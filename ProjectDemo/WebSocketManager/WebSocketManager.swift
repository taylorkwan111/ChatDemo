//
//  WebSocketManager.swift
//  WebSocketDemo
//
//  Created by 姬向阳 on 2020/5/7.
//  Copyright © 2020 SUNNYJ. All rights reserved.
//

import Starscream

class WebSocketManager {
    // 单例
    static let shared = WebSocketManager()
    private init() {
        //socket.delegate = self
        // NotificationCenter.default.addObserver(self, selector: #selector(onNetworkStatusChange), name: , object: nil)
    }
    
    /// 是否正在连接
    var isConnected: Bool = false
    /// socket
    var socket = { () -> WebSocket in
        var request = URLRequest(url: URL(string: "http://cloud.chongyeye.com:21567")!)
        request.timeoutInterval = 5
        var socket = WebSocket(request: request)
        return socket
    }()
    
    /// 连接服务器
    func connect() {
        socket.connect()
    }
    
    /// 断开连接
    func disConnect() {
        socket.disconnect()
    }
    
    /// 重新连接
    func reConnect() {
        if(isConnected) {
            disConnect()
        }
        socket.connect()
    }
    
    // 发送文字信息
    func sendString(string: String) {
        socket.write(string: string)
    }
    
    @objc func onNetworkStatusChange() {
        
    }
}
/*
// MARK:- Delegate
extension WebSocketManager: WebSocketDelegate {
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            //handleError(error)
            print(error!.localizedDescription)
        }
    }
}
 */
