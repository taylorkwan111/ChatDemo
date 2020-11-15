//
//  HKPhotoCropperViewController.swift
//  SACO
//
//  Created by Hesse Huang on 2017/3/20.
//  Copyright © 2017年 Guangzhou Toodony Tech. Ltd. All rights reserved.
//

import UIKit

public protocol HKPhotoCropperViewControllerDelegate: class {
    func localizedConfirmButtonTitle(for photoCropperViewController: HKPhotoCropperViewController) -> String?
    func localizedEditButtonTitle(for photoCropperViewController: HKPhotoCropperViewController) -> String?
    func photoCropperViewController(_ photoCropperViewController: HKPhotoCropperViewController, didFinishWith image: UIImage)
}

public final class HKPhotoCropperViewController: UIViewController {
    
    // MARK: - Public
    
    /// The original image to be processed.
    public let image: UIImage
    
    /// A Boolean value indicating whether the receiver should fix the orientation of the image automatically.
    /// Default value of this property is `true`.
    public var shouldFixImageOrientation: Bool = true

    /// A Boolean value indicating whether the receiver should hide "Moments" back button item on the navigation bar.
    /// Default value of this property is `true`.
    public var shouldHideMomentsBackTitle: Bool = true
    
    /// A Boolean value indicating whether the receiver is in cropping mode or not.
    /// Default value of this property is `true`.
    public var isCroppingMode: Bool = true
    
    /// The scale of the current editing image.
    public private(set) var scale: CGFloat = 1.0
    
    /// The delgate object.
    public weak var delegate: HKPhotoCropperViewControllerDelegate?
    
    
    /// Returns a newly initialized `HKPhotoCropperViewController` with the given to-be-edited image.
    /// This is the designated initializer for this class.
    ///
    /// - Parameters:
    ///   - image: The image to be cropped.
    public init(editImage image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    /// DO NOT USE THIS METHOD.
    /// The implementaion of this initializing method has not been implemented.
    ///
    /// - Parameter aDecoder: A decoder.
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        view.backgroundColor = .darkGray
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        view.addSubview(maskView)
        
        scrollView.contentSize = imageView.bounds.size + CGSize(width: 100, height: 100)
        centralizeImageView(imageView, onScrollView: scrollView)
        
        if isCroppingMode {
            enterCropperMode()
        } else {
            setupPreviewMode()
        }
        
        focusScrollViewAtTheCenter()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        
        var offset = scrollView.contentOffset
        offset.x = (scrollView.contentSize.width - circleDiameter) / 2
        offset.y = (scrollView.contentSize.height - circleDiameter) / 2
        scrollView.setContentOffset(offset, animated: false)
        scrollViewDidEndZooming(scrollView, with: imageView, atScale: scrollView.minimumZoomScale)
        
        if shouldHideMomentsBackTitle {
            hideMomentTitle()
        }
    }
    
    // MARK: - Private
    
