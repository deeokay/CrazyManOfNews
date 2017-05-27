//
//  MiLiaoViewController.swift
//  Aimi-V1.1
//
//  Created by Ivanlee on 2017/4/6.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import MJRefresh

class MiLiaoViewController: HideTabbarController, UITableViewDelegate, UITableViewDataSource {
    
    // 数据存储
    var dataArr = Array<JSON>()
    // 已选择存储
    var selectedArr: [Int] = []
    
    var messageLabel: UILabel {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: UIwidth, height: 80))
        label.textAlignment = .center
        label.center = self.miliaoTableView.center
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 25)
        label.text = NSLocalizedString("暂无收藏内容！", comment: "")
        return label
    }
    var totalPage: Int = 1
    var page: Int = 1
    var footer: MJRefreshAutoFooter {
        let ft = MJRefreshAutoFooter {
            if self.page < self.totalPage {
                self.page += 1
                self.loadData(page: self.page)
            } else {
                DeeShareMenu.messageFrame(msg: "已经到底啦！", view: self.miliaoTableView)
            }
        }
        return ft!
    }
    var header: MJRefreshNormalHeader {
        let hd = MJRefreshNormalHeader {
            self.loadData(page: 1)
        }
        return hd!
    }
    @IBOutlet weak var miliaoTableView: UITableView!
    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var checkBoxImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configTableView()
        self.loadData(page: 1)
        // 获得编辑通知
        NotificationCenter.default.addObserver(self, selector: #selector(MiLiaoViewController.deleteSelect), name: NSNotification.Name(rawValue: "delete"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.miliaoTableView.isEditing = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    deinit {
        // 注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configTableView() {
        self.miliaoTableView.register(UINib(nibName: "MiLiaoCell", bundle: nil), forCellReuseIdentifier: "MiLiaoCell")
        self.miliaoTableView.delegate = self
        self.miliaoTableView.dataSource = self
        self.miliaoTableView.tableFooterView = UIView()
        self.miliaoTableView.mj_header = self.header
        self.miliaoTableView.mj_footer = self.footer
    }
    
    // 右上角编辑按钮
    func deleteSelect() {
        AimiFunction.checkLogin(controller: self) {
            self.miliaoTableView.setEditing(!self.miliaoTableView.isEditing, animated: true)
            self.selectedButton.isEnabled = !self.selectedButton.isEnabled
            self.deleteButton.isEnabled = !self.deleteButton.isEnabled
        }
        
    }
    // 左下角全选
    @IBAction func selectAction(_ sender: UIButton) {
        self.selectedButton.isSelected = !self.selectedButton.isSelected
        if self.selectedButton.isSelected == false {
            self.checkBoxImageView.image = UIImage.init(named: "用户协议2")
            // 取消全选
            self.deSelectedAll()
        } else {
            self.checkBoxImageView.image = UIImage.init(named: "用户协议1")
            // 全选
            self.selectAll()
        }
    }
    
    // 全选
    private func selectAll() {
        //先清空
        self.selectedArr.removeAll()
        for i in 0..<self.dataArr.count {
            // 再逐个添加所有
            self.selectedArr.append(i)
            let indexPath = NSIndexPath.init(row: i, section: 0)
            let cell = self.miliaoTableView.cellForRow(at: indexPath as IndexPath) as! MiLiaoCell
            cell.isSelected = true
        }
        
    }
    
    // 取消全选
    private func deSelectedAll() {
        // 清空选择数组
        self.selectedArr.removeAll()
        for i in 0..<self.dataArr.count {
            
            let indexPath = NSIndexPath.init(row: i, section: 0)
            let cell = self.miliaoTableView.cellForRow(at: indexPath as IndexPath) as! MiLiaoCell
            cell.isSelected = false
        }
    }

    
    // 右下角删除
    @IBAction func deleteAction(_ sender: UIButton) {
        self.miliaoTableView.setEditing(false, animated: true)
        self.selectedButton.isEnabled = false
        self.selectedButton.isSelected = false
        self.deleteButton.isEnabled = false
        self.showHud(in: self.view)
        
        var fidString = String()
        for i in self.selectedArr.sorted() {
            fidString.append("\(self.dataArr[i]["fid"].intValue)")
            if self.selectedArr.count > 1 {
                fidString.append(",")
            }
        }
        let dic = ["uid": UserDefaults.standard.object(forKey: "uid"),
                   "aid": "",
                   "iid": "",
                   "vid": "",
                   "fid": fidString]
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/delfavour", dic: dic as NSDictionary, success: { (data) in
            
            for index in self.selectedArr.sorted().reversed() {
                self.dataArr.remove(at: index)
            }
            self.selectedArr.removeAll()
            self.miliaoTableView.reloadData()
            self.hideHud()
        }, fail: { (err) in
            self.hideHud()
        }, Pro: { (pro) in
            
        })
    }
    
    // MARK: - DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MiLiaoCell", for: indexPath) as! MiLiaoCell
        cell.avatarImageView.kf.setImage(with: URL.init(string: self.dataArr[indexPath.row]["writer_avatar"].stringValue))
        cell.timeLabel.text = self.dataArr[indexPath.row]["create_time"].stringValue
        cell.contentLabel.text = self.dataArr[indexPath.row]["content"].stringValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    // 设置全选模式
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        return UITableViewCellEditingStyle.init(rawValue: UITableViewCellEditingStyle.delete.rawValue | UITableViewCellEditingStyle.insert.rawValue)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.miliaoTableView.isEditing == true {
            // 编辑模式
            self.selectedArr.append(indexPath.row)
            let cell = self.miliaoTableView.cellForRow(at: indexPath) as! MiLiaoCell
            cell.isSelected = true
        } else {
            // 非编辑模式
            let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "MiTalkDetails") as! MiTalkDetails
            let model = MiTalkModel()
            model.content = self.dataArr[indexPath.row]["content"].stringValue
            model.fid = self.dataArr[indexPath.row]["fid"].intValue
            model.avatar = self.dataArr[indexPath.row]["writer_avatar"].stringValue
            model.publishtime = self.dataArr[indexPath.row]["create_time"].stringValue as! NSMutableString
            model.username = self.dataArr[indexPath.row]["username"].stringValue
            vc.model = model
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // 取消选中
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // 编辑模式
        if self.miliaoTableView.isEditing == true {
            let cell = self.miliaoTableView.cellForRow(at: indexPath) as! MiLiaoCell
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
    
    // MARK: - 获取数据
    
    fileprivate func loadData(page: Int) {
        // 等待数据加载完毕，开始转圈圈
        self.showHud(in: self.view)
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let dic =  ["uid":uid, "page": page] as NSDictionary
        
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/ffavorite_list", dic: dic, success: { (data) in
            
            guard JSON.init(data: data)["error"].intValue == 0 else {
                print("error = 0")
                DeeShareMenu.messageFrame(msg: NSLocalizedString("加载数据失败！", comment: ""), view: self.miliaoTableView)
                return
            }
            // 加载成功后要停止圈圈转动
//            print(JSON.init(data: data))
            self.hideHud()
            self.page = JSON.init(data: data)["current_page"].intValue
            self.totalPage = JSON.init(data: data)["lastpage"].intValue
            if page == 1 {
                self.dataArr = JSON.init(data: data)["data"].arrayValue
            } else {
                self.dataArr += JSON.init(data: data)["data"].arrayValue
            }
            if self.dataArr.count == 0 {
                self.view.addSubview(self.messageLabel)
            }
            // 重载列表
            self.miliaoTableView.reloadData()
            self.miliaoTableView.mj_header.endRefreshing()
            self.miliaoTableView.mj_footer.endRefreshing()
        }, fail: { (err) in
            // 加载失败也要停止圈圈转动
            self.hideHud()
            self.miliaoTableView.mj_header.endRefreshing()
            self.miliaoTableView.mj_footer.endRefreshing()
            self.page -= 1
            DeeShareMenu.messageFrame(msg: NSLocalizedString("连接服务器失败！", comment: ""), view: self.miliaoTableView)
        }) { (pro) in
            
        }
    }

}

