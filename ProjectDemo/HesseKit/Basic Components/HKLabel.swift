//
//  HKLabel.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 31/3/2018.
//  Copyright © 2018 bichenkk. All rights reserved.
//

import UIKit

/// A label with content insets.
@IBDesignable
class HKLabel: UILabel {

    var contentInsets: UIEdgeInsets = .zero
    
    @IBInspectable
    var topInset: CGFloat {
        get { return contentInsets.top }
        set { contentInsets.top = newValue }
    }
    @IBInspectable
    var bottomInset: CGFloat {
        get { return contentInsets.bottom }
        set { contentInsets.bottom = newValue }
    }
    @IBInspectable
    var leftInset: CGFloat {
        get { return contentInsets.left }
        set { contentInsets.left = newValue }
    }
    @IBInspectable
    var rightInset: CGFloat {
        get { return contentInsets.right }
        set { contentInsets.right = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setCustomFont()
    }
    
    func setCustomFont() { }
    
    override func drawText(in rect: CGRect) {
        // https://stackoverflow.com/questions/27459746/adding-space-padding-to-a-uilabel/27461090#27461090
        super.drawText(in: rect.inset(by: contentInsets))
    }
        
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += contentInsets.left + contentInsets.right
        size.height += contentInsets.top + contentInsets.bottom
        return size
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
    
}

class HKKeyNumberFormattedLabel: HKLabel {
    
    // MARK: - Public
    var keyNumber: Int = 0 {
        didSet {
            super.text = format(keyNumber)
        }
    }
    var format: (Int) -> String = { "\($0) hasn't been formatted."} {
        didSet {
            super.text = format(keyNumber)
        }
    }
    
    func increase(value: Int = 1) {
        keyNumber += value
    }
    
    func decrease(value: Int = 1) {
        keyNumber -= value
    }
    
    // MARK: - Private
    @available(*, unavailable)
    override var text: String? {
        get { return super.text }
        set { super.text = newValue }
    }

}

class HKGradientLabelView: UIView {
    
    let label = HKLabel()
    
    let backgroundGradientLayer = CAGradientLayer()
    
    override var frame: CGRect {
        didSet {
            label.frame.size = bounds.size
            backgroundGradientLayer.frame.size = bounds.size
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundGradientLayer.frame.size = bounds.size
        backgroundGradientLayer.colors = [#colorLiteral(red: 1, green: 0.7406695236, blue: 0.02244160582, alpha: 1).cgColor,#colorLiteral(red: 1, green: 0.9245636287, blue: 0.00438770172, alpha: 1).cgColor]
        backgroundGradientLayer.startPoint = .zero
        backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(backgroundGradientLayer)
        label.contentInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        mask = label
    }
    
    override var intrinsicContentSize: CGSize {
        return label.intrinsicContentSize
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        frame.size = label.intrinsicContentSize
    }
    
}
