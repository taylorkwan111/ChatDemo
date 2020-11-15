//
//  AlertViewController.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 14/6/2018.
//  Copyright © 2018 bichenkk. All rights reserved.
//

import UIKit

class AlertQueue: NSObject {
    
    static let `default` = AlertQueue()
    
    /// The array of AlertViewController. The first element in this array is the one currently showing on screen.
    /// If no elements here, there is no alert views on screen.
    var alerts = [AlertViewController]()
    
    /// Appends a new alert view controller into the queue. Any duplicated one will be discards.
    ///
    /// - Parameter alert: The alert to be shown or discarded.
    func tryToAppend(alert: AlertViewController) {
        // If it's already in queue, simply ignore.
        if alerts.contains(alert) {
            return
        }
        // Discard any duplicated alerts.
        if alerts.contains(where: { $0.isDuplicated(comparedWith: alert) }) {
            dprint("Duplicated alert discarded: \(alert.titleLabel?.text ?? "-NOTITLE-") - \(alert.messageLabel?.text ?? "-NOMESSAGE-")")
            return
        }
        alerts.append(alert)
    }
    
    
    /// Handle the dismissal of an alert.
    ///
    /// - Parameter alert: The alert that just dismissed.
    func handleAlertDismissal(alert: AlertViewController) {
        alerts.remove(alert)
        alerts.first?.attemptToPresent()
    }
    
    /// Returns `true` if the given alert view controller should be presented.
    ///
    /// - Parameter alert: The alert view controller intended to show.
    /// - Returns: `true` if the given alert view controller should be presented.
    func shouldPresent(alert: AlertViewController) -> Bool {
        return alerts.first == alert
    }
    
}

class AlertViewController: PopupViewController {
    
    // MARK: - Supporting Alert Actions
    var cancelTitle: String?
    var cancelHandler: (() -> Void)?
    var confirmTitle: String?
    var confirmHandler: (() -> Void)?
    var confirmTitle2: String?
    var confirmHandler2: (() -> Void)?
    
    
    var additionalDidDismissAction: (() -> Void)?
    
    var queue: AlertQueue {
        return .default
    }
    
    @objc func commitCancelAction() {
        additionalDidDismissAction = cancelHandler
        dismissPopupView()
    }
    
    @objc func commitConfirmAction() {
        additionalDidDismissAction = confirmHandler
        dismissPopupView()
    }
    
    @objc func commitConfirmAction2() {
        additionalDidDismissAction = confirmHandler2
        dismissPopupView()
    }
    
    deinit {
        printDeinitMessage()
    }
    
    /// Represents some layout options to be applied when making a new alert view.
    enum ViewOption {
        /// Using dedicated popup image
        case dedicatedImage(UIImage)
        /// Using general images or image urls
        case generalImage(UIImage?, URL?)
        /// Using the specified placeholder image
        case placeholderImage(UIImage?)
        /// Tells the image view to use the specified content mode.
        case contentMode(UIView.ContentMode)
        /// Tells the image view to resize itself so that it matches the preferred size.
        case preferredSize(CGSize)
        /// Tells the image view to resize exactly to the specified size.
        case exactSize(CGSize)
        /// Sets the image view with the given alpha value
        case alpha(CGFloat)
        /// Uses multi-option alert
        case useMultioption([(String?, () -> Void)])
        
