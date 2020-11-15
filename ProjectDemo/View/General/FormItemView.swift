//
//  FormItemView.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 16/5/2019.
//  Copyright © 2019 Binatir. All rights reserved.
//

#if canImport(SnapKit)
import SnapKit
import UIKit

/// The following classes are Kawa-like, similar implementations.

class FormItemView: UIView {
    
    let descriptionLabel: UILabel = {
        let l = UILabel()
        l.textColor = .themeTextLightGray
        l.font = .regularRegular
        return l
    }()
    let textField: HKTextField = {
        let t = HKTextField()
        t.tintColor = .black
        t.textColor = .black
        t.font = .regularRegular
        return t
    }()
    
    // Setting text without breaking the layout. If you'd like to set this, make sure after setting `descriptionLabel.text`
    var contentText: String? {
        get {
            return textField.text
        }
        set {
            descriptionLabel.layoutIfNeeded()
            textField.text = newValue
            if isTextEmpty {
                resetDescriptionLabel(animated: false)
            } else {
                animateDescriptionLabel(animated: false)
            }
        }
    }
    
    var automaticallyAnimateDescriptionLabel: Bool = true
    
    private var isTextEmpty: Bool {
        return textField.text?.isEmpty ?? true
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
        layer.cornerRadius = LayoutConstant.cornerRadius
        backgroundColor = .themeBackgroundLightGray
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        textField.addTarget(self, action: #selector(textFieldEditingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldEditingDidEnd), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(textFieldEditingDidEnd), for: .editingDidEndOnExit)
        textField.textRectInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10))
            make.height.equalTo(48).priority(999)
        }
    }
    
    
    @objc private func textFieldEditingDidBegin() {
        if isTextEmpty {
            if automaticallyAnimateDescriptionLabel {
                animateDescriptionLabel(animated: true)
            }
        }
    }
    
    @objc private func textFieldEditingDidEnd() {
        if isTextEmpty {
            if automaticallyAnimateDescriptionLabel {
                resetDescriptionLabel(animated: true)
            }
        }
    }
    
    func animateDescriptionLabel(animated: Bool) {
        let scaling: CGFloat = 0.75
        let xOffset = descriptionLabel.bounds.width * (1 - scaling) / 2
        var `transform` = CGAffineTransform.identity
        transform.translateBy(x: -xOffset, y: -12)
        transform.scaleBy(x: scaling, y: scaling)
        if animated {
            UIView.animate(
                withDuration: 0.15,
                delay: 0, options: [.curveEaseInOut, .beginFromCurrentState],
                animations: {
                    self.descriptionLabel.transform = transform
            },
                completion: { _ in
                    self.descriptionLabel.transform = transform
            })
        } else {
            self.descriptionLabel.transform = transform
        }
    }
    
    func resetDescriptionLabel(animated: Bool) {
        if animated {
            UIView.animate(
                withDuration: 0.15,
                delay: 0, options: [.curveEaseInOut, .beginFromCurrentState],
                animations: {
                    self.descriptionLabel.transform = .identity
                    self.descriptionLabel.textColor = .gray
            },
                completion: { _ in
                    self.descriptionLabel.transform = .identity
                    self.descriptionLabel.textColor = .gray
            })
        } else {
            self.descriptionLabel.transform = .identity
            self.descriptionLabel.textColor = .gray
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            return textField
        }
        return view
    }
    
    
}


class KawaFormItemTableViewCell: UITableViewCell {
    
    var titleLabel: UILabel {
        return itemView.descriptionLabel
    }
    
    var textField: HKTextField {
        return itemView.textField
    }
    
    /// Set the text into text field.
    var textFieldText: String? {
        get {
            return textField.text
        }
        set {
            itemView.contentText = newValue
        }
    }
    
    private let itemView = FormItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        contentView.addSubview(itemView)
        itemView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        }
    }
}

class KawaFormDoubleItemsTableViewCell: UITableViewCell {
    
    var leftDecLabel: UILabel {
        return leftItemView.descriptionLabel
    }
    var leftTextField: HKTextField {
        return leftItemView.textField
    }
    var leftTextFieldText: String? {
        get {
            return leftTextField.text
        }
        set {
            leftItemView.contentText = newValue
        }
    }
    var rightDecLabel: UILabel {
        return rightItemView.descriptionLabel
    }
    var rightTextField: HKTextField {
        return rightItemView.textField
    }
    var rightTextFieldText: String? {
        get {
            return rightTextField.text
        }
        set {
            rightItemView.contentText = newValue
        }
    }

    let leftItemView = FormItemView()
    let rightItemView = FormItemView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        let stackView = UIStackView(arrangedSubviews: [leftItemView, rightItemView])
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        }
    }
    
}

#endif