    // 整个可缩放的scrollView，内嵌maskView
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: self.view.bounds)
        sv.minimumZoomScale = 1.0
        sv.maximumZoomScale = 4.0
        sv.delegate = self
        return sv
    }()
    
    // 主图imageView
    private lazy var imageView: UIImageView = {
        let iv = UIImageView(image: self.image)
        iv.frame.size = iv.intrinsicContentSize
        iv.frame = self.adjustFrameToFitScreen(iv.frame)
        return iv
    }()
    
    /// 虚线圆的直径
    private let circleDiameter: CGFloat = Screen.width - (32 * 2)
    /// 虚线圆Rect的origin.y
    private var circleRectOriginY: CGFloat { return (Screen.height - circleDiameter) / 2 }
    /// 遮罩View，即虚线圆+半透明黑色View
    private lazy var maskView: UIView = {
        let maskView = UIView(frame: CGRect(x: 0, y: 0, width: Screen.width, height: Screen.height))
        maskView.isUserInteractionEnabled = false
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        maskLayer.fillColor = UIColor(white: 0, alpha: 0.5).cgColor
        
        let circleDiameter = Screen.width - (32 * 2)
        let maskPath = UIBezierPath(ovalIn: CGRect(x: 32, y: self.circleRectOriginY, width: circleDiameter, height: circleDiameter))
        let clipPath = UIBezierPath(rect: maskView.bounds)
        clipPath.append(maskPath)
        clipPath.usesEvenOddFillRule = true
        maskLayer.path = clipPath.cgPath
        maskView.layer.addSublayer(maskLayer)
        
        let line = CAShapeLayer()
        line.lineWidth = 2.0
        line.strokeColor = UIColor.white.cgColor
        line.fillColor = UIColor.clear.cgColor
        line.path = maskPath.cgPath
        line.lineDashPattern = [10, 8]
        maskLayer.addSublayer(line)
        
        return maskView
    }()
    
    
    private var additionalEdgeContentSize: CGSize {
        return CGSize(width: 32 * 2, height: self.circleRectOriginY * 2)
    }

    private func hideMomentTitle() {
        navigationController?.viewControllers.dropLast().last?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @objc private func confirmButtonPressed(_ sender: UIBarButtonItem) {
        let factor = (scrollView.contentSize - additionalEdgeContentSize).width / image.size.width
        let actualClipSize = CGSize(width: circleDiameter, height: circleDiameter) / factor
        let actualClipOrigin = CGPoint(x: scrollView.contentOffset.x / factor, y: scrollView.contentOffset.y / factor)
        let rect = CGRect(origin: actualClipOrigin, size: actualClipSize)
        let size = CGSize(width: 324, height: 324)
        if let newAvatar = image.subImage(in: rect)?.resized(to: size) {
            delegate?.photoCropperViewController(self, didFinishWith: shouldFixImageOrientation ? newAvatar.orientationFixed : newAvatar)
        }
    }
    
    private func setupPreviewMode() {
        maskView.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: delegate?.localizedEditButtonTitle(for: self) ?? "Edit",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(enterCropperMode))
    }
    
    @objc private func enterCropperMode() {
        maskView.isHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: delegate?.localizedConfirmButtonTitle(for: self) ?? "Comfirm",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(confirmButtonPressed(_:)))
    }
    
    private func adjustFrameToFitScreen(_ frame: CGRect) -> CGRect {
        // 如果高度过高
        let height = frame.size.height
        let width = frame.size.width
        
        if height > width {
            let factor = width / Screen.width
            let rect = CGRect(x: 0, y: 0, width: Screen.width, height: height / factor)
            scrollView.minimumZoomScale = circleDiameter / rect.width
            return rect
            
        } else {
            let factor = height / Screen.height
            let rect = CGRect(x: 0, y: 0, width: width / factor, height: Screen.height)
            scrollView.minimumZoomScale = circleDiameter / rect.height
            return rect
        }
    }
    
    /// 将imageView置于scrollView中央
    private func centralizeImageView(_ imageView: UIImageView, onScrollView scrollView: UIScrollView) {
        let svContentWidth = scrollView.contentSize.width
        let svContentHeight = scrollView.contentSize.height
        let svWidth = scrollView.bounds.size.width
        let svHeight = scrollView.bounds.size.height
        
        let x = svContentWidth > svWidth ? svContentWidth / 2 : scrollView.center.x
        let y = svContentHeight > svHeight ? svContentHeight / 2 : scrollView.center.y
        imageView.center = CGPoint(x: x, y: y)
        UIView.animate(withDuration: 0.2, animations: {
            imageView.center = CGPoint(x: x, y: y)
        })
    }
    
    /// 将scrollView滚动至整个content的中央位置
    private func focusScrollViewAtTheCenter() {
        scrollViewDidEndZooming(scrollView,
                                with: viewForZooming(in: scrollView),
                                atScale: 1.0)
        let x = scrollView.contentSize.width / 2 - Screen.width / 2
        let y = scrollView.contentSize.height / 2 - Screen.height / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
}

// MARK: - UIScrollViewDelegate
extension HKPhotoCropperViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // 每次EndZooming后，scrollView的contentSize会自动被设置成跟其内容一样。我们需要手动更新contentSize。
        scrollView.contentSize = imageView.bounds.size * scale + additionalEdgeContentSize
        // 将imageView居中
        centralizeImageView(imageView, onScrollView: scrollView)
        // 更新缩放比
        self.scale = scale
    }

}