        case titleLabelConfig((UILabel) -> Void)
        case buttonConfig((UIButton) -> Void)
    }
    
    
    // MARK: - Views
    fileprivate var imageView: UIImageView?
    fileprivate var titleLabel: UILabel?
    fileprivate var messageLabel: UILabel?
    fileprivate(set) var buttons = [UIButton]()
    
    
    /// Make an alert view.
    ///
    /// - Parameters:
    ///   - title: The title.
    ///   - message: The detail message under the title.
    ///   - options: Options that configurate the image view.
    ///   - customView: An optional custom view added just above the alert buttons.
    /// - Returns: A newly created alert view.
    func makeAlertView(title: String,
                       message: NSAttributedString?,
                       options: [ViewOption] = [],
                       customView: UIView? = nil) -> UIView {
        
        let alertWidth = 300.0 / 375.0 * Screen.width
        let alertWidthWithContentPadding = alertWidth //- 16 * 2
        
        // The container.
        let alertView = UIView().then { it in
            it.backgroundColor = .white
            it.layer.masksToBounds = true
            it.layer.cornerRadius = 8
            it.snp.makeConstraints { make in
                make.width.equalTo(alertWidth)
//                make.height.greaterThanOrEqualTo(alertWidth)
            }
        }
        
        let labelStackView = UIStackView().then { it in
            it.axis = .vertical
            it.spacing = 10
            it.alignment = .fill
            it.distribution = .fill
            alertView.addSubview(it)
            it.snp.makeConstraints { make in
                make.leading.top.trailing.bottom.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
            }
        }
        
        // Use customized multiple option buttons instead of simply cancel+confirm.
        var multioptions: [(String?, () -> Void)]?
        
        var titleLabelConfig: ((UILabel) -> Void)?
        var buttonConfig: ((UIButton) -> Void)?
        
        if !options.isEmpty {
            
            // Parsing options
            var dedicatedImage: UIImage?
            var generalImage: UIImage?
            var generalImageUrl: URL?
            var placeholderImage: UIImage?
            var contentMode: UIView.ContentMode?
            var preferredSize: CGSize?
            var exactSize: CGSize?
            var alpha: CGFloat?
            
            
            options.forEach {
                switch $0 {
                case .dedicatedImage(let image):
                    dedicatedImage = image
                case .generalImage(let image, let url):
                    generalImage = image
                    generalImageUrl = url
                case .placeholderImage(let image):
                    placeholderImage = image
                case .contentMode(let mode):
                    contentMode = mode
                case .preferredSize(let size):
                    preferredSize = size.fittingTargetSize(CGSize(width: alertWidthWithContentPadding, height: .greatestFiniteMagnitude))
                case .exactSize(let size):
                    exactSize = size
                case .alpha(let a):
                    alpha = a
                case .useMultioption(let options):
                    multioptions = options
                case .titleLabelConfig(let c):
                    titleLabelConfig = c
                case .buttonConfig(let c):
                    buttonConfig = c
                }
            }
            
            if dedicatedImage != nil || generalImage != nil || generalImageUrl != nil {
                let imageViewBase = UIView().then { it in
                    it.snp.makeConstraints { make in
                        make.height.greaterThanOrEqualTo(it.snp.width).multipliedBy(0.4)
                    }
                    labelStackView.addArrangedSubview(it)
                }
                
                // Configurating image view
                let imageView = UIImageView().then { it in
                    it.image = dedicatedImage ?? generalImage
                    it.contentMode = contentMode ?? .scaleAspectFill
                    it.alpha = alpha ?? 1.0
                    if let imageUrl = generalImageUrl {
                        #if canImport(SDWebImage)
                        it.setImage(src: imageUrl, placeholderImage: placeholderImage)
                        #endif
                    }
                    
                    imageViewBase.addSubview(it)
                    it.snp.makeConstraints { make in
                        make.width.equalTo(exactSize?.width ?? preferredSize?.width ?? 120)
                        make.height.equalTo(exactSize?.height ?? preferredSize?.height ?? 120).priority(999)
                        make.centerX.centerY.equalToSuperview()
                        make.width.lessThanOrEqualToSuperview().offset(-16 * 2)
                        make.height.equalToSuperview().offset(-16 * 2)
                    }
                }
                self.imageView = imageView
            }
            
        }
        
        let titleLabel = BIBoldSectionLabel().then { it in
            it.text = title
            it.textColor = .black
            it.textAlignment = .center
            it.numberOfLines = 0
        }
        titleLabelConfig?(titleLabel)
        self.titleLabel = titleLabel
        
        labelStackView.addArrangedSubview(titleLabel)
        
        // Layout a message label
        if let message = message {
            let messageLabel = BIAdditionalLabel().then {
                $0.textAlignment = .center
                $0.textColor = .themeTextLightGray
                $0.attributedText = message
                $0.numberOfLines = 0
            }
            self.messageLabel = messageLabel
            
            labelStackView.addArrangedSubview(messageLabel)
        }
        
        // Layout the custom view
        if let customView = customView {
            labelStackView.addArrangedSubview(customView)
        }
        
        if let multioptions = multioptions, !multioptions.isEmpty {
            buttons = multioptions.map {
                newButton(title: $0.0, closure: $0.1)
            }
            
        } else {
            if let confirmTitle = confirmTitle {
                buttons.append(newButton(title: confirmTitle, action: #selector(commitConfirmAction)))
            }
            if let confirmTitle2 = confirmTitle2 {
                buttons.append(newButton(title: confirmTitle2, action: #selector(commitConfirmAction2)))
            }
            if let cancelTitle = cancelTitle {
                let cancelButton = newButton(title: cancelTitle, action: #selector(commitCancelAction))
                cancelButton.backgroundColor = .themeLightBlack
                buttons.append(cancelButton)
            }
        }
        if buttons.count == 1 {
            buttons.first?.backgroundColor = .themeBlack
        }
        if !buttons.isEmpty {
            // Layout all the buttons
            let buttonStackView = UIStackView(arrangedSubviews: buttons)
            buttonStackView.axis = .vertical
            buttonStackView.alignment = .fill
            buttonStackView.distribution = .fillEqually
            buttonStackView.spacing = 10
            
            // Make an additional spacing between the buttons and the view above them.
            if #available(iOS 11.0, *) {
                if let last = labelStackView.arrangedSubviews.last {
                    labelStackView.setCustomSpacing(16, after: last)
                }
            }
            
            labelStackView.addArrangedSubview(buttonStackView)
            buttonStackView.snp.makeConstraints { make in
                make.width.equalToSuperview()
            }
        }
        buttons.forEach {
            buttonConfig?($0)
        }
        
        return alertView
    }
    
    private func newButton(title: String?, action: Selector?) -> UIButton {
        let btn = ProceedButton(type: .system)
        btn.layer.cornerRadius = 0
        btn.layer.masksToBounds = false
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = .themeBlack
        if let action = action {
            btn.addTarget(self, action: action, for: .touchUpInside)
        }
        return btn
    }
    
    private func newButton(title: String?, closure: @escaping () -> Void) -> UIButton {
        let btn = newButton(title: title, action: nil)
        btn.addAction(for: .touchUpInside) { [weak self] in
            self?.additionalDidDismissAction = closure
            self?.dismissPopupView()
        }
        return btn
    }
    
    // MARK: - Supporting Multi-alert
    func attemptToPresent() {
        queue.tryToAppend(alert: self)
        if let vc = UIViewController.getCurrentViewController(), queue.shouldPresent(alert: self) {
            vc.view.endEditing(true) // End any editing session (hide keyboard)
            vc.present(self, animated: false, completion: nil)
        }
    }
    
    func isDuplicated(comparedWith anAlertViewController: AlertViewController) -> Bool {
        let sameTitle = titleLabel?.text == anAlertViewController.titleLabel?.text
        let sameMessage = messageLabel?.text == anAlertViewController.messageLabel?.text
        
        var sameButtons = true
        zip(buttons, anAlertViewController.buttons).forEach {
            sameButtons = sameButtons && $0.titleLabel?.text == $1.titleLabel?.text
        }
        return sameTitle && sameMessage && sameButtons
    }
    
    
}

extension AlertViewController: PopupViewControllerDelegate {
    
    func popupViewControllerDidDismiss(_ popupViewController: PopupViewController) {
        // Commit any additional action.
        additionalDidDismissAction?()
        // Supporting multi-alerts
        queue.handleAlertDismissal(alert: self)
    }
}

extension UIViewController {
    
    /// Show a newly created popup view on the view controller.
    ///
    /// - Parameters:
    ///   - title: The title (text) in bold
    ///   - message: The subtitle in regular
    ///   - image: A image to be shown
    ///   - preferredImageSize: The preferred size of the image, which is 120x120 by default
    ///   - confirmTitle: The title of confirm button. `confirmTitle` and `confirmHandler` should be passed or omitted in pair.
    ///   - confirmHandler: The action of confirm button. `confirmTitle` and `confirmHandler` should be passed or omitted in pair.
    ///   - confirmTitle2: The title of another optional confirm button. `confirmTitle2` and `confirmHandler2` should be passed or omitted in pair.
    ///   - confirmHandler2: The action of another optional confirm button. `confirmTitle2` and `confirmHandler2` should be passed or omitted in pair.
    ///   - cancelTitle: The title of cancel button
    ///   - cancelHandler: The action of cancel button
    func showAlert(
        title: String,
        message: NSAttributedString? = nil,
        image: UIImage? = nil,
        options: [AlertViewController.ViewOption] = [],
        isTapToDismissEnabled: Bool = true,
        customView: UIView? = nil,
        confirmTitle: String? = nil,
        confirmHandler: (() -> Void)? = nil,
        confirmTitle2: String? = nil,
        confirmHandler2: (() -> Void)? = nil,
        cancelTitle: String? = NSLocalizedString("Cancel", bundle: .language, comment: "Button title"),
        cancelHandler: (() -> Void)? = nil)
    {
        
        func appropriateSize(forDedicatedImage image: UIImage) -> CGSize {
            let alertWidth = 270.0 / 375.0 * Screen.width
            let maxHeight: CGFloat = 140
            let maxWidth = alertWidth * 2/3
            if image.size.width < maxWidth && image.size.height < maxHeight {
                return image.size
            } else {
                let maxSize = CGSize(width: maxWidth, height: maxHeight)
                return image.size.fittingTargetSize(maxSize)
            }
        }
        
        let alertViewController = AlertViewController()
        alertViewController.delegate = alertViewController
        alertViewController.cancelTitle = cancelTitle
        alertViewController.cancelHandler = cancelHandler
        alertViewController.confirmTitle = confirmTitle
        alertViewController.confirmHandler = confirmHandler
        alertViewController.confirmTitle2 = confirmTitle2
        alertViewController.confirmHandler2 = confirmHandler2
        
        
        var options = options
        
        // Add the give image to `.dedicatedImage` if it's not exist.
        if let image = image, !options.containsDedicatedImage {
            options.append(.dedicatedImage(image))
        }
        
        // Specifying `.preferredSize` if there is `.dedicatedImage`
        if let _ = options.firstDedicatedImage, !options.containsSize {
            let size = CGSize(width: 40, height: 40)
            options.append(.exactSize(size))
            options.append(.contentMode(.scaleAspectFit))
        }
        
        let alertView = alertViewController.makeAlertView(
            title: title,
            message: message,
            options: options,
            customView: customView)
        
        alertViewController.popupView = alertView
        alertViewController.isTapToDismissEnabled = isTapToDismissEnabled
        alertViewController.attemptToPresent()
        
    }
    
    func showSuccessAlert(
        title: String,
        message: String? = nil,
        image: UIImage? = nil,
        isTapToDismissEnabled: Bool = true,
        customView: UIView? = nil,
        confirmTitle: String? = nil,
        confirmHandler: (() -> Void)? = nil,
        confirmTitle2: String? = nil,
        confirmHandler2: (() -> Void)? = nil,
        cancelTitle: String? = NSLocalizedString("Cancel", bundle: .language, comment: "Button title"),
        cancelHandler: (() -> Void)? = nil)
    {
        var msg: NSAttributedString?
        if let message = message {
            msg = NSAttributedString(string: message, attributes: [.foregroundColor: UIColor.themeTextLightGray])
        }
        showSuccessAlert(title: title, message: msg, image: image, isTapToDismissEnabled: isTapToDismissEnabled, confirmTitle: confirmTitle, confirmHandler: confirmHandler, confirmTitle2: confirmTitle2, confirmHandler2: confirmHandler2, cancelTitle: cancelTitle, cancelHandler: cancelHandler)
    }
    
    func showSuccessAlert(
        title: String,
        message: NSAttributedString?,
        image: UIImage? = nil,
        isTapToDismissEnabled: Bool = true,
        customView: UIView? = nil,
        confirmTitle: String? = nil,
        confirmHandler: (() -> Void)? = nil,
        confirmTitle2: String? = nil,
        confirmHandler2: (() -> Void)? = nil,
        cancelTitle: String? = NSLocalizedString("Cancel", bundle: .language, comment: "Button title"),
        cancelHandler: (() -> Void)? = nil)
    {
        showAlert(title: title, message: message, image: image, isTapToDismissEnabled: isTapToDismissEnabled, confirmTitle: confirmTitle, confirmHandler: confirmHandler, confirmTitle2: confirmTitle2, confirmHandler2: confirmHandler2, cancelTitle: cancelTitle, cancelHandler: cancelHandler)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func showFailureAlert(
        title: String,
        message: String? = nil,
        image: UIImage? = nil,
        isTapToDismissEnabled: Bool = true,
        customView: UIView? = nil,
        confirmTitle: String? = nil,
        confirmHandler: (() -> Void)? = nil,
        confirmTitle2: String? = nil,
        confirmHandler2: (() -> Void)? = nil,
        cancelTitle: String? = NSLocalizedString("Okay", bundle: .language, comment: "Button title"),
        cancelHandler: (() -> Void)? = nil)
    {
        var msg: NSAttributedString?
        if let message = message {
            msg = NSAttributedString(string: message, attributes: [.foregroundColor: UIColor.themeTextLightGray])
        }
        showFailureAlert(title: title, message: msg, image: image, isTapToDismissEnabled: isTapToDismissEnabled, customView: customView, confirmTitle: confirmTitle, confirmHandler: confirmHandler, confirmTitle2: confirmTitle2, confirmHandler2: confirmHandler2, cancelTitle: cancelTitle, cancelHandler: cancelHandler)
    }
    func showFailureAlert(
        title: String,
        message: NSAttributedString?,
        image: UIImage? = nil,
        isTapToDismissEnabled: Bool = true,
        customView: UIView? = nil,
        confirmTitle: String? = nil,
        confirmHandler: (() -> Void)? = nil,
        confirmTitle2: String? = nil,
        confirmHandler2: (() -> Void)? = nil,
        cancelTitle: String? = NSLocalizedString("Okay", bundle: .language, comment: "Button title"),
        cancelHandler: (() -> Void)? = nil)
    {
        showAlert(title: title, message: message, image: image, isTapToDismissEnabled: isTapToDismissEnabled, customView: customView, confirmTitle: confirmTitle, confirmHandler: confirmHandler, confirmTitle2: confirmTitle2, confirmHandler2: confirmHandler2, cancelTitle: cancelTitle, cancelHandler: cancelHandler)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    
    func showInquiryAlert(
        title: String,
        message: String? = nil,
        image: UIImage? = nil,
        isTapToDismissEnabled: Bool = true,
        customView: UIView? = nil,
        confirmTitle: String? = nil,
        confirmHandler: (() -> Void)? = nil,
        confirmTitle2: String? = nil,
        confirmHandler2: (() -> Void)? = nil,
        cancelTitle: String? = NSLocalizedString("Cancel", bundle: .language, comment: "Button title"),
        cancelHandler: (() -> Void)? = nil)
    {
        var msg: NSAttributedString?
        if let message = message {
            msg = NSAttributedString(string: message, attributes: [.foregroundColor: UIColor.themeTextLightGray])
        }
        showInquiryAlert(title: title, message: msg, image: image, isTapToDismissEnabled: isTapToDismissEnabled, customView: customView, confirmTitle: confirmTitle, confirmHandler: confirmHandler, confirmTitle2: confirmTitle2, confirmHandler2: confirmHandler2, cancelTitle: cancelTitle, cancelHandler: cancelHandler)
    }
    
    func showInquiryAlert(
        title: String,
        message: NSAttributedString?,
        image: UIImage? = nil,
        isTapToDismissEnabled: Bool = true,
        customView: UIView? = nil,
        confirmTitle: String? = nil,
        confirmHandler: (() -> Void)? = nil,
        confirmTitle2: String? = nil,
        confirmHandler2: (() -> Void)? = nil,
        cancelTitle: String? = NSLocalizedString("Cancel", bundle: .language, comment: "Button title"),
        cancelHandler: (() -> Void)? = nil)
    {
        showAlert(title: title, message: message, image: image, isTapToDismissEnabled: isTapToDismissEnabled, customView: customView, confirmTitle: confirmTitle, confirmHandler: confirmHandler, confirmTitle2: confirmTitle2, confirmHandler2: confirmHandler2, cancelTitle: cancelTitle, cancelHandler: cancelHandler)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    
}

fileprivate extension UIImage {
    
    // The image on dismiss button of alert view.
    static let alertDismissButtonImage: UIImage? = {
        let size = CGSize(width: 28, height: 28)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        let rect = CGRect(origin: .zero, size: size)
        let roundedRectPath = UIBezierPath(roundedRect: rect, cornerRadius: 4)
        UIColor.gray.setFill()
        roundedRectPath.fill()
        
        let insetRect = rect.inset(by: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        let crossPath = UIBezierPath().then {
            $0.move(to: insetRect.topLeft)
            $0.addLine(to: insetRect.bottomRight)
            $0.move(to: insetRect.topRight)
            $0.addLine(to: insetRect.bottomLeft)
            $0.lineWidth = 3
            $0.lineCapStyle = .round
        }
        UIColor.white.setStroke()
        crossPath.stroke()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }()
    
}

extension Array where Element == AlertViewController.ViewOption {
    var firstDedicatedImage: UIImage? {
        if case .dedicatedImage(let image)? = first(where: {
            switch $0 {
            case .dedicatedImage:
                return true
            default:
                return false
            }
        }) {
            return image
        }
        return nil
    }
    var containsDedicatedImage: Bool {
        return contains {
            switch $0 {
            case .dedicatedImage:
                return true
            default:
                return false
            }
        }
    }
    var containsSize: Bool {
        return contains {
            switch $0 {
            case .exactSize, .preferredSize:
                return true
            default:
                return false
            }
        }
    }
}
