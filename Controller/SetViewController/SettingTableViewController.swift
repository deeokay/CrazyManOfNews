//
//  SettingTableViewController.swift
//  AimiHealth
//
//  Created by IvanLee on 2017/3/6.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var shakeSwitch: UISwitch!
    @IBOutlet weak var downSwitch: UISwitch!
    @IBOutlet weak var cacheLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var mixSwitch: UISwitch!
    @IBOutlet weak var mixWeb: UISwitch!
    // 缓存大小
    var size: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(UserDefaults.standard)
        self.clearsSelectionOnViewWillAppear = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 如果没有登录，按钮们就不能用
        if UserDefaults.standard.bool(forKey: "isLogin") == false {
            self.logoutButton.isHidden = true
        } else {
            self.logoutButton.isHidden = false
        }
        self.shakeSwitch.isOn = UserDefaults.standard.bool(forKey: shankeShare)
        self.downSwitch.isOn = UserDefaults.standard.bool(forKey: "downloadWhilePlaying")
        self.mixSwitch.isOn = UserDefaults.standard.bool(forKey: "mix")
        self.mixSwitch.isOn = UserDefaults.standard.bool(forKey: "mix")
        self.mixWeb.isOn = UserDefaults.standard.bool(forKey: "mixWeb")
        // 查询缓存
        self.calCache()
    }
    
    // 计算缓存大小
    private func calCache() {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
        guard let appCachePath = cachePath?.appending("/Cupiday.AimiHealth") else {
            print("文件路径不存在")
            return
        }
        guard let array = FileManager.default.subpaths(atPath: appCachePath) else {
            print("找不到子文件")
            self.cacheLabel.text = "0MB"
            return
        }
        for subPath in array {
            let fullPath = appCachePath.appending("/\(subPath)")
            if FileManager.default.fileExists(atPath: fullPath) == true {
                do {
                    if let attr: NSDictionary = try FileManager.default.attributesOfItem(atPath: fullPath) as NSDictionary? {
                        size += Double(attr.fileSize())
                    }
                } catch {
                    
                }
            }
        }
        self.cacheLabel.text = String(format: "%.2fMB", size/1000/1000)
    }
    
    @IBAction func shakeAction(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: shankeShare)
        UserDefaults.standard.synchronize()
    }
    @IBAction func downAction(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "downloadWhilePlaying")
        UserDefaults.standard.synchronize()
    }
    @IBAction func mixAction(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "mix")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func mixWebAction(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "mixWeb")
        UserDefaults.standard.synchronize()
    }
    
    

    @IBAction func cancelAction(_ sender: Any) {
        print("退出登录")
        if UserDefaults.standard.bool(forKey: "isLogin") == true {
        
            let alert = UIAlertController.init(title: NSLocalizedString("提示", comment: ""), message: NSLocalizedString("是否退出登录?", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: NSLocalizedString("确定", comment: ""), style: .default, handler: { (alertAction) in
                UserDefaults.standard.set(false, forKey: "isLogin")
                UserDefaults.standard.set(0, forKey: "uid")
                UserDefaults.standard.set(false, forKey: "VIP")
                UserDefaults.standard.synchronize()
                _ = self.navigationController?.popViewController(animated: true)
                AimiData.deleteAllData {
                }
            })
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if UserDefaults.standard.bool(forKey: "isLogin") == true {
                return 3
            } else {
                return 1
            }
        } else {
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                // 摇一摇分享
                self.shakeSwitch.setOn(!self.shakeSwitch.isOn, animated: true)
                UserDefaults.standard.set(self.shakeSwitch.isOn, forKey: shankeShare)
                UserDefaults.standard.synchronize()
            case 1:
                // 边下边播
                self.downSwitch.setOn(!self.downSwitch.isOn, animated: true)
                UserDefaults.standard.set(self.downSwitch.isOn, forKey: "downloadWhilePlaying")
                UserDefaults.standard.synchronize()
            case 2:
                // 混合风格
                self.mixSwitch.setOn(!self.mixSwitch.isOn, animated: true)
                UserDefaults.standard.set(self.mixSwitch.isOn, forKey: "mix")
                UserDefaults.standard.synchronize()
            default:
                // 混合风格
                self.mixWeb.setOn(!self.mixWeb.isOn, animated: true)
                UserDefaults.standard.set(self.mixWeb.isOn, forKey: "mixWeb")
                UserDefaults.standard.synchronize()
            }
        } else {
            switch indexPath.row {
            case 0:
                // 清除缓存
                let alert = UIAlertController.init(title: NSLocalizedString("提示", comment: ""), message: NSLocalizedString("是否清除缓存?", comment: ""), preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: NSLocalizedString("确定", comment: ""), style: .default, handler: { (alertAction) in
                    // 清除缓存
                    let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
                    let appCachePath = cachePath?.appending("/Cupiday.AimiHealth")
                    if FileManager.default.fileExists(atPath: appCachePath!) {
                        do {
                            try FileManager.default.removeItem(atPath: appCachePath!)
                            self.calCache()
                        } catch {
                            
                        }
                    }
                })
                let cancelAction = UIAlertAction.init(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil)
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            case 1:
                // 设置密码
                let secretVC = ChangePasswordController()
                self.navigationController?.pushViewController(secretVC, animated: true)
            default:
                // 修改密保
                let guardSecretVC = ConfigMiBaoViewController()
                self.navigationController?.pushViewController(guardSecretVC, animated: true)
            }
        }
    }

}
