//
//  ChatEachOtherViewController.swift
//  ProjectDemo
//
//  Created by 邓唯 on 2020/11/16.
//  Copyright © 2020 Binatir. All rights reserved.
//

import UIKit
import ChatViewController
import Starscream


class ChatEachOtherViewController: ChatViewController {
    
//    var chatManager = ChatManager()
//    var socket: WebSocket!
//    var isConnected = false
    //    let server = WebSocketServer()
    var socketManager = WebSocketManager.shared
    
   
    
    var viewModel: MessageViewModel!
    var imagePickerHelper: ImagePickerHelper?
    var numberUserTypings = 0
    
    init(viewModel: MessageViewModel!) {
           self.viewModel = viewModel
           super.init(nibName: nil, bundle: nil)
       }

       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectServer()
        setupUI()
        setupData()
        bindViewModel()
        //         Get user data firstly
        //        let client = TCPClient(address: "localhost", port: 21567)
        
//        var request = URLRequest(url: URL(string: "ws://127.0.0.1:21567")!)
//        //https://localhost:8080
//        request.timeoutInterval = 5
//        socket = WebSocket(request: request)
//        socket.delegate = self
//        socket.connect()
//        socket.disconnect()
        
//        socket.write(string: "hekkk")
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.getUserData()
        }
        
        viewModel.firstLoadData { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }
    func connectServer() {
        socketManager.connect()
    }
    
    /// 断开连接
    func disConnect() {
        socketManager.disConnect()
    }
    
    /// 连接服务器后,发送avatar注册身份
//    func register() {
//        socketManager.sendString(string: avatar)
//    }
    
    /// 发送消息
    /// - Parameter string: 消息字符串
    func sendMessage(_ string: String) {
        socketManager.sendString(string: string)
    }
    
//    func recieveMessage(_ string: String) {
//           guard let dataFromString = string.data(using: .utf8, allowLossyConversion: false) else {
//               fatalError("Can not load data from string.")
//           }
//           let json = try! JSON(data: dataFromString)
//           if json["type"].string == "color" {
//               let now = Date()
//               let msg = Message(time: now.description(with: .autoupdatingCurrent), author: "System", text: "Login with \(json["data"].string ?? "error") color.", color: json["data"].string ?? "error")
//               addMessage.append(msg)
//           } else if json["type"].string == "history" {
//               for (_,dict):(String, JSON) in json["data"] {
//                   self.dealWithMessage(dict)
//               }
//           } else if json["type"].string == "message" {
//               self.dealWithMessage(json["data"])
//           }
//       }
//    // MARK: - WebSocketDelegate
//    func didReceive(event: WebSocketEvent, client: WebSocket) {
//        switch event {
//        case .connected(let headers):
//            isConnected = true
//            print("websocket is connected: \(headers)")
//        case .disconnected(let reason, let code):
//            isConnected = false
//            print("websocket is disconnected: \(reason) with code: \(code)")
//        case .text(let string):
//            print("Received text: \(string)")
//        case .binary(let data):
//            print("Received data: \(data.count)")
//        case .ping(_):
//            break
//        case .pong(_):
//            break
//        case .viabilityChanged(_):
//            break
//        case .reconnectSuggested(_):
//            break
//        case .cancelled:
//            isConnected = false
//        case .error(let error):
//            isConnected = false
//            handleError(error)
//        }
//    }
//
//    func handleError(_ error: Error?) {
//        if let e = error as? WSError {
//            print("websocket encountered an error: \(e.message)")
//        } else if let e = error {
//            print("websocket encountered an error: \(e.localizedDescription)")
//        } else {
//            print("websocket encountered an error")
//        }
//    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = viewModel.messages[indexPath.row]
        let cellIdentifer = message.cellIdentifer()
        let user = viewModel.getUserFromID(message.sendByID)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifer, for: indexPath) as! MessageCell
        let positionInBlock = viewModel.getPositionInBlockForMessageAtIndex(indexPath.row)
        
        cell.transform = tableView.transform
        cell.bind(withMessage: viewModel.messages[indexPath.row], user: user)
        cell.updateUIWithBubbleStyle(viewModel.bubbleStyle, isOutgoingMessage: message.isOutgoing)
        cell.updateLayoutForBubbleStyle(viewModel.bubbleStyle, positionInBlock: positionInBlock)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let chatCell = cell as! MessageCell
        let positionInBlock = viewModel.getPositionInBlockForMessageAtIndex(indexPath.row)
        
        chatCell.layoutIfNeeded()
        
        // Update UI for cell
        chatCell.showHideUIWithBubbleStyle(viewModel.bubbleStyle, positionInBlock: positionInBlock)
        chatCell.updateAvatarPosition(bubbleStyle: viewModel.bubbleStyle)
        chatCell.roundViewWithBubbleStyle(viewModel.bubbleStyle, positionInBlock: positionInBlock)
    }
    
    override func didPressSendButton(_ sender: Any?) {
        guard let currentUser = viewModel.currentUser else {
            return
        }
        
        let message = Message(id: UUID().uuidString, sendByID: currentUser.id,
                              createdAt: Date(), text: chatBarView.textView.text)
        addMessage(message)
        socketManager.sendString(string: chatBarView.textView.text)
        
//        socket.write(string: chatBarView.textView.text)
        super.didPressSendButton(sender)
    }
    
    override func didPressGalleryButton(_ sender: Any?) {
        guard configuration.imagePickerType == .actionSheet else {
            super.didPressGalleryButton(sender)
            return
        }
        
        /// Dismiss keyboard if keyboard is showing
        if currentKeyboardType == .default {
            dismissKeyboard()
        }
        
        imagePickerHelper?.takeOrChoosePhoto()
    }
    
    override func didSelectVideo(url: URL?) {
        print("URL \(url!)")
    }
    
    override func didSelectImage(url: URL?) {
        print("URL \(url!)")
    }
}


