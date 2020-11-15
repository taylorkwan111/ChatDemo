//
//  ChatListTableViewController.swift
//  ProjectDemo
//
//  Created by 邓唯 on 2020/11/12.
//  Copyright © 2020 Binatir. All rights reserved.
//

import UIKit
import ChatViewController
class ChatListTableViewController: BaseTableViewController {

  var bubbleImageStyle: BubbleStyle = .facebook
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chat"
        configureTableView()
    }
    
    private func configureTableView() {
           tableView.do {
               $0.separatorStyle = .none
               $0.keyboardDismissMode = .onDrag
               $0.delegate = self
               $0.dataSource = self
               $0.register(ChatListTableViewCell.nib, forCellReuseIdentifier: "cell")
               $0.backgroundView = UIImageView(image: UIImage(named: "chatbg"))
           }
       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Table view data source
}



extension ChatListTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return 4
       }
       
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatListTableViewCell
           return cell
       }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatEachOtherViewController(viewModel: MessageViewModel(bubbleStyle: bubbleImageStyle)) as! ChatViewController
        vc.hidesBottomBarWhenPushed = true
        var configuration = ChatViewConfiguration.default
//        configuration.chatBarStyle = chatBarStyle
//        configuration.imagePickerType = imagePickerType
        configuration.chatBarStyle = .default
        configuration.imagePickerType = .slack
        vc.configuration = configuration

        navigationController?.pushViewController(vc, animated: true)
    }
    
}
