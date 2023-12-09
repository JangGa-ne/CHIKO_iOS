//
//  ReGoodsOptionVC.swift
//  market
//
//  Created by 장 제현 on 11/12/23.
//

import UIKit
import PanModal

class ReGoodsOptionTC: UITableViewCell {
    
    @IBOutlet weak var optionColor_view: UIView!
    @IBOutlet weak var optionSequence_label: UILabel!
    @IBOutlet weak var optionNamePrice_label: UILabel!
    @IBOutlet weak var optionSelect_btn: UIButton!
    @IBOutlet weak var optionSoldOut_label: UILabel!
}

class ReGoodsOptionVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var GoodsObject: GoodsData = GoodsData()
    
    @IBAction func back_btn(_ sender: UIButton) { dismiss(animated: true, completion: nil) }
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = .zero }
        tableView.delegate = self; tableView.dataSource = self
    }
}

extension ReGoodsOptionVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if GoodsObject.item_option.count > 0 { return GoodsObject.item_option.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = GoodsObject.item_option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReGoodsOptionTC", for: indexPath) as! ReGoodsOptionTC
        cell.optionColor_view.backgroundColor = .init(hex: "#\(ColorArray[data.color] ?? "ffffff")")
        cell.optionSequence_label.text = "상품 \(indexPath.row+1)."
        cell.optionNamePrice_label.text = "옵션. \(data.color) + \(data.size) (+\(priceFormatter.string(from: (data.price-GoodsObject.item_sale_price) as NSNumber) ?? "0")원)\n가격. ₩ \(priceFormatter.string(from: data.price as NSNumber) ?? "0")"
        cell.optionSoldOut_label.isHidden = !data.sold_out
        cell.optionSelect_btn.tag = indexPath.row; cell.optionSelect_btn.addTarget(self, action: #selector(optionSelect_btn(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func optionSelect_btn(_ sender: UIButton) {
        
        var exist: Bool = false
        ReGoodsDetailVCdelegate?.OptionArray.forEach { data in if data.sequence == sender.tag+1 { exist = true; return } }
        if exist { customAlert(message: "이미 선택한 상품입니다.", time: 1) { self.dismiss(animated: true, completion: nil) }; return }
        if GoodsObject.item_option[sender.tag].sold_out { return }
        
        let data = GoodsObject.item_option[sender.tag]
        let optionValue = GoodsOptionData()
        optionValue.color = data.color
        optionValue.price = data.price
        optionValue.quantity = 1
        optionValue.sequence = sender.tag+1
        optionValue.size = data.size
        ReGoodsDetailVCdelegate?.OptionArray.insert(optionValue, at: 0)
        UIView.setAnimationsEnabled(false)
        ReGoodsDetailVCdelegate?.tableView.reloadSections(IndexSet(integer: 1), with: .none)
        UIView.setAnimationsEnabled(true)
        ReGoodsDetailVCdelegate?.setTotalPrice()
        dismiss(animated: true, completion: nil)
    }
}

extension ReGoodsOptionVC: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var cornerRadius: CGFloat {
        return 15
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(50+CGFloat(GoodsObject.item_option.count*110)+20+view.safeAreaInsets.bottom)
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeight
    }
}
