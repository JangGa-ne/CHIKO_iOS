//
//  s_vcDelegate.swift
//  market
//
//  Created by 장 제현 on 2023/10/16.
//

import UIKit
    
var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
/// Common
weak var SplashVCdelegate: SplashVC? = nil
weak var SignInVCdelegate: SignInVC? = nil
weak var ChoiceStoreVCdelegate: ChoiceStoreVC? = nil
weak var SearchStoreVCdelegate: SearchStoreVC? = nil
weak var SignUpMemberVCdelegate: SignUpMemberVC? = nil
weak var SignUpStoreVCdelegate: SignUpStoreVC? = nil
weak var BuildingListVCdelegate: BuildingListVC? = nil
weak var BankListVCdelegate: BankListVC? = nil
weak var AccountVCdelegate: AccountVC? = nil
weak var TagVCdelegate: TagVC? = nil
weak var MPayVCdelegate: MPayVC? = nil
weak var CalendarVCdelegate: CalendarVC? = nil
weak var PaymentVCdelegate: PaymentVC? = nil
weak var ScrapVCdelegate: ScrapVC? = nil
weak var NoticeVCdelegate: NoticeVC? = nil
// Retailseller
weak var ReMainTBCdelegate: ReMainTBC? = nil
weak var ReHomeVCdelegate: ReHomeVC? = nil
weak var ReGoodsVCdelegate: ReGoodsVC? = nil
weak var ReGoodsFilterVCdelegate: ReGoodsFilterVC? = nil
weak var ReGoodsDetailVCdelegate: ReGoodsDetailVC? = nil
weak var ReChatbotVCdelegate: ReChatbotVC? = nil
weak var ReMyPageVCdelegate: ReMyPageVC? = nil
weak var ReLiquidateVCdelegate: ReLiquidateVC? = nil
weak var ReOrderVCdelegate: ReOrderVC? = nil
weak var ReOrderDetailVCdelegate: ReOrderDetailVC? = nil
weak var ReDeliveryPaymentVCdelegate: ReDeliveryPaymentVC? = nil
weak var ReBasketVCdelegate: ReBasketVC? = nil
weak var ReStoreVisitVCdelegate: ReStoreVisitVC? = nil
weak var ReDeliveryVCdelegate: ReDeliveryVC? = nil
weak var ReEnquiryReceiptVCdelegate: ReEnquiryReceiptVC? = nil
weak var ReEnquiryReceiptDetailVCdelegate: ReEnquiryReceiptDetailVC? = nil
weak var ReReceiptUploadVCdelegate: ReReceiptUploadVC? = nil
weak var ReReceiptUploadTCdelegate: ReReceiptUploadTC? = nil
/// Wholesales
weak var WhHomeVCdelegate: WhHomeVC? = nil
weak var WhMyPageVCdelegate: WhMyPageVC? = nil
weak var WhGoodsVCdelegate: WhGoodsVC? = nil
weak var WhGoodsUploadVCdelegate: WhGoodsUploadVC? = nil
weak var WhGoodsDetailVCdelegate: WhGoodsDetailVC? = nil
weak var WhGoodsTop30VCdelegate: WhGoodsTop30VC? = nil
weak var WhOrderBatchVCdelegate: WhOrderBatchVC? = nil
weak var WhNotDeliveryAddVCdelegate: WhNotDeliveryAddVC? = nil
weak var WhNotDeliveryAddTCdelegate: WhNotDeliveryAddTC? = nil
weak var WhChatVCdelegate: WhChatVC? = nil
