//
//  PaymentVC.swift
//  market
//
//  Created by Busan Dynamic on 3/7/24.
//

import UIKit
import WebKit
import os.log

class PaymentVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var cny_cash: String = ""
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var wkWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        wkWebView.configuration.preferences.javaScriptEnabled = true
        wkWebView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let htmlString = """
        <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
        <html>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

        <!-- InnoPay 결제연동 스크립트(필수) -->
        <script type="text/javascript" src="https://pg.innopay.co.kr/ipay/js/jquery-2.1.4.min.js"></script>
        <script type="text/javascript" src="https://pg.innopay.co.kr/ipay/js/innopay_overseas-2.0.js" charset="utf-8"></script>
        <script type="text/javascript">
            jQuery(document).ready(function() {
                innopay.goPay({
                    PayMethod : 'ALIPAY',
                    MID: 'testpay01m',
                    MerchantKey: 'Ma29gyAFhvv/+e4/AHpV6pISQIvSKziLIbrNoXPbRS5nfTx2DOs8OJve+NzwyoaQ8p9Uy1AN4S1I0Um5v7oNUg==',
                    GoodsName: '페이충전',
                    Amt: '\(cny_cash)',
                    BuyerName: '\(MemberObject.member_name)',
                    BuyerTel: '\(MemberObject.member_num)',
                    BuyerEmail: '\(MemberObject.member_email)',
                    ResultYN: 'Y',
                    Currency: 'CNY',
                    Moid : 'testpay01m' + getDate(),
                    ReturnURL: 'https://pg.innopay.co.kr/ipay/returnPay.jsp',
                });
            });

            /**
             * 결제결과 수신 Javascript 함수
             * ReturnURL이 없는 경우 아래 함수로 결과가 리턴됩니다 (함수명 변경불가!)
             */
            function innopay_result(data) {
                var a = JSON.stringify(data);
                // Sample
                var mid = data.MID; // 가맹점 MID
                var tid = data.TID; // 거래고유번호
                var amt = data.Amt; // 금액
                var moid = data.MOID; // 주문번호
                var authdate = data.AuthDate; // 승인일자
                var authcode = data.AuthCode; // 승인번호
                var resultcode = data.ResultCode; // 결과코드(PG)
                var resultmsg = data.ResultMsg; // 결과메세지(PG)
                var errorcode = data.ErrorCode; // 에러코드(상위기관)
                var errormsg = data.ErrorMsg; // 에러메세지(상위기관)
                var EPayCl = data.EPayCl;
                //alert("["+resultcode+"]"+resultmsg);
                alert(a);
            }

            $(function() {
                $('#CNY').attr('disabled', true);
                $('input[name="PayMethod"]').click(function() {
                    var state = $('input[name="PayMethod"]:checked').val();
                    if (state == 'OPCARD') {
                        $('#KRW,#USD').attr('disabled', false);
                        $('#CNY').attr('disabled', true);
                        $('#USD').prop('checked', true);
                    } else {
                        $('#KRW,#USD').attr('disabled', true);
                        $('#CNY').attr('disabled', false);
                        $('#CNY').prop('checked', true);
                    }
                });
            })
            
             /*
             *  DATE 형식  YYYYMMDDHHMMSS
             *  중복 MOID 방지
             */
                  function getDate() {
                      var currentdate = new Date();
                      var rst = pad(currentdate.getFullYear(), 2) + pad(
                          (currentdate.getMonth() + 1), 2 ) + pad(currentdate.getDate(), 2) + pad(currentdate.getHours(), 2) + pad(
                          currentdate.getMinutes(), 2 );
                      return rst;
                  }
                  function pad(number, length) {
                      var str = '' + number;
                      while (str.length < length) {
                          str = '0' + str;
                      }
                      return str;
                  }
        </script>

        <!-- 샘플 HTML -->
        <title>INNOPAY Electronic Payment Service</title>
        </head>
        <body>
        </body>
        </html>
        """

        // Load HTML string
        wkWebView.loadHTMLString(htmlString, baseURL: nil)
        
//        wkWebView.navigationDelegate = self
//        wkWebView.load(URLRequest(url: URL(string: "https://pg.innopay.co.kr/ipay/js/innopay_overseas-2.0.js")!))
        
//        let timestamp = String(setGMTUnixTimestamp())
//        let params: [String: Any] = [
//            "PayMethod": "WECHATPAY",                                                                                       // 결제수단(OPCARD, ALIPAY, WECHATPAY)
//            "MID": "testpay01m",                                                                                            // API아이디
//            "MerchantKey": "Ma29gyAFhvv/+e4/AHpV6pISQIvSKziLIbrNoXPbRS5nfTx2DOs8OJve+NzwyoaQ8p9Uy1AN4S1I0Um5v7oNUg==",      // API라이센스키
//            "GoodsName": "페이충전",
//            "GoodsCnt": "1",
//            "Amt": String(cny_cash),                                                                                        // 거래금액
//            "Currency": "CNY",                                                                                              // 통화코드(KRW, CNY, USD)
//            "Moid": timestamp,                                                                                              // 주문번호
//            "BuyerName": MemberObject.member_name,                                                                          // 구매자명
//            "BuyerTel": MemberObject.member_num,                                                                  // 구매자연락처
//            "BuyerEmail": MemberObject.member_email,                                                                        // 구매자이메일
//            "ResultYN": "Y",                                                                                                // 결제결과창유무
//            "ReturnURL": "https://pg.innopay.co.kr/ipay/returnPay.jsp",
//        ]
//        /// Payment 요청
//        requestPayment(params: params) { html, status in
//            print(html, status)
//            
//            self.customLoadingIndicator(animated: false)
//            
//            if html != "" {
//                self.wkWebView.loadHTMLString(html, baseURL: URL(string: requestPaymentUrl)!)
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

extension PaymentVC: WKUIDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            
        guard let targetFrame = navigationAction.targetFrame else {
            webView.load(navigationAction.request)
            return nil
        }
        
        if !targetFrame.isMainFrame {
            webView.load(navigationAction.request)
        }
        
        return nil
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("웹뷰가 페이지 로드를 시작합니다.")
        customLoadingIndicator(animated: true)
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
}
