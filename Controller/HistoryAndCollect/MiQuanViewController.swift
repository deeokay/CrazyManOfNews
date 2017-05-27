//
//  MiQuanViewController.swift
//  AimiHealth
//
//  Created by ivan on 17/3/1.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import MJRefresh

class MiQuanViewController: SeleDelParentController,UITableViewDataSource,UITableViewDelegate {
    
    override var spaceMessage: String {
        return Locale.cast(str: "暂无收藏内容！")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 获得编辑通知
        NotificationCenter.default.addObserver(self, selector: #selector(MiQuanViewController.deleteSelect), name: NSNotification.Name(rawValue: "delete"), object: nil)
    }
    
    override func setupTableView() {
        super.setupTableView()
        self.contentTableView.dataSource = self
        self.contentTableView.delegate = self
        self.contentTableView.register(UINib(nibName: "MiQuanCell", bundle: nil), forCellReuseIdentifier: "XibMiQuanCell")
    }
    
    deinit {
        // 注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    // 右上角编辑按钮
    func deleteSelect() {
        AimiFunction.checkLogin(controller: self) {
            self.contentTableView.setEditing(!self.contentTableView.isEditing, animated: true)
            self.seleDelView.selectButton.isEnabled = !self.seleDelView.selectButton.isEnabled
            self.seleDelView.deleteButton.isEnabled = !self.seleDelView.deleteButton.isEnabled
        }
        
    }
    
    override func delete() {
        super.delete()
        self.showHud(in: self.view)
        // 把aid用逗号分隔改为字符串用作参数
        var aidString = String()
        for i in self.selectedArr.sorted() {
            aidString.append("\(self.dataArr[i]["aid"].intValue)")
            if self.selectedArr.count > 1 {
                aidString.append(",")
            }
        }
        print(aidString)
        let dic = ["uid": UserDefaults.standard.object(forKey: "uid"),
                   "aid": aidString,
                   "iid": "",
                   "vid": "",
                   "fid": ""]
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/delfavour", dic: dic as NSDictionary, success: { (data) in
            
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

    // MARK: - 获取网络数据
    override func loadData(page: Int) {
        // 等待数据加载完毕，开始转圈圈
        self.showHud(in: self.view)
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let dic =  ["uid":uid, "page": page] as NSDictionary
        
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/afavorite", dic: dic, success: { (data) in
            
            guard JSON.init(data: data)["error"].intValue == 0 else {
                DeeShareMenu.messageFrame(msg: NSLocalizedString("加载数据失败！", comment: ""), view: self.contentTableView)
                return
            }
//            print(JSON.init(data: data))
            // 加载成功后要停止圈圈转动
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
            self.contentTableView.reloadData()
            self.contentTableView.mj_header.endRefreshing()
            self.contentTableView.mj_footer.endRefreshing()
        }, fail: { (err) in
            // 加载失败也要停止圈圈转动
            self.hideHud()
            self.contentTableView.mj_header.endRefreshing()
            self.contentTableView.mj_footer.endRefreshing()
            self.page -= 1
            DeeShareMenu.messageFrame(msg: NSLocalizedString("连接服务器失败！", comment: ""), view: self.contentTableView)
        }) { (pro) in
            
        }
        
    }
    
    // MARK: - Table view data source
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataArr.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.contentTableView.dequeueReusableCell(withIdentifier: "XibMiQuanCell", for: indexPath) as! MiQuanCell
        // 右侧标题
        cell.collectTitleLabel.text = self.dataArr[indexPath.row]["title"].stringValue
        let urlString = self.dataArr[indexPath.row]["imgUrl"].stringValue
        let url = NSURL(string: urlString)
        // 左侧图片
        cell.collectionImageView.kf.setImage(with: url as URL?)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.contentTableView.isEditing == true {
            // 编辑模式
            self.selectedArr.append(indexPath.row)
            let cell = self.contentTableView.cellForRow(at: indexPath) as! MiQuanCell
            cell.isSelected = true
        } else {
            // 非编辑模式
            let supportStoryBoard = UIStoryboard.init(name: "Support", bundle: nil)
            let miquanVC = supportStoryBoard.instantiateViewController(withIdentifier: "MiquanDetailsController") as! MiquanDetailsController
            let model = ArticleModel()
            model.aid = self.dataArr[indexPath.row]["aid"].intValue
            model.title = self.dataArr[indexPath.row]["title"].stringValue
            model.link = self.dataArr[indexPath.row]["link"].stringValue
            model.audioUrl = self.dataArr[indexPath.row]["audioUrl"].stringValue
            if (model.audioUrl as NSString).length > 0 {
                model.article_type = 1
            } else {
                model.article_type = 0
            }
            model.imgUrl = self.dataArr[indexPath.row]["imgUrl"].stringValue
            model.bgUrl = self.dataArr[indexPath.row]["bgUrl"].stringValue
            model.bgAvatar = self.dataArr[indexPath.row]["bgAvatar"].stringValue
            miquanVC.model = model
            print(miquanVC.model.mj_keyValues())
            self.navigationController?.pushViewController(miquanVC, animated: true)
        }
    }
    
    // 取消选中
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // 编辑模式
        if self.contentTableView.isEditing == true {
            let cell = self.contentTableView.cellForRow(at: indexPath) as! MiQuanCell
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
    
    // 设置全选模式
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        return UITableViewCellEditingStyle.init(rawValue: UITableViewCellEditingStyle.delete.rawValue | UITableViewCellEditingStyle.insert.rawValue)!
    }

}
