//
//  SeleDelParentController.swift
//  Aimi-V1.1
//
//  Created by Ivanlee on 2017/5/3.
//  Copyright © 2017年 Cupiday. All rights reserved.
//  所有的具有全选、删除功能的列表的父类。

import UIKit
import SwiftyJSON
import Kingfisher
import MJRefresh
import SnapKit

class SeleDelParentController: HideTabbarController {

    // 数据存储
    var dataArr = Array<JSON>()
    // 已选择存储
    var selectedArr: [Int] = []
    
    var spaceMessage: String {
        return Locale.cast(str: "内容为空！")
    }
    
    var messageLabel: UILabel {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: UIwidth, height: 80))
        label.textAlignment = .center
        label.center = self.contentTableView.center
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 25)
        label.text = Locale.cast(str: spaceMessage)
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
                DeeShareMenu.messageFrame(msg: Locale.cast(str: "已经到底啦！"), view: self.contentTableView)
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
    
    var contentTableView: UITableView!
    var seleDelView: SeleDelView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupBottomBar()
        self.loadData(page: 1)
    }
    
    func setupTableView() {
        self.contentTableView = UITableView.init()
        self.view.addSubview(self.contentTableView)
        self.contentTableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsets.init(top: 96, left: 0, bottom: 44, right: 0))
        }
        self.contentTableView.tableFooterView = UIView()
        self.contentTableView.mj_header = self.header
        self.contentTableView.mj_footer = self.footer
    }
    
    func setupBottomBar() {
        self.seleDelView = Bundle.main.loadNibNamed("SeleDelView", owner: self, options: nil)?.first as! SeleDelView
        self.view.addSubview(self.seleDelView)
        self.seleDelView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(44)
        }
        self.seleDelView.selectHandle = {
            if self.seleDelView.selectButton.isSelected == false {
                self.deSelectedAll()
            } else {
                self.selectAll()
            }
        }
        self.seleDelView.deleteHandle = {
            self.contentTableView.setEditing(false, animated: true)
            self.delete()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.contentTableView.isEditing = false
    }

    // 全选
    func selectAll() {
        //先清空
        self.selectedArr.removeAll()
        for i in 0..<self.dataArr.count {
            // 再逐个添加所有
            self.selectedArr.append(i)
            let indexPath = NSIndexPath.init(row: i, section: 0)
            let cell = self.contentTableView.cellForRow(at: indexPath as IndexPath)!
            cell.isSelected = true
        }
    }
    
    // 取消全选
    func deSelectedAll() {
        // 清空选择数组
        self.selectedArr.removeAll()
        for i in 0..<self.dataArr.count {
            
            let indexPath = NSIndexPath.init(row: i, section: 0)
            let cell = self.contentTableView.cellForRow(at: indexPath as IndexPath)!
            cell.isSelected = false
        }
    }
    
    func delete() {
        self.seleDelView.selectButton.isSelected = false
    }

    func loadData(page: Int) {
        
    }
}
