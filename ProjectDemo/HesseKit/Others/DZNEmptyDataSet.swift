//
//  DZNEmptyDataSet.swift
//  DZNEmptyDataSet
//
//  Created by Hesse Huang on 2017/3/21.
//  Copyright © 2018年 Hesse. All rights reserved.
//

import UIKit

protocol DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString?
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString?
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage?
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor?
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView) -> CAAnimation?
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString?
    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage?
    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView) -> UIImage?
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor?
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView?
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat
}

extension DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? { return nil }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? { return nil }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? { return nil }
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? { return nil }
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView) -> CAAnimation? { return nil }
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? { return nil }
    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? { return nil }
    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView) -> UIImage? { return nil }
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? { return nil }
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? { return nil }
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat { return 0.0 }
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat { return 0.0 }
}

protocol DZNEmptyDataSetDelegate: class {
    func emptyDataSetShouldFadeIn(_ scrollView: UIScrollView) -> Bool
    func emptyDataSetShouldBeForcedToDisplay(_ scrollView: UIScrollView) -> Bool
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool
    func emptyDataSetShouldAllowAnimateImageView(_ scrollView: UIScrollView) -> Bool
    func emptyDataSet(_ scrollView: UIScrollView, didTap view: UIView)
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton)
    func emptyDataSetWillAppear(_ scrollView: UIScrollView)
    func emptyDataSetDidAppear(_ scrollView: UIScrollView)
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView)
    func emptyDataSetDidDisappear(_ scrollView: UIScrollView)
}

extension DZNEmptyDataSetDelegate {
    func emptyDataSetShouldFadeIn(_ scrollView: UIScrollView) -> Bool { return true }
    func emptyDataSetShouldBeForcedToDisplay(_ scrollView: UIScrollView) -> Bool { return false }
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool { return true }
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool { return true }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool { return true }
    func emptyDataSetShouldAllowAnimateImageView(_ scrollView: UIScrollView) -> Bool { return false }
    func emptyDataSet(_ scrollView: UIScrollView, didTap view: UIView) {}
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {}
    func emptyDataSetWillAppear(_ scrollView: UIScrollView) {}
    func emptyDataSetDidAppear(_ scrollView: UIScrollView) {}
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView) {}
    func emptyDataSetDidDisappear(_ scrollView: UIScrollView) {}
}


private class DZNEmptyDataSetView: UIView {

    lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 27.0)
        $0.textColor = UIColor(white: 0.6, alpha: 1.0)
        $0.textAlignment = .center
        $0.lineBreakMode = .byWordWrapping
        $0.numberOfLines = 0
        $0.accessibilityIdentifier = "empty set title"
        return $0
    }(UILabel())
    
    lazy var detailLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 17.0)
        $0.textColor = UIColor(white: 0.6, alpha: 1.0)
        $0.textAlignment = .center
        $0.lineBreakMode = .byWordWrapping
        $0.numberOfLines = 0
        $0.accessibilityIdentifier = "empty set detail title"
        return $0
    }(UILabel())
    
    lazy var imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.accessibilityIdentifier = "empty set background image"
        return $0
    }(UIImageView())
    
    lazy var button: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentHorizontalAlignment = .center
        $0.accessibilityIdentifier = "empty set button"
        $0.addTarget(self, action: #selector(DZNEmptyDataSetView.didTap(button:)), for: .touchUpInside)
        return $0
    }(UIButton(type: .custom))
    
    var customView: UIView? {
        willSet {
            customView?.removeFromSuperview()
        }
        didSet {
            customView?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    
    var tapGesture: UITapGestureRecognizer?
    
    var verticalOffset: CGFloat = 0.0
    var verticalSpace: CGFloat = 11.0
    
    var fadeInOnDisplay: Bool = true
    
    private var shouldShowImageView: Bool {
        return imageView.image != nil
    }
    
    private var shouldShowTitleLabel: Bool {
        if let text = titleLabel.attributedText {
            return !text.string.isEmpty
        } else {
            return false
        }
    }
    
    private var shouldShowDetailLabel: Bool {
        if let text = detailLabel.attributedText {
            return !text.string.isEmpty
        } else {
            return false
        }
    }
    
    private var shouldShowButton: Bool {
        var isTitleExist: Bool {
            if let title = button.attributedTitle(for: .normal) {
                return !title.string.isEmpty
            } else {
                return false
            }
        }
        var isImageExist: Bool {
            return button.image(for: .normal) != nil
        }
        return isTitleExist || isImageExist
    }
    
    // MARK: - Refine Using StackView
    let stackView = UIStackView()
    
    func setupUsingStackView() {
        
        if let superview = superview {
            self.translatesAutoresizingMaskIntoConstraints = false
            self.leadingAnchor.constraint(equalTo: superview.layoutMarginsGuide.leadingAnchor).isActive = true
            self.trailingAnchor.constraint(equalTo: superview.layoutMarginsGuide.trailingAnchor).isActive = true
            self.topAnchor.constraint(equalTo: superview.layoutMarginsGuide.topAnchor).isActive = true
            self.bottomAnchor.constraint(equalTo: superview.layoutMarginsGuide.bottomAnchor).isActive = true
        }
        
        stackView.axis = .vertical
        stackView.spacing = verticalSpace
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true // Not supplied by data source yet
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: verticalOffset).isActive = true
        
        // If applicable, set the custom view's constraints
        if let customView = customView {
            stackView.addArrangedSubview(customView)
        }
        else {
            
            // setup image view
            if shouldShowImageView {
                stackView.addArrangedSubview(imageView)
            } else {
                stackView.removeArrangedSubview(imageView)
            }
            
            // setup title label
            if shouldShowTitleLabel {
                stackView.addArrangedSubview(titleLabel)
            } else {
                stackView.removeArrangedSubview(titleLabel)
            }
            
            // setup detail text label
            if shouldShowDetailLabel {
                stackView.addArrangedSubview(detailLabel)
            } else {
                stackView.removeArrangedSubview(detailLabel)
            }
            
            // setup button
            if shouldShowButton {
                stackView.addArrangedSubview(button)
            } else {
                stackView.removeArrangedSubview(button)
            }
        }
    }

    
    // MARK: -
    
    
    private func removeAllConstraints() {
        removeConstraints(constraints)
    }
    
    func prepareForReuse() {
        removeAllConstraints()
    }
    
    @objc private func didTap(button: UIButton) {
        guard let scrollView = superview as? UIScrollView else { return }
        scrollView.emptyDataSetDelegate?.emptyDataSet(scrollView, didTap: button)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        // Return any UIControl instance such as buttons, segmented controls, switches, etc.
        if hitView is UIControl {
            return hitView
        }
        // Return either the contentView or customView
        if /*hitView == content666View ||*/ hitView == customView {
            return hitView
        }
        return nil
    }
}

extension UIScrollView {
    
    private struct Key {
        static var emptyDataSetSource         = "emptyDataSetSource"
        static var emptyDataSetDelegate       = "emptyDataSetDelegate"
        static var emptyDataSetView           = "emptyDataSetView"
        static var emptyImageViewAnimation    = "com.dzn.emptyDataSet.imageViewAnimation"
    }
    