extension ChatEachOtherViewController {
    
    private func setupUI() {
        title = "Liliana"
        addBackBarButton()
        
        /// Tableview
        tableView.estimatedRowHeight = 88
        tableView.keyboardDismissMode = .none
        tableView.register(MessageTextCell.self, forCellReuseIdentifier: MessageTextCell.reuseIdentifier)
        tableView.register(MessageImageCell.self, forCellReuseIdentifier: MessageImageCell.reuseIdentifier)
        
        // Set buttons
        let typingButton = UIButton(type: .system)
        typingButton.setImage(UIImage(named: "ic_typing"), for: .normal)
        typingButton.adjustsImageWhenHighlighted = false
        typingButton.addTarget(self, action:#selector(handleTypingButton), for:.touchUpInside)
        typingButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let typingButtonBarItem = UIBarButtonItem(customView: typingButton)
        
        let hideChatBarButton = UIButton(type: .system)
        hideChatBarButton.setImage(UIImage(named: "ic_keyboard"), for: .normal)
        hideChatBarButton.adjustsImageWhenHighlighted = false
        hideChatBarButton.addTarget(self, action:#selector(handleShowHideChatBar(_:)), for:.touchUpInside)
        hideChatBarButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        hideChatBarButton.transform = CGAffineTransform(rotationAngle: .pi)
        let hideChatBarButtonItem = UIBarButtonItem(customView: hideChatBarButton)
        
        navigationItem.rightBarButtonItems = [typingButtonBarItem, hideChatBarButtonItem]
        
        // Add function load more for table view
        tableView.addLoadMore { [weak self] in
            self?.viewModel.loadMoreData(completion: { indexPaths in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.tableView.beginUpdates()
                    // We will reload the last row before we add new message to display right bubblr type
                    let firstRow = indexPaths.first
                    let lastRow = IndexPath(row: firstRow!.row - 1, section: 0)
                    self?.tableView.reloadRows(at: [lastRow], with: .none)
                    self?.tableView.insertRows(at: indexPaths, with: .bottom)
                    self?.tableView.endUpdates()
                    self?.tableView.stopLoadMore()
                    self?.updateLoadMoreAble()
                }
            })
        }
        
        // Add function refresh for table view
        tableView.addFooterRefresh { [weak self] in
            self?.viewModel.firstLoadData {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.tableView.reloadData()
                    self?.tableView.stopFooterRefresh()
                    // After reload we should enable load more function
                    self?.tableView.setLoadMoreEnable(true)
                }
            }
        }
    }
    
    private func bindViewModel() {
        
    }
    
    private func setupData() {
        guard configuration.imagePickerType == .actionSheet else {
            return
        }
        
        imagePickerHelper = ImagePickerHelper()
        imagePickerHelper?.delegate = self
        imagePickerHelper?.parentViewController = self
    }
    
    private func updateUI() {
        tableView.reloadData { [weak self] in
            self?.viewModel.isRefreshing = false
        }
    }
    
    private func addMessage(_ message: Message) {
        viewModel.messages.insert(message, at: 0)
        
        // Insert new message cell
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        tableView.endUpdates()
        
        // Check if we have more than one message
        switch viewModel.bubbleStyle {
        case .facebook:
            if viewModel.messages.count <= 1 { return }
            reloadLastMessageCell()
        default: break
        }
    }
    
    @objc private func handleTypingButton() {
        switch numberUserTypings {
        case 0, 1, 2:
            var user: User
            switch numberUserTypings {
            case 0:
                user = User (id: 1, name: "Harry")
            case 1:
                user = User(id: 2, name: "Bob")
            default:
                user = User(id: 3, name: "Liliana")
            }
            viewModel.users.append(user)
            typingIndicatorView.insertUser(user)
            numberUserTypings += 1
        default:
            for user in viewModel.users {
                typingIndicatorView.removeUser(user)
            }
            numberUserTypings = 0
            break
        }
    }
    
    @objc private func handleShowHideChatBar(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            sender.imageView?.transform = sender.imageView?.transform.rotated(by: CGFloat.pi) ?? CGAffineTransform.identity
        }
        setChatBarHidden(!isCharBarHidden, animated: true)
    }
    private func updateLoadMoreAble() {
        tableView.setLoadMoreEnable(viewModel.pagination?.hasMore() ?? false)
    }
    
    private func reloadLastMessageCell() {
        tableView.beginUpdates()
        let lastIndexPath = IndexPath(row: 1, section: 0)
        let cell = tableView.cellForRow(at: lastIndexPath) as? MessageCell
        let positionInBlock = viewModel.getPositionInBlockForMessageAtIndex(lastIndexPath.row)
        cell?.updateLayoutForBubbleStyle(viewModel.bubbleStyle, positionInBlock: positionInBlock)
        cell?.roundViewWithBubbleStyle(viewModel.bubbleStyle, positionInBlock: positionInBlock)
        tableView.endUpdates()
        tableView.scrollToFirstCell()
    }
}



