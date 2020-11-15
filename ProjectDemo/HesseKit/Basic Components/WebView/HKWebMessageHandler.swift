//
//  HKScriptMessageHandler.swift
//  HesseKit
//
//  Created by Hesse Huang on 2018/2/4.
//  Copyright © 2018年 Hesse. All rights reserved.
//

import WebKit

typealias HKWebMessageAction = (Any) -> Void

class HKScriptMessageHandler: NSObject, WKScriptMessageHandler {
    
    var actions = [String: HKWebMessageAction]()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        actions[message.name]?(message.body)
        dprint("Web is invocating native methods... name = \(message.name), body = \(message.body)")
    }
    
}
