//
//  PaymentVC.swift
//  market
//
//  Created by 장 제현 on 3/7/24.
//

/// 번역완료

import UIKit
import WebKit
import os.log

class PaymentVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var type: String = ""               // 결제타입(상품, 물류)
    var payment_type: String = ""       // 결제수단(OPCARD, ALIPAY, WECHATPAY, VBANK)
    var item_name: String = ""
    var cny_cash: String = ""
    
    @IBOutlet var labels: [UILabel]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    @IBOutlet weak var testPayment_btn: UIButton!
    
    @IBOutlet weak var WkWebView: WKWebView!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PaymentVCdelegate = self
        
        print("""
            PayMethod : '\(payment_type)',
            MID: 'buchicocom',
            MerchantKey: '8XdELC2ifRhtdusuTGnFNE/REqIuIRKBWPib6KkzTqNCUDQzflOmDpOCa/6LAfag6PLJOdCKjpALb5Sx/GFWQw==',
            GoodsName: '\(item_name)',
            Amt: '\(cny_cash)',
            BuyerName: '\(MemberObject.member_name)',
            BuyerTel: '\(MemberObject.member_num)',
            BuyerEmail: '\(MemberObject.member_email)',
            ResultYN: 'Y',
            Currency: 'CNY',
            Moid : 'buchicocom' + getDate(),
            ReturnURL: 'https://pg.innopay.co.kr/ipay/returnPay.jsp',
        """)
        
        testPayment_btn.isHidden = !(MemberObject.member_id == "receo0005")
        testPayment_btn.addTarget(self, action: #selector(testPayment_btn(_:)), for: .touchUpInside)
        
        WkWebView.uiDelegate = self
        WkWebView.navigationDelegate = self
        WkWebView.configuration.preferences.javaScriptEnabled = true
        WkWebView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
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
                    // 결제요청 함수
                    innopay.goPay({
                        //// 필수 파라미터
                        PayMethod : '\(payment_type)',
                        MID: 'buchicocom',
                        MerchantKey: '8XdELC2ifRhtdusuTGnFNE/REqIuIRKBWPib6KkzTqNCUDQzflOmDpOCa/6LAfag6PLJOdCKjpALb5Sx/GFWQw==',
                        GoodsName: '\(item_name)',
                        Amt: '\(cny_cash)',
                        BuyerName: '\(MemberObject.member_name)',
                        BuyerTel: '\(MemberObject.member_num)',
                        BuyerEmail: '\(MemberObject.member_email)',
                        ResultYN: 'Y',
                        Currency: 'CNY',
                        Moid : 'buchicocom' + getDate(),
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
                    var rst = pad(currentdate.getFullYear(), 2) + pad((currentdate.getMonth() + 1), 2 ) + pad(currentdate.getDate(), 2) + pad(currentdate.getHours(), 2) + pad(currentdate.getMinutes(), 2 );
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
        WkWebView.loadHTMLString(htmlString, baseURL: URL(string: "https://pg.innopay.co.kr/ipay/js/innopay_overseas-2.0.js") ?? nil)
    }
    
    func clearCache() {
        let websiteDataTypes: Set<String> = [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache]
        let dateFrom = Date(timeIntervalSince1970: 0)
        
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom) {
            print("Cache cleared successfully")
        }
    }
    
    @objc func testPayment_btn(_ sender: UIButton) {
        navigationController?.popViewController(animated: true, completion: {
            if self.type == "상품", let delegate = ReLiquidateVCdelegate {
                delegate.payment(status: 200)
            } else if self.type == "물류", let delegate = ReDeliveryPaymentVCdelegate {
                delegate.payment(status: 200)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

extension PaymentVC: WKUIDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            // 팝업을 허용하기 위해 새 WKWebView를 만듭니다.
            let newWebView = WKWebView(frame: self.WkWebView.bounds, configuration: configuration)
            newWebView.navigationDelegate = self
            self.WkWebView.addSubview(newWebView)
            return newWebView
        } else {
            return nil
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else { decisionHandler(.allow); return }
        print(url)
        
        if url.scheme != "http" && url.scheme != "https" {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
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
}
