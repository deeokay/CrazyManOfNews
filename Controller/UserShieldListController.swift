//
//  UserShieldListController.swift
//  Aimi-V1.1
//
//  Created by Ivanlee on 2017/4/6.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import MJRefresh

class UserShieldListController: SeleDelParentController, UITableViewDelegate, UITableViewDataSource {
    
    override var spaceMessage: String {
        return Locale.cast(str: "暂无黑名单用户！")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 获得删除通知
        NotificationCenter.default.addObserver(self, selector: #selector(UserShieldListController.deleteSelected), name: NSNotification.Name(rawValue: "shieldDelete"), object: nil)
    }
    
    override func setupTableView() {
        super.setupTableView()
        self.contentTableView.allowsSelection = false
        self.contentTableView.allowsSelectionDuringEditing = false
        self.contentTableView.dataSource = self
        self.contentTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    deinit {
        // 注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    func deleteSelected() {
        AimiFunction.checkLogin(controller: self) {
            self.contentTableView.setEditing(!self.contentTableView.isEditing, animated: true)
            self.seleDelView.selectButton.isEnabled = !self.seleDelView.selectButton.isEnabled
            self.seleDelView.deleteButton.isEnabled = !self.seleDelView.deleteButton.isEnabled
        }
    }
    
    override func delete() {
        super.delete()
        self.showHud(in: self.view)
        var sidString = String()
        for i in self.selectedArr.sorted() {
            sidString.append("\(self.dataArr[i]["id"].intValue)")
            if self.selectedArr.count > 1 {
                sidString.append(",")
            }
        }
        let dict = ["id": sidString]
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/del_shield", dic: dict as NSDictionary, success: { (data) in
            
            for index in self.selectedArr.sorted().reversed() {
                self.dataArr.remove(at: index)
            }
            self.selectedArr.removeAll()
            self.contentTableView.reloadData()
            self.hideHud()
        }, fail: { (err) in
            self.hideHud()
        }, Pro: { (pro) in
            
        })
    }
    
    // MARK: - Delegate&DateSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init()
        cell.imageView?.kf.setImage(with: URL.init(string: self.dataArr[indexPath.row]["avatar"].stringValue), placeholder: UIImage.init(named: "屏蔽用户"))
        cell.textLabel?.text = self.dataArr[indexPath.row]["username"].stringValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.contentTableView.isEditing == true {
            self.selectedArr.append(indexPath.row)
            let cell = self.contentTableView.cellForRow(at: indexPath as IndexPath)!
            cell.isSelected = true
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if self.contentTableView.isEditing == true {
            let cell = self.contentTableView.cellForRow(at: indexPath as IndexPath)!
            cell.isSelected = false
            
            var i = 0
            for index in self.selectedArr {
                
                if index == indexPath.row {
                    self.selectedArr.remove(at: i)
                }
                i += 1
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.init(rawValue: UITableViewCellEditingStyle.delete.rawValue | UITableViewCellEditingStyle.insert.rawValue)!
    }
    
    override func loadData(page: Int) {
        super.loadData(page: page)
        // 等待数据加载完毕，开始转圈圈
        self.showHud(in: self.view)
        
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let dic =  ["uid":uid, "page": page] as NSDictionary
        
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/shield_user", dic: dic, success: { (data) in
            
            guard JSON.init(data: data)["error"].intValue == 0 else {
                print("error = 0")
                DeeShareMenu.messageFrame(msg: Locale.cast(str: "加载数据失败！"), view: self.contentTableView)
                return
            }
            // 加载成功后要停止圈圈转动
            self.hideHud()
            if page == 1 {
                self.dataArr = JSON.init(data: data)["body"].arrayValue
            } else {
                self.dataArr += JSON.init(data: data)["body"].arrayValue
            }
            if self.dataArr.count == 0 {
                self.view.addSubview(self.messageLabel)
            }
            // 重载列表
            self.contentTableView.reloadData()
            self.contentTableView.mj_header.endRefreshing()
            self.contentTableView.mj_footer.endRefreshing()
        }, fail: { (err) in
            // 加载失败也要停止圈圈转动
            self.hideHud()
            self.contentTableView.mj_header.endRefreshing()
            self.contentTableView.mj_footer.endRefreshing()
            self.page -= 1
            DeeShareMenu.messageFrame(msg: Locale.cast(str: "连接服务器失败！"), view: self.contentTableView)
        }) { (pro) in
            
        }
    }
}
