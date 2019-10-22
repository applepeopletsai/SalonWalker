//
//  WebViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/5/14.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: BaseViewController {

    @IBOutlet private weak var webBaseView: UIView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!
    
    private var progressView = UIProgressView()
    private var webView = WKWebView()
    private var urlString: String?
    private var seArticlesId: Int?
    private var maArticleId: Int?
    private var articleContentModel: ArticleContentModel?
    
    private var showShareButton = false
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWebView()
        self.setupProgressView()
        self.addObser()
        self.setupUI()
    }
    
    deinit {
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView.removeObserver(self, forKeyPath: "title")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadWebView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.webView.frame = self.webBaseView.bounds
        self.progressView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 1.0)
    }
    
    // MARK: Method
    override func networkDidRecover() {
        loadWebView()
    }
    
    func setupWebVCWith(url: String? = nil, showShareButton: Bool = false) {
        self.urlString = url
        self.showShareButton = showShareButton
    }
    
    // 精選文章
    func setupWebVCWith(seArticlesId: Int? = nil, maArticleId: Int? = nil, showShareButton: Bool = true) {
        self.seArticlesId = seArticlesId
        self.maArticleId = maArticleId
        self.showShareButton = showShareButton
    }
    
    func reloadWebViewWith(seArticlesId: Int? = nil, maArticleId: Int? = nil) {
        self.seArticlesId = seArticlesId
        self.maArticleId = maArticleId
        self.apiFashionArticleContent()
    }
    
    private func addObser() {
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        self.webView.addObserver(self, forKeyPath: "title", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    private func setupUI() {
        self.shareButton.isHidden = !showShareButton
    }
    
    private func setupWebView() {
        self.webBaseView.insertSubview(webView, at: 0)
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
    }
    
    private func setupProgressView() {
        self.webView.addSubview(progressView)
        self.progressView.progress = 0.0
        self.progressView.tintColor = color_7AFEC6
    }
    
    private func loadWebView() {
        if let urlString = urlString, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            self.webView.load(request)
        } else {
            apiFashionArticleContent()
        }
    }
    
    private func loadWebViewByHtmlString(_ htmlString: String) {
        self.webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    private func configureHtmlStringWith(model: ArticleContentModel) {
        self.titleLabel.text = model.title
        let time = model.startTime.transferToDate(dateFormat: "yyyy-MM-dd HH:mm:ss")
        let bodyString = "</br></br><a style=\"color:#303538;font-size:44pt;font-weight:bold\">\(model.title)</a></br></br><a style=\"color:#2F10A0;font-size:28pt\">\(time.transferToString(dateFormat: "yyyy/MM/dd"))</a><div style=\"color:#303538;font-size:28pt\">\(model.redactor ?? "")</div></br></br><img alt=\"\" src=\(model.imgUrl) style=\"width:100%;\"></br></br><div style=\"color:#303538;font-size:30pt\">\(model.content ?? "")</div>"
        let htmlString = "<html><body style=\"margin-left:20;margin-right:20;\">\(bodyString)</body></html>"
        
        loadWebViewByHtmlString(htmlString)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress" {
            self.progressView.alpha = 1.0
            self.progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
            
            if self.webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                    self?.progressView.alpha = 0.0
                }, completion: { [weak self] (finish) in
                    self?.progressView.progress = 0.0
                })
            }
        }
        
        if keyPath == "title" {
            self.titleLabel.text = self.webView.title
        }
    }

    // MARK: Event Handler
    @IBAction private func shareButtonPress(_ sender: UIButton) {
        BranchManager.createDeepLinkUrl(seArticlesId: seArticlesId, maArticleId: maArticleId, title: articleContentModel?.title, success: { [weak self] (url) in
            let content = "\(self?.articleContentModel?.title ?? "")\n\n\(url)"
            SystemManager.goingToShareInfoAbout(text: content)
        }, failure: { error in
            SystemManager.showErrorMessageBanner(title: error?.localizedDescription ?? LocalizedString("Lang_GE_010"), body: "")
        })
    }
    
    // MARK: API
    private func apiFashionArticleContent() {
        if seArticlesId == nil && maArticleId == nil { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            HomeManager.apiFashionArticleContent(seArticlesId: seArticlesId, maArticleId: maArticleId, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    if let data = model?.data {
                        self.articleContentModel = data
                        self.hideLoading()
                        self.configureHtmlStringWith(model: data)
                    } else {
                        SystemManager.showErrorAlert()
                    }
                } else {
                    self.endLoadingWith(model: model)
                }
                
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityIndicatorView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicatorView.stopAnimating()
    }
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        print("decidePolicyFor navigationAction url:\(navigationAction.request.url?.absoluteString ?? "")")
//        decisionHandler(.allow)
//    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("decidePolicyFor navigationResponse url:\(navigationResponse.response.url?.absoluteString ?? "")")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicatorView.stopAnimating()
        if error._code == NSURLErrorCancelled { return }
        SystemManager.showAlertWith(alertTitle: error.localizedDescription, alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        })
    }
}

extension WebViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        SystemManager.showAlertWith(alertTitle: message, alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: completionHandler)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        SystemManager.showTwoButtonAlertWith(alertTitle: message, alertMessage: nil, leftButtonTitle: LocalizedString("Lang_GE_060"), rightButtonTitle: LocalizedString("Lang_GE_056"), leftHandler: {
            completionHandler(false)
        }, rightHandler: {
            completionHandler(true)
        })
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        SystemManager.showTextFieldAlertWith(title: prompt, message: defaultText, buttonTitle: LocalizedString("Lang_GE_056"), handler: { (string) in
            completionHandler(string)
        })
    }
}


