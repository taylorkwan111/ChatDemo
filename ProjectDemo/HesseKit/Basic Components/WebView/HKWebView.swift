//
//  HKWebView.swift
//  HesseKit
//
//  Created by Hesse Huang on 2018/2/4.
//  Copyright © 2018年 Hesse. All rights reserved.
//

import WebKit


/// 自定义的WebView，集成了message handling的功能。
class HKWebView: WKWebView {

    deinit {
        removeMessageHandler()
    }
    
    private lazy var messageHandler = HKScriptMessageHandler()
    
    func response(message name: String, action: @escaping HKWebMessageAction) {
        messageHandler.actions[name] = action
        configuration.userContentController.add(messageHandler, name: name)
    }
    
    private func removeMessageHandler() {
        messageHandler.actions.forEach {
            configuration.userContentController.removeScriptMessageHandler(forName: $0.key)
        }
        messageHandler.actions.removeAll()
    }

    
}



