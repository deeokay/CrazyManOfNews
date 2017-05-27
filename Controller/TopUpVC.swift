//
//  TopUpVC.swift
//  AimiHealth
//
//  Created by apple on 2017/2/23.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import MJRefresh

class TopUpVC: HideTabbarController,UITableViewDelegate,UITableViewDataSource,SKProductsRequestDelegate,SKPaymentTransactionObserver{
    var vip_Month = "Cupiday.AimiHealth.1"
    var vip_hYear = "Cupiday.AimiHealth.2"
    var vip_Year = "Cupiday.AimiHealth.3"
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var TB: UITableView!
    var HUD = MBProgressHUD()
    override func viewDidLoad() {
        super.viewDidLoad()
        HUD = MBProgressHUD.init()
        HUD.center = self.view.center
        HUD.mode = .indeterminate
        HUD.label.text = NSLocalizedString("支付中", comment: "")
        self.view.addSubview(HUD)
        self.TB.tableFooterView = UIView()
        self.TB.register(UINib.init(nibName: "TopUpMicoinsCell", bundle: nil), forCellReuseIdentifier: "topUpCell")
        self.TB.register(UINib.init(nibName: "vipCell", bundle: nil), forCellReuseIdentifier: "vipCell")
        if !SKPaymentQueue.canMakePayments(){
            let alert = UIAlertController.init(title: NSLocalizedString("无法使用苹果支付", comment: ""), message: NSLocalizedString("当前Apple ID不支持内购,请重新检查后再试", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "朕知道了", style: .default, handler: nil))
        }
        SKPaymentQueue.default().add(self)
        let header = MJRefreshNormalHeader.init(refreshingBlock: {
            self.TB.mj_header.endRefreshing()
            self.getAcountInfo()
            self.getDeviceInfo()
        })
        header?.setTitle(NSLocalizedString("刷新用户与设备信息", comment: ""), for: .pulling)
        self.TB.mj_header = header

        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "isLogin"){
            self.getAcountInfo()
        }
        else{
            self.userInfo = Locale.cast(str: "当前为游客模式")
        }
        self.getDeviceInfo()
    }

    

    @IBAction func goToRechargeVC(_ sender: Any) {
        let vc = MiCoinViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("处理支付中!")
        for i in transactions{
            if SKPaymentTransactionState.purchased == i.transactionState{
                var vipLevel = 0
                switch goodsName {
                case vip_Year:
                    vipLevel = 3
                case vip_hYear:
                    vipLevel = 2
                case vip_Month:
                    vipLevel = 1
                default:
                    break
                }
                self.HUD.hide(animated: true)
                self.goodsName = ""
                if vipLevel > 0{
                    if self.isDeviceBuyVip{
                        AimiFunction.deviceBuyVIP(success: {
                            self.isDeviceBuyVip = false
                            print("触发了RMB购买设备VIP接口!")
                            UserDefaults.standard.set(true, forKey: "DVIP")
                            SKPaymentQueue.default().finishTransaction(i)
                            self.getDeviceInfo()
                            self.successMemo()
                        }, fail: { 
                            self.getDeviceInfo()
                            self.failMemo()
                            SKPaymentQueue.default().restoreCompletedTransactions()
                        }, vipLevel: vipLevel)
                    }
                        
                    else{
                        AimiFunction.RMB_VIP(success: {
                            print("触发了RMB购买用户VIP接口!")
                            UserDefaults.standard.set(true, forKey: "VIP")
                            SKPaymentQueue.default().finishTransaction(i)
                            self.getAcountInfo()
                            self.successMemo()
                        }, fail: {
                            self.failMemo()
                            SKPaymentQueue.default().restoreCompletedTransactions()
                        }, vipLevel: vipLevel)
                    }
                    
                }
            }
            else if SKPaymentTransactionState.failed == i.transactionState{
                SKPaymentQueue.default().restoreCompletedTransactions()
                DeeShareMenu.messageFrame(msg: Locale.cast(str: "购买异常!"), view: self.view)
                self.HUD.hide(animated: true)
                return
            }
        }
    }
    
    func successMemo() -> Void {
        self.HUD.hide(animated: true)
        let alert = UIAlertController.init(title: NSLocalizedString("支付结果", comment: ""), message: NSLocalizedString("购买成功", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("朕知道了", comment: ""), style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func failMemo() -> Void {
        self.HUD.hide(animated: true)
        let alert = UIAlertController.init(title: NSLocalizedString("支付结果", comment: ""), message: NSLocalizedString("购买失败,请联系客服处理", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("联系客服", comment: ""), style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("完成恢复事务")
        self.HUD.hide(animated: true)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        print("更新下载")
        self.HUD.hide(animated: true)

    }

    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        self.HUD.hide(animated: true)
        print("移除恢复事务!")
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let payMent = SKPayment.init(product: response.products.last!)
        SKPaymentQueue.default().add(payMent)
        self.HUD.label.text = NSLocalizedString("验证结果中", comment: "")
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("完成恢复!")
        self.HUD.hide(animated: true)
    }

    func refreshStatus() -> Void {
        self.info.text =  "\(self.userInfo)\n\(self.deviceInfo)"
    }

    var deviceInfo = ""
    func getDeviceInfo() -> Void {
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/check_visitor_vip", dic: ["device":AimiFunction.getUniqueDeviceIdentifierAsString()], success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                print("请求访问设备VIP失败!")
                return
            }
            let json_err = json.object(forKey: "error") as! Int
            if json_err == 0{
                self.deviceInfo = "当前设备剩余的服务天数:\(json.object(forKey: "day") as! String)"
                UserDefaults.standard.set(true, forKey: "DVIP")
            }
            else{
                self.deviceInfo = "\(json.object(forKey: "message") as! String)"
                UserDefaults.standard.set(false, forKey: "DVIP")
            }
            UserDefaults.standard.synchronize()
            self.refreshStatus()
        }, fail: { (err) in
            print(err.localizedDescription)
        }) { (pro) in
        }
    }
    var userInfo = ""
    var currentCoins = 0
    func getAcountInfo() -> Void {
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/select_integral", dic: ["uid":UserDefaults.standard.integer(forKey: "uid")], success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                DeeShareMenu.messageFrame(msg: NSLocalizedString("服务器错误!", comment: ""), view: self.view)
                return
            }
            if json.object(forKey: "error") as! Int == 0{
                var day = json.object(forKey: "day") as! Int
                if UserDefaults.standard.bool(forKey: "isLogin") == false {
                    day = 0
                }
                let integral = json.object(forKey: "integral") as! Int
                self.userInfo = "\(NSLocalizedString("当前的用户服务剩余时间:", comment: ""))\(day)\(NSLocalizedString("天", comment: ""))"
                self.currentCoins = integral
            }
            self.refreshStatus()
        }, fail: { (err) in
            DeeShareMenu.messageFrame(msg: err.localizedDescription, view: self.view)
        }) { (pro) in
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
             return 3
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }



    var goodsName = ""
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "vipCell", for: indexPath) as! vipCell
            let arr =  [vip_Year,vip_hYear,vip_Month]
            var Level = ""
            var days = ""
            var amount = ""
            var color = UIColor.init()
            switch indexPath.row {
            case 0:
                Level = NSLocalizedString("金牌会员服务", comment: "")
                days = NSLocalizedString("享受365天", comment: "")
                amount = NSLocalizedString("¥50", comment: "")
                color = UIColor.init(red: 106/255, green: 124/255, blue: 255/255, alpha: 0.7)
            case 1:
                Level = NSLocalizedString("银牌会员服务", comment: "")
                days = NSLocalizedString("享受183天", comment: "")
                amount = NSLocalizedString("¥30", comment: "")
                color = UIColor.init(red: 120/255, green: 124/255, blue: 255/255, alpha: 0.7)
            case 2:
                Level = NSLocalizedString("铜牌会员服务", comment: "")
                days = NSLocalizedString("享受30天", comment: "")
                amount = NSLocalizedString("¥6", comment: "")
                color = UIColor.init(red: 148/255, green: 124/255, blue: 255/255, alpha: 0.7)
            default:
                break
            }
            cell.vipLevel.text = Level
            cell.enjoyDays.text = days
            cell.topUpVipBtn.setTitle(amount, for: .normal)
            cell.backgroundColor = color
            
        cell.topUpVipAction = {
            if !UserDefaults.standard.bool(forKey: "isLogin"){
            let recharge = UIAlertController.init(title: Locale.cast(str: "开通VIP"), message: Locale.cast(str: "登录爱米购买,可跨平台享受会员权益,直接购买,会为当前设备开通会员,当两者皆是会员时,取最高权益为主."), preferredStyle: .alert)
            recharge.addAction(UIAlertAction.init(title:Locale.cast(str: "登录爱米购买"), style: .default, handler: { (action) in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                self.present(vc, animated: true, completion: nil)
            }))
            recharge.addAction(UIAlertAction.init(title: Locale.cast(str: "游客身份购买"), style: .default, handler: { (action) in
                self.goodsName = arr[indexPath.row]
                let set = NSSet.init(object: self.goodsName)
                print("商品名称:",self.goodsName)
                self.isDeviceBuyVip = true
                let buyRequst = SKProductsRequest.init(productIdentifiers: set as! Set<String>)
                buyRequst.delegate = self
                buyRequst.start()
//                self.HUD.show(animated: true)
            }))
            recharge.addAction(UIAlertAction.init(title: Locale.cast(str: "朕不要了"), style: .destructive, handler: nil))
            self.present(recharge, animated: true, completion: nil)
            }
            else{
                AimiFunction.checkLogin(controller: self, success: {
                    self.goodsName = arr[indexPath.row]
                    let set = NSSet.init(object: self.goodsName)
                    print("商品名称:",self.goodsName)
                    let buyRequst = SKProductsRequest.init(productIdentifiers: set as! Set<String>)
                    buyRequst.delegate = self
                    buyRequst.start()
                    self.HUD.show(animated: true)
                })
            }
        }
            return cell
    }

    var isDeviceBuyVip = false

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 40))
        let title = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: UIwidth, height: 40))
        title.tintColor = UIColor.darkGray
        title.text = "充值"
        title.textAlignment = .center
        view.addSubview(title)
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 0
    }



    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 50
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
