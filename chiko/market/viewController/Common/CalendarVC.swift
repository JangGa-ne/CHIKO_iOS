//
//  CalendarVC.swift
//  market
//
//  Created by 장 제현 on 1/31/24.
//

import UIKit
import CVCalendar
import PanModal

class CalendarVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    var WhOrderBatchVCdelegate: WhOrderBatchVC? = nil
    var WhInventoryTCdelegate: WhInventoryTC? = nil
    var WhNotDeliveryAddVCdelegate: WhNotDeliveryAddVC? = nil
    var WhNotDeliveryAddTCdelegate: WhNotDeliveryAddTC? = nil
    
    var start_date: String = ""
    var present_date: String = ""
    /// 미송상품 등록
    var indexpath_row: Int = 0
    var present_btn: UIButton = UIButton()
    
    @IBOutlet weak var alert_v: UIView!
    @IBOutlet weak var yearMonth_label: UILabel!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    @IBOutlet weak var choice_btn: UIButton!
    @IBAction func back_btn(_ sender: UIButton) { dismiss(animated: true, completion: nil) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CalendarVCdelegate = self
        // init
        alert_v.layer.cornerRadius = device_radius
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        yearMonth_label.text = dateFormatter.string(from: Date())
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yy-MM-dd"
        if present_date == "" { present_date = dateFormatter2.string(from: Date()).replacingOccurrences(of: "-", with: ".") }
        calendarView.presentedDate = CVDate(date: dateFormatter2.date(from: present_date.replacingOccurrences(of: ".", with: "-")) ?? Date())

        calendarView.calendarAppearanceDelegate = self
        calendarView.calendarDelegate = self
        calendarView.contentController.refreshPresentedMonth()
        
        choice_btn.addTarget(self, action: #selector(choice_btn(_:)), for: .touchUpInside)
    }
    
    @objc func choice_btn(_ sender: UIButton) {
        
        var total_price: Int = 0
        
        if let delegate = WhOrderBatchVCdelegate {
            
            delegate.date_btn.setTitle(present_date, for: .normal)
            /// 데이터 삭제
            delegate.WhOrderArray.removeAll()
            delegate.WhNotDeliveryArray.removeAll()
            /// 오늘의주문
            delegate.WhOrderArray_all.filter { data in
                return data.order_date.contains(present_date.replacingOccurrences(of: ".", with: ""))
            }.forEach { data in
                data.item_option.forEach { data in total_price += (data.price*data.quantity) }
                /// 데이터 추가
                delegate.WhOrderArray.append(data)
            }
            /// 미송상품
            delegate.WhNotDeliveryArray_all.filter { data in
                return data.order_date.contains(present_date.replacingOccurrences(of: ".", with: ""))
            }.forEach { data in
                /// 데이터 추가
                delegate.WhNotDeliveryArray.append(data)
            }
            
            delegate.totalPrice_label.text = "₩\(priceFormatter.string(from: total_price as NSNumber) ?? "0")"
            
            if delegate.WhOrderArray.count > 0 {
                delegate.problemAlert(view: delegate.tableView)
            } else {
                delegate.problemAlert(view: delegate.tableView, type: "nodata")
            }
            delegate.tableView.reloadData()
        }
        
        if let delegate = WhInventoryTCdelegate {
            
            if Int(start_date.replacingOccurrences(of: ".", with: "")) ?? 0 >= Int(present_date.replacingOccurrences(of: ".", with: "")) ?? 0 {
                customAlert(message: "금일 보다 선택한 날짜가 같거나 작을 수 없습니다.", time: 2); return
            } else {
                delegate.InventoryObject.item_option[indexpath_row].date = present_date
                delegate.register()
            }
        }
        
        if let VCdelegate = WhNotDeliveryAddVCdelegate, let TCdelegate = WhNotDeliveryAddTCdelegate {
            
            if Int(start_date.replacingOccurrences(of: ".", with: "")) ?? 0 >= Int(present_date.replacingOccurrences(of: ".", with: "")) ?? 0 {
                customAlert(message: "등록된 날짜 보다 선택한 날짜가 같거나 작을 수 없습니다.", time: 2); return
            } else {
                VCdelegate.WhNotDeliveryArray_new[TCdelegate.indexpath_row].item_option[indexpath_row].not_delivery_memo = present_date
                present_btn.setTitle(present_date, for: .normal)
                present_btn.setTitleColor(.black, for: .normal)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
    }
}

extension CalendarVC: CVCalendarViewDelegate, CVCalendarViewAppearanceDelegate {
    
    func presentationMode() -> CVCalendar.CalendarMode {
        return .monthView
    }
    
    func firstWeekday() -> CVCalendar.Weekday {
        return .sunday
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        yearMonth_label.text = dateFormatter.string(from: date.convertedDate() ?? Date())
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yy.MM.dd"
        present_date = dateFormatter2.string(from: date.convertedDate() ?? Date())
    }
    
    func dayLabelWeekdayInTextColor() -> UIColor {
        return .black
    }
    
    func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor {
        return .H_8CD26B.withAlphaComponent(0.3)
    }
    func dayLabelPresentWeekdaySelectedTextColor() -> UIColor {
        return .H_8CD26B
    }
    func dayLabelPresentWeekdayTextColor() -> UIColor {
        return .H_8CD26B
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return .H_8CD26B
    }
    
    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        
        if let delegate = WhOrderBatchVCdelegate {
            for data in delegate.WhOrderArray_all {
                let year = Int(data.order_date.prefix(4))
                let month = Int(data.order_date.prefix(6).suffix(2))
                let day = Int(data.order_date.suffix(2))
                if !dayView.isHidden && dayView.date != nil, (dayView.date.year == year) && (dayView.date.month == month) && (dayView.date.day == day) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 15
    }
    
    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        return [.systemRed]
    }
    
    func dotMarker(moveOffsetOnDayView dayView: DayView) -> CGFloat {
        return 15
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: DayView) -> Bool {
        return false
    }
}

extension CalendarVC: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var showDragIndicator: Bool {
        return false
    }
}
