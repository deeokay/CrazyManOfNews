//
//  RechargeMiCoins.swift
//  AimiHealth
//
//  Created by apple on 2017/3/8.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import MJRefresh
class RechargeMiCoins: HideTabbarController,UITableViewDelegate,UITableViewDataSource {
//    var delegate:AcountViewController?
    var delegate: MiCoinViewController?
    var HUD = MBProgressHUD()
    @IBOutlet weak var TB: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TB.register(UINib.init(nibName: "vipCell", bundle: nil), forCellReuseIdentifier: "vipCell")
        HUD = MBProgressHUD.init()
        HUD.center = self.view.center
        HUD.mode = .indeterminate
        HUD.label.text = NSLocalizedString("支付中", comment: "")
        self.view.addSubview(HUD)
        self.TB.tableFooterView = UIView()
        self.TB.register(UINib.init(nibName: "TopUpMicoinsCell", bundle: nil), forCellReuseIdentifier: "topUpCell")
        let header = MJRefreshNormalHeader.init(refreshingBlock: {
            self.TB.mj_header.endRefreshing()
            self.delegate?.data()
        })
        header?.setTitle(NSLocalizedString("刷新用户信息", comment: ""), for: .pulling)
        self.TB.mj_header = header
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "vipCell", for: indexPath) as! vipCell
            let vipLevel =  [3,2,1]
            let price = [500,300,60]
            var Level = ""
            var days = ""
            var amount = ""
            var color = UIColor.init()
            switch indexPath.row {
            case 0:
                Level = NSLocalizedString("金牌服务", comment: "")
                days = NSLocalizedString("享受365天", comment: "")
                amount = NSLocalizedString("500米币", comment: "")
                color = UIColor.init(red: 106/255, green: 124/255, blue: 255/255, alpha: 0.7)
            case 1:
                Level = NSLocalizedString("银牌服务", comment: "")
                days = NSLocalizedString("享受183天", comment: "")
                amount = NSLocalizedString("300米币", comment: "")
                color = UIColor.init(red: 120/255, green: 124/255, blue: 255/255, alpha: 0.7)
            case 2:
                Level = NSLocalizedString("铜牌服务", comment: "")
                days = NSLocalizedString("享受30天", comment: "")
                amount = NSLocalizedString("60米币", comment: "")
                color = UIColor.init(red: 148/255, green: 124/255, blue: 255/255, alpha: 0.7)
            default:
                break
        }
        cell.vipLevel.text = Level
        cell.enjoyDays.text = days
        cell.topUpVipBtn.setTitle(amount, for: .normal)
        cell.backgroundColor = color
        cell.topUpVipAction = {
            if Int((self.delegate?.miCoinNumberlabel.text)!)! < price[indexPath.row]{
                let alert = UIAlertController.init(title: NSLocalizedString("兑换", comment: ""), message: NSLocalizedString("米币不足,继续努力", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: NSLocalizedString("朕知道了", comment: ""), style: .default, handler: nil))
                alert.addAction(UIAlertAction.init(title: NSLocalizedString("充值", comment: ""), style: .default, handler: { (action) in
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "TopUpVC") as! TopUpVC
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                AimiFunction.MiCoin_VIP(success: {
                    self.delegate?.data()
                    UserDefaults.standard.set(true, forKey: "VIP")
                    let alert = UIAlertController.init(title: NSLocalizedString("兑换", comment: ""), message: NSLocalizedString("购买成功", comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: NSLocalizedString("朕知道了", comment: ""), style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }, fail: {
                }, vipLevel: vipLevel[indexPath.row])
                self.HUD.hide(animated: true)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    
    
}
