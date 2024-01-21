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
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var building_tableView: UITableView!
    @IBOutlet weak var floor_tableView: UITableView!
    @IBOutlet weak var class_tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if BuildingObject.building_name.count > 0 {
            click(name: BuildingObject.building_name[0])
        }
        
        ([building_tableView, floor_tableView, class_tableView] as [UITableView]).forEach { tableView in
            
            tableView.separatorStyle = .none
            tableView.contentInset = .zero
            tableView.delegate = self; tableView.dataSource = self
        }
    }
    
    func click(name: String) {
        
        building_name = BuildingObject.building_name
        BuildingObject.building_floor.forEach { floor in
            if floor.contains(name) { building_room.append(floor.replacingOccurrences(of: "\(name)/", with: "")) }
            BuildingObject.building_room.forEach { room in
                if room.contains(floor) { building_room.append(room.replacingOccurrences(of: "\(floor)/", with: "")) }
            }
        }
        
        building_name.sort()
        building_floor.sort()
        building_room.sort()
        
        ([building_tableView, floor_tableView, class_tableView] as [UITableView]).forEach { tableView in
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
        if tableView == building_tableView, BuildingObject.building_name.count > 0 {
            return BuildingObject.building_name.count
        } else if tableView == floor_tableView, building_floor.count > 0 {
            return building_floor.count
        } else if tableView == class_tableView, building_room.count > 0 {
            return building_room.count
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuildingListTC", for: indexPath) as! BuildingListTC
        cell.title_label.padding(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        
        if tableView == building_tableView {
            cell.title_label.text = building_name[indexPath.row]
        } else if tableView == floor_tableView {
            cell.title_label.text = building_name[indexPath.row]
        } else if tableView == class_tableView {
            cell.title_label.text = building_name[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == building_tableView {
            
        } else if tableView == floor_tableView {
            
        } else if tableView == class_tableView {
            
        }
    }
}
