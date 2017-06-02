//
//  PersonalPreference.swift
//  AimiHealth
//
//  Created by apple on 2016/12/5.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit
import pop
import TabPageViewController
import MJRefresh
import Kingfisher
class PersonalPreference: UIViewController,UITableViewDataSource,UITableViewDelegate,GDTMobBannerViewDelegate {
    
    var banner = GDTMobBannerView()
    @IBOutlet weak var TB: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TB.tableFooterView = UIView()
        self.TB.register(UINib.init(nibName: "userCenter", bundle: nil), forCellReuseIdentifier: "user")
        let bar = self.tabBarController as! Tabbar
        bar.action4 = {
            if  bar.selectedIndex == 2{
                DeeSetView.setAnimate(view: self.TB, orginW: UIwidth * 0.7, orginH: UIheight * 0.7, pointX: UIwidth / 2, pointY: UIheight / 2, width: UIwidth, height: UIheight, key: "myPer")
            }
        }
        self.banner = GDTMobBannerView.init(frame: CGRect.init(x: 0, y: UIheight - 50 - 44, width: UIwidth, height: 50), appkey: "1105939483", placementId: "9050028032736604")
        self.banner.delegate = self
        self.banner.interval = 30
        self.banner.currentViewController = self
        self.banner.isAnimationOn = true
        self.banner.showCloseBtn = false
        self.view.addSubview(self.banner)
        let header = MJRefreshNormalHeader.init {
            self.TB.reloadData()
            self.TB.mj_header.endRefreshing()
        }
        header?.isAutomaticallyChangeAlpha = true
        header?.setTitle(NSLocalizedString("刷新用户信息", comment: ""), for: .pulling)
        self.TB.mj_header = header
        
    }
    
    func bannerViewFail(toReceived error: Error!) {
        print(error)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.TB.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        if !UserDefaults.standard.bool(forKey: "VIP"){
            self.banner.loadAdAndShow()
        }
        else{
            self.banner.removeFromSuperview()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 3
        default:
            return 1
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "user") as! userCenter
                cell.selectionStyle = .none
                cell.bgImage.image = UIImage.init(named: "banner")
                cell.userImage.layer.cornerRadius = UIwidth / 11.2
                cell.gender.isHidden = true
                cell.topUpAction = {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "TopUpVC") as! TopUpVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.vipAction = {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "TopUpVC") as! TopUpVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                if  UserDefaults.standard.bool(forKey: "isLogin") {
                    let uid = UserDefaults.standard.integer(forKey: "uid")
                    DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/select_integral", dic: ["uid":uid], success: { (data) in
                        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                            print("解析-读取用户米币Json失败!")
                            return
                        }
                        if json.object(forKey: "error") as! Int == 0{
                            let vipLevel = json.object(forKey: "vip") as! Int
                            if UserDefaults.standard.bool(forKey: "VIP"){
                                UserDefaults.standard.set(true, forKey: "VIP")
                            }
                            else{
                                UserDefaults.standard.set(false, forKey: "VIP")
                            }
                            UserDefaults.standard.synchronize()
                            switch vipLevel {
                            case 1:
                                cell.VIPButton.setImage(UIImage.init(named: "铜色-拷贝"), for: .normal)
                            case 2:
                                cell.VIPButton.setImage(UIImage.init(named: "半年-拷贝"), for: .normal)
                            case 3:
                                cell.VIPButton.setImage(UIImage.init(named: "年卡"), for: .normal)
                            default:
                                cell.VIPButton.setImage(UIImage.init(named: "无-拷贝"), for: .normal)
                            }
                        }
                    }, fail: { (err) in
                        print("请求-读取用户米币Json失败!",err.localizedDescription)
                    }, Pro: { (pro) in
                    })
                    cell.userImage.kf.setImage(with: URL.init(string: UserDefaults.standard.object(forKey: "userImage") as! String))
                    cell.nickName.text = UserDefaults.standard.object(forKey: "userName") as! String?
                    cell.touXiang = {
                        let touxiang = ChangePhotosViewController()
                        let nav = UINavigationController.init(rootViewController: touxiang)
                        self.present(nav, animated: true, completion: nil)
                    }
                }
                else{
                    cell.userImage.image = UIImage.init(named: "大头像")
                    cell.VIPButton.setImage(UIImage.init(named: "无-拷贝"), for: .normal)
                    cell.nickName.text = NSLocalizedString("客官大人", comment: "")
                    cell.touXiang = {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                        self.present(vc, animated: true, completion: nil)
                    }
                }
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "Function1") as! Function1
                cell.selectionStyle = .none
                var vc = UIViewController()
                vc.hidesBottomBarWhenPushed = true
                // 历史
                cell.action_0 = {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "HistoryVC") as! HistoryVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                // 收藏
                cell.action_1 = {
                    let tc = TabPageViewController.create()
                    let miQuanVC = MiQuanViewController()
                    let miXiuVC = MiXiuViewController()
                    /*
                     * 去掉米聊
                    let miLiaoVC = MiLiaoViewController()
                    tc.tabItems = [(miQuanVC, NSLocalizedString("米 圈", comment: "")), (miLiaoVC, NSLocalizedString("米 聊", comment: "")), (miXiuVC, NSLocalizedString("米 秀", comment: ""))]
                    */
                    tc.tabItems = [(miQuanVC, NSLocalizedString("米 圈", comment: "")), (miXiuVC, NSLocalizedString("米 秀", comment: ""))]
                    var option = TabPageOption()
                    option.tabWidth = self.view.frame.width / CGFloat(tc.tabItems.count)
                    option.fontSize = 17.0
                    tc.option = option
                    let barButton = UIBarButtonItem.init(title: "", style: .done, target: self, action: nil)
                    tc.navigationItem.backBarButtonItem = barButton
                    tc.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("编辑", comment: ""), style: .done, target: self, action: #selector(PersonalPreference.collectionEdit))
                    tc.navigationItem.title = NSLocalizedString("收藏", comment: "")
                    self.navigationController?.pushViewController(tc, animated: true)
                }
                // 评论
                cell.action_2 = {
                    let tc = TabPageViewController.create()
                    let miquanVC = myCommentViewController()
                    let mixiuVC =  CommentMeViewController()
                    let starVC = StarMeViewController()
                    tc.tabItems = [(miquanVC, NSLocalizedString("我的评论", comment: "")),(mixiuVC, NSLocalizedString("评论我的", comment: "")),(starVC, NSLocalizedString("给我点赞", comment: ""))]
                    var option = TabPageOption()
                    option.tabWidth = self.view.frame.width / CGFloat(tc.tabItems.count)
                    option.fontSize = 17.0
                    tc.option = option
                    tc.navigationItem.title = NSLocalizedString("评论", comment: "")
                    let barButton = UIBarButtonItem.init(title: " ", style: .done, target: self, action: nil)
                    tc.navigationItem.backBarButtonItem = barButton
                    self.navigationController?.pushViewController(tc, animated: true)
                }
                // 米币
                cell.action_3 = {
                    vc = MiCoinViewController()
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                return cell
            }
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Function2") as! Function2
            cell.selectionStyle = .none
            if indexPath.section == 1 {
                switch indexPath.row {
                case 0:
                    cell.img.image = UIImage.init(named: "我的上传")
                    cell.label.text = NSLocalizedString("我要上传", comment: "")
                default:
                    cell.img.image = UIImage.init(named: "屏蔽列表")
                    cell.label.text = NSLocalizedString("屏蔽列表", comment: "")
                }
                
            }
            else if indexPath.section == 2{
                switch indexPath.row {
                case 0:
                    cell.img.image = UIImage.init(named: "用户反馈")
                    cell.label.text = NSLocalizedString("用户反馈", comment: "")
                case 1:
                    cell.img.image = UIImage.init(named: "用户协议")
                    cell.label.text = NSLocalizedString("用户协议", comment: "")
                default:
                    cell.img.image = UIImage.init(named: "关于爱米")
                    cell.label.text = NSLocalizedString("关于爱米", comment: "")
                }
            }
            else if indexPath.section == 3 {
                cell.img.image = UIImage.init(named: "系统设置")
                cell.label.text = NSLocalizedString("个人设置", comment: "")
            }
            return cell
        }
    }
    
    func collectionEdit() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "delete"), object: self)
    }
    
    func shieldEdit() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "shieldDelete"), object: self)
    }
    
    func bannerViewClicked() {
        AimiFunction.addMiCoin(success: {
            DeeShareMenu.messageFrame(msg: NSLocalizedString("增加米币成功", comment: ""), view: self.view)
            self.TB.reloadRows(at: [IndexPath.init(item: 0, section: 0)], with: .middle)
        }, fail: {
            DeeShareMenu.messageFrame(msg: NSLocalizedString("增加米币失败", comment: ""), view: self.view)
        }, num: 1)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var vc = UIViewController()
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        if indexPath.section == 0 && indexPath.row == 0{
            return
        }
        else if indexPath.section == 1{
            switch indexPath.row {
            case 0:
                vc = mainStoryBoard.instantiateViewController(withIdentifier: "MyUpload") as! MyUpload
            case 1:
                let tc = TabPageViewController.create()
                let contentVC = ContentShieldListController()
                let userVC = UserShieldListController()
                tc.tabItems = [(contentVC, NSLocalizedString("内 容", comment: "")), (userVC, NSLocalizedString("用 户", comment: ""))]
                var option = TabPageOption()
                option.tabWidth = self.view.frame.width / CGFloat(tc.tabItems.count)
                option.fontSize = 17.0
                tc.option = option
                let barButton = UIBarButtonItem.init(title: "", style: .done, target: self, action: nil)
                tc.navigationItem.backBarButtonItem = barButton
                tc.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("编辑", comment: ""), style: .done, target: self, action: #selector(PersonalPreference.shieldEdit))
                tc.navigationItem.title = NSLocalizedString("屏蔽列表", comment: "")
                self.navigationController?.pushViewController(tc, animated: true)
                return
            default:
                return
            }
        }
        else if indexPath.section == 2{
            switch indexPath.row {
            case 0:
                vc = mainStoryBoard.instantiateViewController(withIdentifier: "userFeedback") as! userFeedback
            case 1 :
                vc = mainStoryBoard.instantiateViewController(withIdentifier: "agreement") as! AgreementController
                let barButton = UIBarButtonItem.init(title: " ", style: .done, target: self, action: nil)
                vc.navigationItem.backBarButtonItem = barButton
                vc.hidesBottomBarWhenPushed = true
            default:
                vc = mainStoryBoard.instantiateViewController(withIdentifier: "AIMI_Introduce") as! AIMI_Introduce
            }
        }
        else if indexPath.section == 3{
            vc = mainStoryBoard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
            vc.hidesBottomBarWhenPushed = true
        } else {
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0...3:
            return 3
        default:
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 0...3:
            let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 999, height: 8))
            view.backgroundColor = UIColor.init(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
            return view
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                return UIwidth / 2.8
            default:
                return 80
            }
        }
        else{
            return 53
        }
    }
    
}
