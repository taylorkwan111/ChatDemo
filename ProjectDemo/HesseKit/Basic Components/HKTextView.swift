//
//  HKTextView.swift
//  Kawa
//
//  Created by Hesse Huang on 17/5/2018.
//  Copyright © 2018 bichenkk. All rights reserved.
//

import UIKit

// Reference:
// https://stackoverflow.com/questions/27652227/text-view-placeholder-swift
// https://github.com/MoZhouqi/KMPlaceholderTextView/blob/master/KMPlaceholderTextView/KMPlaceholderTextView.swift
class HKTextView: UITextView {
    
    @IBInspectable open var placeholder: String? {
        get {
            return placeholderLabel.text
        }
        set {
            placeholderLabel.text = newValue
            layoutPlaceholderLabel()
        }
    }
    
    @IBInspectable open var placeholderColor: UIColor {
        get {
            return placeholderLabel.textColor
        }
        set {
            placeholderLabel.textColor = newValue
        }
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            layoutPlaceholderLabel()
        }
    }
    
    let placeholderLabel = UILabel()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutPlaceholderLabel()
    }
    
    private func commonInit() {
        font = .systemFont(ofSize: 17)
        placeholderLabel.textColor = .lightGray
        placeholderLabel.numberOfLines = 0
        addSubview(placeholderLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)
    }
    
    private func layoutPlaceholderLabel() {
        let size = CGSize(width: bounds.size.width - textContainer.lineFragmentPadding * 2,
                          height: CGFloat.greatestFiniteMagnitude)
        let height = placeholderLabel.text?.boundingRect(with: size,
                                                         options: [.usesLineFragmentOrigin],
                                                         attributes: [.font: placeholderLabel.font ?? .systemFont(ofSize: 17)],
                                                         context: nil).height ?? 0.0
        placeholderLabel.frame.origin = CGPoint(x: textContainer.lineFragmentPadding + textContainerInset.left, y: textContainerInset.top)
        placeholderLabel.frame.size = CGSize(width: size.width, height: height)
    }
    
    
    @objc func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    
    // MARK: - Validation
    
    /// The validation closure to check by the text field. By setting this closure, a button is set onto the `rightView` of the receiver, if it's not yet set.
    var validation: ((_ text: String, _ wasFirstResponder: Bool) -> Bool?)?
    
    /// The error recovery message used to present to users to help them input the correct and expected content.
    var localizedErrorRecoveryMessage: String?
    
    /// Whether the validation test can pass. If no `validation`, this property returns `true`.
    var isValidationPassed: Bool {
        return validation?(text ?? "", true) ?? true
    }
    
    var errorBorderColor = UIColor.red.withAlphaComponent(0.5)
    var correctBorderColor = UIColor.green.withAlphaComponent(0.5)
    
    override var text: String! {
        set {
            super.text = newValue
            validateText()
            textDidChange()
        }
        get {
            return super.text
        }
    }
    
    /// Whether the receiver has been a first responder before.
    private(set) var wasFirstResponder: Bool = false
    
    /// validate the text, and update UIs of the receiver.
    func validateText() {
        if let bool = validation?(text ?? "", wasFirstResponder) {
            bool ? setCorrectState() : setErrorState()
        } else {
            resetState()
        }
    }
    
    /// Make the receiver become the correct appearance.
    func setCorrectState() {
        layer.borderWidth = 1
        layer.borderColor = correctBorderColor.cgColor
    }
    /// Make the receiver become the error appearance.
    func setErrorState() {
        wasFirstResponder = true
        layer.borderWidth = 1
        layer.borderColor = errorBorderColor.cgColor
    }
    /// Make the receiver become the normal appearance.
    func resetState() {
        layer.borderWidth = 0
    }
    
    func indicateContentError() {
        setErrorState()
        shakeToIndicateError()
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        defer { wasFirstResponder = true }
        return super.becomeFirstResponder()
    }
    
}
