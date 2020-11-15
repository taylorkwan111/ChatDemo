//
//  ProceedButton.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 25/7/2018.
//  Copyright © 2018 Binatir. All rights reserved.
//
#if canImport(SnapKit)
import SnapKit
import UIKit

class ProceedButton: UIButton {
    
    enum Style {
        case tint, white, disabled
    }
    
    var style: Style = .tint {
        didSet {
            switch style {
            case .tint:
                backgroundColor = .themeTint
                setTitleColor(.white, for: .normal)
            case .white:
                backgroundColor = .white
                setTitleColor(.themeTint, for: .normal)
            case .disabled:
                backgroundColor = .themeDisabledGray
                setTitleColor(.white, for: .normal)
            }
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
    
    private var titleFont: UIFont {
        return .systemFont(ofSize: 16)
    }
    
    private func commonInit() {
        style = .tint
        titleLabel?.font = titleFont
        layer.cornerRadius = LayoutConstant.cornerRadius
        layer.masksToBounds = true
        snp.makeConstraints { make in
            make.height.equalTo(LayoutConstant.proceedButtonHeight).priority(880)
        }
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        titleLabel?.font = titleFont
    }
    
    private var titleBeforeShowingIndicator: String?
    private(set) var loadingIndicator: UIActivityIndicatorView?

    func showLoadingIndictorInsteadOfTitle() {
        guard loadingIndicator == nil else { return }
        let indicator = UIActivityIndicatorView(style: .white)
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
        indicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        indicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loadingIndicator = indicator
        titleBeforeShowingIndicator = title(for: .normal)
        setTitle(nil, for: .normal)
        backgroundColor = .themeDisabledGray
        isEnabled = false
    }
    
    func restoreTitleFromLoadingIndictor() {
        guard loadingIndicator != nil else { return }
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
        loadingIndicator = nil
        setTitle(titleBeforeShowingIndicator, for: .normal)
        titleBeforeShowingIndicator = nil
        backgroundColor = .themeTint
        isEnabled = true
    }

}

#endif
