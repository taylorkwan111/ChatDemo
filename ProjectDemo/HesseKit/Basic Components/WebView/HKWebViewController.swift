//
//  HKWebViewController.swift
//  HesseKit
//
//  Created by Hesse Huang on 2018/2/4.
//  Copyright © 2018年 Hesse. All rights reserved.
//

import UIKit
import WebKit

class HKWebViewController: UIViewController, UIScrollViewDelegate, WKNavigationDelegate, WKUIDelegate {
    
    fileprivate enum KVOKeyPath: String {
        case title
        case estimatedProgress
    }
    
    deinit {
        // removing observers
        if shouldObserveTitle {
            endUpdatingTitle()
        }
        if !isProgressViewHidden {
            endProcessIndicating()
        }
        // fixing a bug in iOS 9
        if webView.scrollView.delegate != nil {
            webView.scrollView.delegate = nil
        }
    }
    
    
    // The web view used to render webpages
    let webView: HKWebView = {
        let js = """
            var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');
            meta.setAttribute('content', 'width=device-width');
            document.getElementsByTagName('head')[0].appendChild(meta);
            document.body.style.fontFamily = '-apple-system';
        """
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController
        return HKWebView(frame: .zero, configuration: wkWebConfig)
    }()
    
    // The progress view to indicate the loading process
    let progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: Screen.width, height: 2.0))
    
    var isProgressViewHidden: Bool {
        get {
            return progressView.isHidden
        }
        set {
            let isHiddenPreviously = progressView.isHidden
            progressView.isHidden = newValue
            // to show
            if isHiddenPreviously && !newValue {
                startProgressIndicating()
            }
            // to hide
            else if !isHiddenPreviously && newValue {
                endProcessIndicating()
            }
        }
    }
    
    // Whether to observe the webpage title changes or not. By default is `false`
    var shouldObserveTitle: Bool = false {
        didSet {
            if oldValue && !shouldObserveTitle {
                endUpdatingTitle()
            }
            else if !oldValue && shouldObserveTitle {
                startUpdatingTitle()
            }
        }
    }
    
    /// To indicate whether there are errors occur, `true` if so.
    fileprivate(set) var loadFailed = false
    
    /// The hyperlink that requested last time calling `loadWebpage`
    private(set) var requestedHref: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // configurate the web view
        let config = WKWebViewConfiguration()
        config.userContentController = WKUserContentController()
        let pref = WKPreferences()
        pref.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = pref
        
        setupUI()

        webView.navigationDelegate = self
        // make the scrolling experience alike that in native scroll view
        webView.scrollView.decelerationRate = UIScrollView.DecelerationRate.normal
        webView.scrollView.delegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        if #available(iOS 9.0, *) {
            webView.allowsLinkPreview = true
        }
        
        // set up the progress view
        progressView.trackTintColor = .clear

        if !isProgressViewHidden {
            startProgressIndicating()
        }

    }
    

    /// Load a new webpage with a given URL string
    ///
    /// - Parameter url: 要请求的url
    func loadWebpage(url: String) {
        guard let URL = URL(string: url) else {
            dprint("构造URL对象返回nil，无法加载url: \(url.isEmpty ? "(empty)" : url)")
            return
        }
        let request = URLRequest(url: URL)
        self.webView.load(request)
    }
    
    
    /// 响应来自WebKit的message
    ///
    /// - Parameters:
    ///   - name: handler的name
    ///   - action: 执行的操作
    func response(message name: String, action: @escaping HKWebMessageAction) {
        webView.response(message: name, action: action)
    }
    
    /// 显示或隐藏进度条
    ///
    /// - Parameter show: 显示传true, 隐藏传false
    private func showProgressView(_ show: Bool) {
        UIView.animate(
            withDuration: 0.2,
            delay: show ? 0.0 : 0.35,
            options: .curveEaseInOut,
            animations: {
                self.progressView.alpha = show ? 1.0 : 0.0
        },
            completion: nil)
    }
    private func startProgressIndicating() {
        webView.addObserver(self, forKeyPath: KVOKeyPath.estimatedProgress.rawValue, options: .new, context: nil)
    }
    private func endProcessIndicating() {
        webView.removeObserver(self, forKeyPath: KVOKeyPath.estimatedProgress.rawValue)
    }
    
    /// KVO获取WebView标题
    private func startUpdatingTitle() {
        webView.addObserver(self, forKeyPath: KVOKeyPath.title.rawValue, options: .new, context: nil)
    }
    private func endUpdatingTitle() {
        webView.removeObserver(self, forKeyPath: KVOKeyPath.title.rawValue)
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard
            let rawValue = keyPath,
            let keyPath = KVOKeyPath(rawValue: rawValue),
            let newValue = change?[.newKey]
            else { return }
        
        switch keyPath {
        case .title:
            guard let newTitle = newValue as? String else { return }
            didObserveNewTitle(newTitle)
            
        case .estimatedProgress:
            guard let progress = newValue as? Float else { return }
            didObserveNewProgress(progress)
        }
        
    }
    
    /// KVO获取到了新标题
    func didObserveNewTitle(_ title: String) {
        self.title = title
    }
    
    /// KVO获取到了新进度
    func didObserveNewProgress(_ progress: Float) {
        progressView.progress = progress
        if progressView.alpha == 0.0 && progress != 1.0 {
            showProgressView(true)
        }
        if progress == 1.0 {
            showProgressView(false)
        }
    }
    
    /// 推出一个新的Web
    ///
    /// - Parameter url: 网页地址
    fileprivate func pushNewWebViewController(with url: String) {
        let webVC = HKWebViewController()
        webVC.loadWebpage(url: url)
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    
    
    /// 网络不好、请求失败时，显示“网络错误”并让用户点击可重新加载
    ///
    /// - Parameter error: 错误
    func handleError(_ error: Error) {
        let e = error as NSError
        switch e.code {
        case NSURLErrorTimedOut,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorBadServerResponse,
             NSURLErrorSecureConnectionFailed:
            loadFailed = true
            
        default:
            break
        }
    }
    
    private func setupUI() {
        view.addSubview(webView)
        view.addSubview(progressView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[webView]|",
                options: [],
                metrics: nil,
                views: ["webView": webView]) +
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[webView]|",
                    options: [],
                    metrics: nil,
                    views: ["webView": webView]) +
                NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|[progressView]|",
                    options: [],
                    metrics: nil,
                    views: ["progressView": progressView]) +
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[progressView(2)]",
                    options: [],
                    metrics: nil,
                    views: ["progressView": progressView])
        )
    }
    
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        
//        if let url = navigationAction.request.url?.absoluteString {
//            if let URL = URL(string: url), url.hasPrefix("tel:") {
//                UIApplication.shared.openURL(URL)
//            }
//            else if navigationAction.targetFrame == nil {
//                pushMostAppropriateWebVC(url: url)
//            }
//        }
//        dprint("decidePolicyFor navigationAction")
//        decisionHandler(.allow)
//    }
//    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
//        dprint("decidePolicyFor navigationResponse")
//        decisionHandler(.allow)
//    }
//    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        dprint("didReceive challenge completionHandler")
//        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
//    }
//    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        dprint("================ Web view did fail navigation ================")
//        handleError(error)
//        dprint(error)
//    }
//    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//        dprint("================ Web view did fail provisional navigation ================")
//        handleError(error)
//        dprint(error)
//    }
//    
//    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
//        dprint("webViewWebContentProcessDidTerminate")
//        loadFailed = true
//        webView.scrollView.reloadEmptyDataSet()
//    }
//    
//    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        dprint("createWebViewWith configuration \(configuration) for navigationAction \(navigationAction)")
//        if let url = navigationAction.request.url?.absoluteString, navigationAction.targetFrame == nil {
//            pushMostAppropriateWebVC(url: url)
//        }
//        return nil
//    }
//    
//    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        dprint("======== Web view did commit navigation ========")
//    }
//    func webViewWebContentProcessDidTerminate(webView: WKWebView) {
//        dprint("webViewWebContentProcessDidTerminate")
//    }
//    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        dprint("didFinishNavigation")
//    }
//    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
//        dprint("didReceiveServerRedirectForProvisionalNavigation")
//    }
//    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        dprint("didStartProvisionalNavigation")
//    }
    
}


