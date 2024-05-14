//
//  SafariVC.swift
//  market
//
//  Created by 장 제현 on 12/20/23.
//

import UIKit
import WebKit

class SafariVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var linkUrl: String = ""
    var htmlString: String = ""
    
    @IBAction func back_btn(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var WkWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WkWebView.uiDelegate = self
        WkWebView.navigationDelegate = self
        
        if linkUrl != "", let linkUrl = URL(string: linkUrl) {
            WkWebView.load(URLRequest(url: linkUrl))
        } else if htmlString != "" {
            WkWebView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

extension SafariVC: WKUIDelegate, WKNavigationDelegate {
    
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
}

