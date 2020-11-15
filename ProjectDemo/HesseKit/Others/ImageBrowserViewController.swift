//
//  ImageBrowserViewController.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 23/4/2018.
//  Copyright © 2018 bichenkk. All rights reserved.
//

#if canImport(FSPagerView)
#if canImport(SDWebImage)

import UIKit
import FSPagerView
import SDWebImage

class ImageBrowserViewController: UIViewController, FSPagerViewDelegate, FSPagerViewDataSource {
    
    enum ContentSource {
        case image([UIImage])
        case url([URL])
    }

    private(set) var contentSource: ContentSource = .image([])
    
    var preselectedIndex = 0
    
    let pagerView = HKPagerView()
    
    let dismissButton = UIButton(type: .system)
    
    var currentIndex: Int {
        return pagerView.currentIndex
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    convenience init(contentSource: ContentSource) {
        self.init()
        self.contentSource = contentSource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupPagerView()
        setupDismissButton()
        
        // manually trigger `pagerView` to layout its content
        pagerView.setNeedsLayout()
        pagerView.layoutIfNeeded()
        pagerView.scrollToItem(at: preselectedIndex, animated: true)
        
        addDownSwipeGesture()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        dismissButton.frame.origin = CGPoint(x: 20, y: view.safeAreaInsets.top + 20)
    }
    
    private func setupDismissButton() {
        // the size of button is based on that of `dismissMark`
        let dismissMark = UIImage.dismissMarker?.withRenderingMode(.alwaysOriginal)
        let size = dismissMark?.size ?? .zero
        if #available(iOS 11.0, *) {
            dismissButton.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 20, width: size.width, height: size.height)
        } else {
            dismissButton.frame = CGRect(x: 20, y: 40, width: size.width, height: size.height)
        }

        dismissButton.setImage(dismissMark, for: .normal)
        dismissButton.layer.cornerRadius = size.height / 2
        dismissButton.layer.masksToBounds = true
        dismissButton.addTarget(self, action: #selector(dismissSelf(_:)), for: .touchUpInside)
        view.addSubview(dismissButton)
    }
    
    private func setupPagerView() {
        pagerView.frame = view.bounds
        pagerView.register(ImageBrowserPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.itemSize = view.bounds.size
        pagerView.innerLayout?.invalidateLayout()
        view.addSubview(pagerView)
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        switch contentSource {
        case .image(let images):
            return images.count
        case .url(let imageUrls):
            return imageUrls.count
        }
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index) as! ImageBrowserPagerViewCell
        cell.isUserInteractionEnabled = false
        cell.zoomableImageView.tag = 1000 + index
        switch contentSource {
        case .image(let images):
            cell.zoomableImageView.image = images[index]
        case .url(let imageUrls):
            let url =  imageUrls[index]
            cell.zoomableImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
            cell.zoomableImageView.sd_imageIndicator?.startAnimatingIndicator()
            cell.zoomableImageView.setImage(src: url, placeholderImage: nil) { _, _, _, _ in
                cell.isUserInteractionEnabled = true
                cell.zoomableImageView.sd_imageIndicator?.stopAnimatingIndicator()
            }
        }
        return cell
    }
    
    func visibleImageView(atIndex index: Int) -> UIImageView? {
        return pagerView.viewWithTag(1000 + index) as? UIImageView
    }
    var currentVisibleImageView: UIImageView? {
        return pagerView.viewWithTag(1000 + currentIndex) as? UIImageView
    }
    
    private func addDownSwipeGesture() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.dismissSelf(_:)))
        swipe.direction = .down
        view.addGestureRecognizer(swipe)
    }
    
  
    
}

class ImageBrowserPagerViewCell: FSPagerViewCell, UIScrollViewDelegate {
    
    let contentScrollView = UIScrollView()
    let zoomableImageView = UIImageView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        contentScrollView.minimumZoomScale = 1
        contentScrollView.maximumZoomScale = 5
        contentScrollView.delegate = self
        contentView.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        zoomableImageView.clipsToBounds = true
        zoomableImageView.contentMode = .scaleAspectFit
        contentScrollView.addSubview(zoomableImageView)
        zoomableImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalTo(contentView)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoomableImageViewDidDoubleTap(_:)))
        tap.numberOfTapsRequired = 2
        zoomableImageView.addGestureRecognizer(tap)
        zoomableImageView.isUserInteractionEnabled = true
    }
    
    @objc private func zoomableImageViewDidDoubleTap(_ sender: UITapGestureRecognizer) {
        if contentScrollView.zoomScale < contentScrollView.maximumZoomScale / 2 {
            let location = sender.location(in: sender.view)
            var rect = CGRect(x: 0, y: 0, width: 120, height: 120)
            rect.center = CGPoint(x: location.x, y: location.y)
            contentScrollView.zoom(to: rect, animated: true)
        } else {
            contentScrollView.setZoomScale(1, animated: true)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomableImageView
    }
    
}

private extension UIImage {
    static let dismissMarker: UIImage? = {
        let size = CGSize(width: 28, height: 28)
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineCap(.round)
        context?.setLineWidth(2.0)
        context?.move(to: CGPoint(x: 8, y: 8))
        context?.addLine(to: CGPoint(x: 20, y: 20))
        context?.move(to: CGPoint(x: 8, y: 20))
        context?.addLine(to: CGPoint(x: 20, y: 8))
        context?.strokePath()
        return UIGraphicsGetImageFromCurrentImageContext()
    }()
}

protocol ImageBrowserCustomTransitioningDelegate: class {
    func sourceImageViewFrame(for imageBrowserViewController: ImageBrowserViewController) -> CGRect
    func destinationImageViewFrame(for imageBrowserViewController: ImageBrowserViewController) -> CGRect
    func transitionDuration(for imageBrowserViewController: ImageBrowserViewController) -> TimeInterval
    func imageBrowserViewControllerWillStartCustomTransitioning()
    func imageBrowserViewControllerDidFinishCustomTransitioning()
    
    // Suporting interaction and interruption
    func shouldFinishDismissalTransition(for imageBrowserViewController: ImageBrowserViewController) -> Bool
}

#endif
#endif
