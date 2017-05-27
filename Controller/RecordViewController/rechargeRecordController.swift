//
//  rechargeRecordController.swift
//  AimiHealth
//
//  Created by IvanLee on 2017/3/8.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//  充值记录界面

import UIKit
import SwiftyJSON
import AFNetworking

class rechargeRecordController: HideTabbarController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var rechargeRecordTableView: UITableView!
    

    var dataArray = Array<JSON>()
    
    var messageLabel: UILabel {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: UIwidth, height: 80))
        label.textAlignment = .center
        label.center = self.view.center
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 25)
        label.text = NSLocalizedString("暂无充值记录", comment: "")
        return label
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("充值记录", comment: "")
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: " ", style: .plain, target: self, action: nil)
        self.rechargeRecordTableView.register(UINib.init(nibName: "RechargeRecordCell", bundle: nil), forCellReuseIdentifier: "RechargeRecord")
        self.rechargeRecordTableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("充值", comment: ""), style: .done, target: self, action: #selector(self.recharge))
        
        self.loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - DataSouce & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RechargeRecord", for: indexPath) as! RechargeRecordCell
        cell.dateLabel.text = self.dataArray[indexPath.row]["create_time"].stringValue
        cell.moneyLabel.text = "\(self.dataArray[indexPath.row]["num"].intValue)(元)"
        cell.miCoinLabel.text = "\(self.dataArray[indexPath.row]["integral"].intValue)(米币)"
        cell.rechargeWayLabel.text = NSLocalizedString("苹果支付", comment: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    // MARK: - Private Methods

    private func loadData() {
        let dict = ["token": UserDefaults.standard.object(forKey: "token"),
                    "uid": UserDefaults.standard.object(forKey: "uid")]
        self.showHud(in: self.view)
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/recharge_history", dic: dict as NSDictionary, success: { (data) in
            
            if JSON.init(data: data)["error"] == 0 {
                
                self.dataArray = JSON.init(data: data)["body"].arrayValue
                self.hideHud()
                if self.dataArray.count == 0 {
                    self.view.addSubview(self.messageLabel)
                }
                self.rechargeRecordTableView.reloadData()
            }
            
        }, fail: { (err) in
            print("服务器加载失败")
        }, Pro: { (pro) in
        })
    }
    
    @objc private func recharge() {
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = mainStoryBoard.instantiateViewController(withIdentifier: "TopUpVC") as! TopUpVC
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
