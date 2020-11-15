//
//  GrayTextField.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 20/8/2018.
//  Copyright © 2018 Binatir. All rights reserved.
//

#if canImport(SnapKit)
import SnapKit
import UIKit

class GrayTextField: HKTextField {
    
    var backgroundImageColor: UIColor {
        return UIColor(hexCode: "F5F5F5")
    }
    var padding: CGFloat {
        return 15.0
    }
    
    /// The validation closure to check by the text field. By setting this closure, a button is set onto the `rightView` of the receiver, if it's not yet set.
    var validation: ((_ text: String, _ wasFirstResponder: Bool) -> Bool?)? {
        didSet {
            if rightView == nil {
                setRightViewButton()
            }
        }
    }
    
    /// Whether the validation test can pass. If no `validation`, this property returns `true`.
    var isValidationPassed: Bool {
        return validation?(text ?? "", true) ?? true
    }
    
    var errorBorderColor = UIColor.themeDangerRed.withAlphaComponent(0.5)
    var correctBorderColor = UIColor.themeAvailableGreen.withAlphaComponent(0.5)
    
    override var text: String? {
        set {
            super.text = newValue
            validateText()
        }
        get {
            return super.text
        }
    }
    
    /// Whether the receiver has been a first responder before.
    private(set) var wasFirstResponder: Bool = false
    
    private(set) var rightViewButton: UIButton?
    
    var fontSize: CGFloat {
        return ThisDevice.hasSmallScreen ? 15: 17
    }
    
    private var textFieldHeight: CGFloat {
        return ThisDevice.hasSmallScreen ? 36 : 48
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// validate the text, and update UIs of the receiver.
    func validateText() {
        if let bool = validation?(text ?? "", wasFirstResponder) {
            bool ? setCorrectState() : setErrorState()
        } else {
            resetState()
        }   
    }
    
//    @discardableResult
//    override func becomeFirstResponder() -> Bool {
//        defer { wasFirstResponder = true }
//        return super.becomeFirstResponder()
//    }
    
    private func commonInit() {
        tintColor = .themeTextBlack
        font = .systemFont(ofSize: fontSize)
        borderStyle = .none
        layer.cornerRadius = 4.0
        layer.masksToBounds = true
        background = .image(withPureColor: backgroundImageColor, for: CGRect(x: 0, y: 0, width: 1, height: 1), rounded: false)
        textRectInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        leftViewOffset = UIOffset(horizontal: padding, vertical: 0)
        rightViewOffset = UIOffset(horizontal: -padding, vertical: 0)
        snp.makeConstraints { make in
            make.height.equalTo(textFieldHeight).priority(888)
        }
        
        addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
    }

    /// Make the receiver become the correct appearance.
    func setCorrectState() {
        layer.borderWidth = 1
        layer.borderColor = correctBorderColor.cgColor
        if rightView == nil {
            setRightViewButton()
        }
        if rightView == rightViewButton {
            rightViewMode = .always
        }
        rightViewButton?.isEnabled = false
    }
    /// Make the receiver become the error appearance.
    func setErrorState() {
        wasFirstResponder = true
        layer.borderWidth = 1
        layer.borderColor = errorBorderColor.cgColor
        if rightView == nil {
            setRightViewButton()
        }
        if rightView == rightViewButton {
            rightViewMode = .always
        }
        rightViewButton?.isEnabled = true
    }
    /// Make the receiver become the normal appearance.
    func resetState() {
        layer.borderWidth = 0
        if rightView == rightViewButton {
            rightViewMode = .never
        }
    }
    
    
    func indicateContentError() {
        setErrorState()
        shakeToIndicateError()
        rightViewButton?.sendActions(for: .touchUpInside)
    }
    
    private func setRightViewButton() {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.setImage(#imageLiteral(resourceName: "icon_tick").withTintColor(correctBorderColor), for: .disabled)
        button.setImage(#imageLiteral(resourceName: "icon_box_important").withTintColor(errorBorderColor), for: .normal)
        rightViewMode = .never
        rightView = button
        rightViewButton = button
    }
    
    @objc private func editingDidEnd() {
        wasFirstResponder = true
    }
    
}

#endif