    private var emptyDataSetView: DZNEmptyDataSetView {
        get {
            if let view = objc_getAssociatedObject(self, &Key.emptyDataSetView) as? DZNEmptyDataSetView {
                return view
            } else {
                let view = DZNEmptyDataSetView()
                view.isHidden = true
                self.emptyDataSetView = view
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(UIScrollView.dzn_didTap(contentView:)))
                tap.delegate = self
                view.tapGesture = tap
                view.addGestureRecognizer(tap)
                return view
            }
        }
        set {
            objc_setAssociatedObject(self, &Key.emptyDataSetView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var emptyDataSetSource: DZNEmptyDataSetSource? {
        get {
            let container = objc_getAssociatedObject(self, &Key.emptyDataSetSource) as? DZNWeakObjectContainer
            return container?.weakObject as? DZNEmptyDataSetSource
        }
        set {
            if newValue == nil || dzn_canDisplay {
                dzn_invalidate()
            }
            objc_setAssociatedObject(self, &Key.emptyDataSetSource, DZNWeakObjectContainer(weakObject: newValue as AnyObject), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // We add method sizzling for injecting -dzn_reloadData implementation to the native -reloadData implementation
            // Exclusively for UITableView, we also inject -dzn_reloadData to -endUpdates
//            if self is UITableView {
//                UIScrollView.swizzleMethodsInTableView
//            }
//            else if self is UICollectionView {
//                UIScrollView.swizzleMethodsInCollectionView
//            }
        }
    }
    
//    private static let swizzleMethodsInTableView: Void = {
//        swizzleMethod(cls: UITableView.self, original: #selector(UITableView.reloadData),              swizzled: #selector(UITableView.dzn_reloadData))
//        swizzleMethod(cls: UITableView.self, original: #selector(UITableView.deleteSections(_:with:)), swizzled: #selector(UITableView.dzn_deleteSections(_:with:)))
//        swizzleMethod(cls: UITableView.self, original: #selector(UITableView.deleteRows(at:with:)),    swizzled: #selector(UITableView.dzn_deleteRows(at:with:)))
//        swizzleMethod(cls: UITableView.self, original: #selector(UITableView.endUpdates),              swizzled: #selector(UITableView.dzn_endUpdates))
////        swizzleMethod(cls: UITableView.self, original: #selector(UITableView.layoutSubviews),          swizzled: #selector(UITableView.dzn_layoutSubviews_tableView))
//    }()
    
    private static let swizzleMethodsInCollectionView: Void = {
        swizzleMethod(cls: UICollectionView.self, original: #selector(UICollectionView.reloadData),         swizzled: #selector(UICollectionView.dzn_reloadData))
        swizzleMethod(cls: UICollectionView.self, original: #selector(UICollectionView.deleteSections(_:)), swizzled: #selector(UICollectionView.dzn_deleteSections(_:)))
        swizzleMethod(cls: UICollectionView.self, original: #selector(UICollectionView.deleteItems(at:)),   swizzled: #selector(UICollectionView.dzn_deleteItems(at:)))
//        swizzleMethod(cls: UICollectionView.self, original: #selector(UICollectionView.layoutSubviews),     swizzled: #selector(UICollectionView.dzn_layoutSubviews_collectionView))
    }()
    
    var emptyDataSetDelegate: DZNEmptyDataSetDelegate? {
        get {
            let container = objc_getAssociatedObject(self, &Key.emptyDataSetDelegate) as? DZNWeakObjectContainer
            return container?.weakObject as? DZNEmptyDataSetDelegate
        }
        set {
            if newValue == nil {
                dzn_invalidate()
            }
            
            objc_setAssociatedObject(self, &Key.emptyDataSetDelegate, DZNWeakObjectContainer(weakObject: newValue as AnyObject?), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var isEmptyDataSetVisible: Bool {
        return !emptyDataSetView.isHidden
    }
    
    private var dzn_canDisplay: Bool {
        return emptyDataSetSource != nil
    }
    
    private var dzn_itemsCount: Int {
        if let tableView = self as? UITableView, let dataSource = tableView.dataSource {
            let sections = dataSource.numberOfSections?(in: tableView) ?? 1
            return (0..<sections).reduce(0) {
                $0 + dataSource.tableView(tableView, numberOfRowsInSection: $1)
            }
        }
        else if let collectionView = self as? UICollectionView, let dataSource = collectionView.dataSource {
            let sections = dataSource.numberOfSections?(in: collectionView) ?? 1
            return (0..<sections).reduce(0) {
                $0 + dataSource.collectionView(collectionView, numberOfItemsInSection: $1)
            }
        }
        return 0
    }
    
    @objc private func dzn_didTap(contentView: UIView) {
        emptyDataSetDelegate?.emptyDataSet(self, didTap: contentView)
    }
    
    // MARK: - Reload APIs
    /// Reload and update the whole empty data set view
    func reloadEmptyDataSet() {

        guard dzn_canDisplay else { return }
        let noContent = dzn_itemsCount == 0
        let shouldDisplay = emptyDataSetDelegate?.emptyDataSetShouldDisplay(self) ?? false
        let shouldForceToDisplay = emptyDataSetDelegate?.emptyDataSetShouldBeForcedToDisplay(self) ?? false
        
        if shouldDisplay && noContent || shouldForceToDisplay {
            
            // Notifies that the empty dataset view will appear
            emptyDataSetDelegate?.emptyDataSetWillAppear(self)
            // Notifies that the empty dataset view did appear (defer this action)
            defer { emptyDataSetDelegate?.emptyDataSetDidAppear(self) }
            
            let view = emptyDataSetView
            
            // Configure empty dataset fade in display
            view.fadeInOnDisplay = emptyDataSetDelegate?.emptyDataSetShouldFadeIn(self) ?? true

            // Add emptyDataSetView to self
            if view.superview == nil {
                // Send the emptyDataSetView all the way to the back, in case a header and/or footer is present, as well as for sectionHeaders or any other content
                if (self is UITableView || self is UICollectionView) && subviews.count > 1 {
                    insertSubview(view, at: 0)
                } else {
                    addSubview(view)
                }
            }
            
            // Removing view resetting the view and its constraints it very important to guarantee a good state
            view.prepareForReuse()
            
            guard let source = emptyDataSetSource else { return }
            
            // If a non-nil custom view is available, let's configure it instead
            if let customView = source.customView(forEmptyDataSet: self) {
                view.customView = customView
            } else {
                // Get the data from the data source and
                // Configure Image
                if let image = source.image(forEmptyDataSet: self) {
                    if let imageTintColor = source.imageTintColor(forEmptyDataSet: self) {
                        view.imageView.tintColor = imageTintColor
                        view.imageView.image = image.withRenderingMode(.alwaysTemplate)
                    } else {
                        view.imageView.image = image
                    }
                }
                // Configure title label
                if let title = source.title(forEmptyDataSet: self) {
                    view.titleLabel.attributedText = title
                }
                // Configure detail label
                if let description = source.description(forEmptyDataSet: self) {
                    view.detailLabel.attributedText = description
                }
                // Configure button
                if let buttonImage = source.buttonImage(forEmptyDataSet: self, for: .normal) {
                    view.button.setImage(buttonImage, for: .normal)
                    if let buttonHighlightedImage = source.buttonImage(forEmptyDataSet: self, for: .highlighted) {
                        view.button.setImage(buttonHighlightedImage, for: .highlighted)
                    }
                } else if let title = source.buttonTitle(forEmptyDataSet: self, for: .normal) {
                    view.button.setAttributedTitle(title, for: .normal)
                    if let higtlightedTitle = source.buttonTitle(forEmptyDataSet: self, for: .highlighted) {
                        view.button.setAttributedTitle(higtlightedTitle, for: .highlighted)
                    }
                    if let backgroundImage = source.buttonBackgroundImage(forEmptyDataSet: self) {
                        view.button.setBackgroundImage(backgroundImage, for: .normal)
                        view.button.setBackgroundImage(backgroundImage, for: .highlighted)
                    }
                }
                
                // Configure offset
                view.verticalOffset = source.verticalOffset(forEmptyDataSet: self)
                view.verticalSpace = source.spaceHeight(forEmptyDataSet: self)
                // Configure the empty dataset view
                view.backgroundColor = source.backgroundColor(forEmptyDataSet: self)
                view.isHidden = false
                view.clipsToBounds = true
                
                // Main setup using UIStackView
                view.setupUsingStackView()
                
                UIView.performWithoutAnimation {
                    view.layoutIfNeeded()
                }
                
                if let delegate = emptyDataSetDelegate {
                    // Configure empty dataset userInteraction permission
                    view.isUserInteractionEnabled = delegate.emptyDataSetShouldAllowTouch(self)
//                        // Configure empty dataset fade in display
//                        view.fadeInOnDisplay = delegate.emptyDataSetShouldFadeIn(self)
                    // Configure scroll permission
                    isScrollEnabled = delegate.emptyDataSetShouldAllowScroll(self)
                    
                    // Configure image view animation
                    if delegate.emptyDataSetShouldAllowAnimateImageView(self) {
                        if let animation = source.imageAnimation(forEmptyDataSet: self) {
                            view.imageView.layer.add(animation, forKey: Key.emptyImageViewAnimation)
                        }
                    }
                    else if view.imageView.layer.animation(forKey: Key.emptyImageViewAnimation) != nil {
                        view.imageView.layer.removeAnimation(forKey: Key.emptyImageViewAnimation)
                    }
                }
            }

        } else if isEmptyDataSetVisible {
            dzn_invalidate()
        }
    }
    private func dzn_invalidate() {
        // Notifies that the empty dataset view will disappear
        emptyDataSetDelegate?.emptyDataSetWillDisappear(self)
        defer { emptyDataSetDelegate?.emptyDataSetDidDisappear(self) }
        
        emptyDataSetView.prepareForReuse()
        emptyDataSetView.removeFromSuperview()
        
        isScrollEnabled = true
    }
    
    @objc private func dzn_deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        dzn_deleteSections(sections, with: animation)
        reloadEmptyDataSet()
    }
    
    @objc private func dzn_deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        dzn_deleteRows(at: indexPaths, with: animation)
        reloadEmptyDataSet()
    }
    
    @objc private func dzn_deleteSections(_ sections: IndexSet) {
        dzn_deleteSections(sections)
        reloadEmptyDataSet()
    }
    
    @objc private func dzn_deleteItems(at indexPath: [IndexPath]) {
        dzn_deleteItems(at: indexPath)
        reloadEmptyDataSet()
    }
    
    @objc private func dzn_endUpdates() {
        dzn_endUpdates()
        reloadEmptyDataSet()
    }

}

// 替换或交换UITableView和UICollectionView的reloadData实现、UITableView的endUpdates()实现
fileprivate func swizzleMethod<T: NSObject>(cls: T.Type, original: Selector, swizzled: Selector) {
    guard let originalMethod = class_getInstanceMethod(cls, original), let swizzledMethod = class_getInstanceMethod(cls, swizzled) else {
        fatalError("`orginalMethod` or `swizzledMethod` is nil")
    }
    let didAddMethod = class_addMethod(cls, original, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
    if didAddMethod {
        class_replaceMethod(cls, swizzled, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UIScrollView: UIGestureRecognizerDelegate {
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == emptyDataSetView {
            return emptyDataSetDelegate?.emptyDataSetShouldAllowTouch(self) ?? true
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let tapGestrue = emptyDataSetView.tapGesture {
            if tapGestrue == gestureRecognizer || tapGestrue == otherGestureRecognizer {
                return true
            }
        }
        if let scrollView = emptyDataSetDelegate as? UIScrollView, scrollView != self {
            if let tapDelegate = scrollView as UIGestureRecognizerDelegate? {
                if let result = tapDelegate.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
                    return result
                }
            }
        }
        return false
    }
}

extension UITableView {
    @objc fileprivate func dzn_reloadData() {
        dzn_reloadData()
        reloadEmptyDataSet()
    }
}

extension UICollectionView {
    @objc fileprivate func dzn_reloadData() {
        dzn_reloadData()
        reloadEmptyDataSet()
    }
}

private class DZNWeakObjectContainer: NSObject {
    weak var weakObject: AnyObject?
    init(weakObject: AnyObject?) {
        super.init()
        self.weakObject = weakObject
    }
}
