//
//  ReDeliveryTrackingVC.swift
//  market
//
//  Created by 장 제현 on 4/8/24.
//

import UIKit
import WebKit

class ReDeliveryTrackingVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var linkUrl: String = ""
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var WkWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WkWebView.scrollView.showsHorizontalScrollIndicator = false
        WkWebView.scrollView.showsVerticalScrollIndicator = false
        WkWebView.scrollView.isScrollEnabled = true
        
        if let linkUrl = URL(string: linkUrl) { WkWebView.load(URLRequest(url: linkUrl)) }
        
        WkWebView.uiDelegate = self; WkWebView.navigationDelegate = self
        WkWebView.configuration.userContentController.add(self, name: "callBackHandler")
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
