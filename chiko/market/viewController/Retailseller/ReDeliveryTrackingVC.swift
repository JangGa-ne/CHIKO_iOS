//
//  ReDeliveryTrackingVC.swift
//  market
//
//  Created by 장 제현 on 4/8/24.
//

/// 번역완료

import UIKit
import WebKit

class ReDeliveryTrackingVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var linkUrl: String = ""
    
    @IBOutlet var labels: [UILabel]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var WkWebView: WKWebView!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WkWebView.scrollView.showsHorizontalScrollIndicator = false
        WkWebView.scrollView.showsVerticalScrollIndicator = false
        WkWebView.scrollView.isScrollEnabled = true
        
        if let linkUrl = URL(string: linkUrl) { WkWebView.load(URLRequest(url: linkUrl)) }
        
        WkWebView.uiDelegate = self; WkWebView.navigationDelegate = self
        WkWebView.configuration.preferences.javaScriptEnabled = true
        WkWebView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        WkWebView.configuration.userContentController = WKUserContentController()
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
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("웹뷰가 페이지 로드를 시작합니다.")
        customLoadingIndicator(text: "불러오는 중...", animated: true)
    }

    // 웹뷰가 페이지 로드를 완료했을 때 호출되는 메서드
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("웹뷰가 페이지 로드를 완료했습니다.")
        customLoadingIndicator(animated: false)
    }

    // 웹뷰가 페이지 로드를 실패했을 때 호출되는 메서드
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("웹뷰가 페이지 로드를 실패했습니다. 오류: \(error)")
        customLoadingIndicator(animated: false)
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // 중복적으로 새로고침이 일어나지 않도록 처리 필요.
        webView.reload()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        alert(title: "", message: message, style: .alert, time: 1)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let dict = message.body as? [String: Any] ?? [:]
    }
}
