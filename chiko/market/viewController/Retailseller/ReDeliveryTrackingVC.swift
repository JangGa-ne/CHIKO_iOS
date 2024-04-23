//
//  ReDeliveryTrackingVC.swift
//  market
//
//  Created by Busan Dynamic on 4/8/24.
//

import UIKit
import WebKit

class ReDeliveryTrackingVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var linkUrl: String = ""
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var wkWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wkWebView.scrollView.showsHorizontalScrollIndicator = false
        wkWebView.scrollView.showsVerticalScrollIndicator = false
        wkWebView.scrollView.isScrollEnabled = true
        
        if let linkUrl = URL(string: linkUrl) { wkWebView.load(URLRequest(url: linkUrl)) }
        
        wkWebView.uiDelegate = self; wkWebView.navigationDelegate = self
        wkWebView.configuration.userContentController.add(self, name: "callBackHandler")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

extension ReDeliveryTrackingVC: WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil { webView.load(navigationAction.request) }; return nil
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        alert(title: "", message: message, style: .alert, time: 1)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let dict = message.body as? [String: Any] ?? [:]
    }
}
