//
//  BuildingListVC.swift
//  market
//
//  Created by Busan Dynamic on 1/17/24.
//

import UIKit

class BuildingListTC: UITableViewCell {
    
    @IBOutlet weak var title_label: UILabel!
}

class BuildingListVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var building_name: [String] = []
    var building_floor: [String] = []
    var building_room: [String] = []
    
    var building_row: Int = 0
    var floor_row: Int = 0
    
    var loading: Bool = true
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    @IBOutlet weak var navi_label: UILabel!
    @IBOutlet weak var navi_lineView: UIView!
    
    @IBOutlet weak var building_tableView: UITableView!
    @IBOutlet weak var floor_tableView: UITableView!
    @IBOutlet weak var room_tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BuildingListVCdelegate = self
        /// navi
        navi_label.alpha = 0.0
        navi_lineView.alpha = 0.0
        
        ([building_tableView, floor_tableView, room_tableView] as [UITableView]).forEach { tableView in
            tableView.separatorStyle = .none
            tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
            tableView.delegate = self; tableView.dataSource = self
        }
        
        if BuildingObject.building_name.count == 0 {
            customLoadingIndicator(text: "불러오는 중...", animated: true)
            /// Building Info 요청
            requestBuildingInfo { status in
                self.customLoadingIndicator(animated: false)
                self.loadingData()
            }
        } else {
            loadingData()
        }
    }
    
    func loadingData(building: String = "", floor: String = "") {
        
        print(building, floor)
        
        var building: String = building
        var floor: String = floor
        
        customLoadingIndicator(animated: false)
        /// 데이터 삭제
        building_name.removeAll()
        building_floor.removeAll()
        building_room.removeAll()
        
        building_name = BuildingObject.building_name
        BuildingObject.building_floor.forEach { floor in
            if building == "" { building = building_name[building_row]+"/" }
            if floor.contains(building) { building_floor.append(floor.replacingOccurrences(of: building, with: "")) }
        }
        BuildingObject.building_room.forEach { room in
            if floor == "" { floor = building_name[building_row]+"/"+building_floor[floor_row]+"/" }
            if room.contains(floor) { building_room.append(room.replacingOccurrences(of: floor, with: "")) }
        }
        
        building_name.sort()
        building_floor = building_floor.sorted { if $0.contains("B") != $1.contains("B") { return $0.contains("B") }; return $0 < $1 }
        building_room.sort()
        
        ([building_tableView, floor_tableView, room_tableView] as [UITableView]).forEach { tableView in
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

extension BuildingListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == building_tableView, building_name.count > 0 {
            return building_name.count
        } else if tableView == floor_tableView, building_floor.count > 0 {
            return building_floor.count
        } else if tableView == room_tableView, building_room.count > 0 {
            return building_room.count
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuildingListTC", for: indexPath) as! BuildingListTC
        cell.layer.cornerRadius = 7.5
        
        if tableView == building_tableView {
            cell.backgroundColor = building_row == indexPath.row ? .white : .clear
            cell.title_label.font = building_row == indexPath.row ? .boldSystemFont(ofSize: 14.0) : .systemFont(ofSize: 14.0)
            cell.title_label.textColor = building_row == indexPath.row ? .black : .black.withAlphaComponent(0.3)
            cell.title_label.text = building_name[indexPath.row]
        } else if tableView == floor_tableView {
            cell.backgroundColor = floor_row == indexPath.row ? .white : .clear
            cell.title_label.font = floor_row == indexPath.row ? .boldSystemFont(ofSize: 14.0) : .systemFont(ofSize: 14.0)
            cell.title_label.textColor = floor_row == indexPath.row ? .black : .black.withAlphaComponent(0.3)
            cell.title_label.text = building_floor[indexPath.row]
            if loading { loading = !loading; loadingData(building: building_name[building_row]+"/", floor: building_name[building_row]+"/"+building_floor[floor_row]+"/") }
        } else if tableView == room_tableView {
            cell.title_label.text = building_room[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == building_tableView {
            building_row = indexPath.row; floor_row = 0; loading = true; loadingData(building: building_name[building_row]+"/")
        } else if tableView == floor_tableView {
            floor_row = indexPath.row; loading = true; tableView.reloadData()
        } else if tableView == room_tableView {
            if let delegate = SignUpStoreVCdelegate {
                delegate.buildingAddressDetail_tf.text = building_name[building_row]+"/"+building_floor[floor_row]+"/"+building_room[indexPath.row]
                delegate.buildingAddressDetail_btn.backgroundColor = .H_8CD26B
                delegate.buildingAddressDetail_btn.isSelected = true
            }
            if let delegate = ReReceiptUploadVCdelegate {
                delegate.ReEnquiryReceiptObject.summary_address = building_name[building_row]+"/"+building_floor[floor_row]+"/"+building_room[indexPath.row]
                UIView.setAnimationsEnabled(false); delegate.tableView.reloadSections(IndexSet(integer: 0), with: .none); UIView.setAnimationsEnabled(true)
            }
            navigationController?.popViewController(animated: true)
        }
    }
}
