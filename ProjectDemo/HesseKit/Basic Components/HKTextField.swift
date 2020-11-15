//
//  HKTextField.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 22/8/2018.
//  Copyright © 2018 Binatir. All rights reserved.
//

import UIKit

class HKTextField: UITextField {
    
    var isPasteEnabled: Bool = true
    var hidesCursor: Bool = false
    
    var textRectInsets: UIEdgeInsets = .zero
    var leftViewOffset: UIOffset = .zero
    var rightViewOffset: UIOffset = .zero
    
    /// The error recovery message used to present to users to help them input the correct and expected content.
    var localizedErrorRecoveryMessage: String?
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        rect.size.width -= (textRectInsets.left + textRectInsets.right)
        rect.size.height -= (textRectInsets.top + textRectInsets.bottom)
        rect.origin.x += textRectInsets.left
        rect.origin.y += textRectInsets.top
        return rect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        rect.size.width -= (textRectInsets.left + textRectInsets.right)
        rect.size.height -= (textRectInsets.top + textRectInsets.bottom)
        rect.origin.x += textRectInsets.left
        rect.origin.y += textRectInsets.top
        return rect
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) && !isPasteEnabled {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += leftViewOffset.horizontal
        rect.origin.y += leftViewOffset.vertical
        return rect
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x += rightViewOffset.horizontal
        rect.origin.y += rightViewOffset.vertical
        return rect
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return hidesCursor ? .zero : super.caretRect(for: position)
    }
    
}
