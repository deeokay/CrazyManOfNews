//
//  mineViewController.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/24.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import PushKit
import UserNotifications
var shareShare = false
class mineViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet var userName: UILabel!
    @IBOutlet var headImg: UIImageView!
    @IBOutlet var TB: UITableView!
    var platformArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent.init()
        content.title = "hello!"
        content.body = "hahahhaha"
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: TimeInterval.init(1), repeats: false)
        let request = UNNotificationRequest.init(identifier: "Fuck?", content: content, trigger: trigger)
        center.add(request) { (error) in
            print("成功推送了!")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "mineCell") as! mineCell
            return cell
        }
        else{
            var cell = tableView.dequeueReusableCell(withIdentifier: "none")
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "none")
            switch indexPath.row {
            case 1:
                cell?.textLabel?.text = "清除缓存"
            case 2:
                if shareShare {
                    cell?.textLabel?.text = "关闭摇一摇分享"
                }else{
                    cell?.textLabel?.text = "开启摇一摇分享"
                }
            case 3:
                cell?.textLabel?.text = "联系作者"
            case 4:
                cell?.textLabel?.text = "款爷赞助"

            default:
                break
            }
            return cell!
        }

    }
    //MARK: TableView点击行为
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: IndexPath.init(row: indexPath.row, section: 0))
        switch indexPath.row {
        case 1:
            let alert = UIAlertController.init(title: "这会更消耗更多的流量", message: "清除缓存", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
            alert.addAction(UIAlertAction.init(title: "确定", style: UIAlertActionStyle.default, handler: { (action) in
                self.earseCache()
            }))
            self.present(alert, animated: true, completion: nil)
            cell?.isSelected = false

        case 2:
            if shareShare == false{
                cell?.isSelected = false
                shareShare = true
                cell?.textLabel?.text = "关闭摇一摇分享"

            }else{
                cell?.isSelected = false
                shareShare = false
                cell?.textLabel?.text = "开启摇一摇分享"
            }

        case 3:
            UIApplication.shared.open(URL.init(string: "mailto://qianjiehao@qq.com")!, options: ["SMS":"haha"], completionHandler: nil)
        default:
            break
        }
    }



    func earseCache() -> Void {
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        print("缓存目录",cachePath!)
        let files = FileManager.default.subpaths(atPath: cachePath!)
        for i in files!{
            let path = cachePath?.appendingFormat("/\(i)")
            if FileManager.default.fileExists(atPath: path!){
                do {
                    try FileManager.default.removeItem(atPath: path!)
                } catch {
                    print(exception())
                }
            }
        }
    }


    @IBAction func Login(_ sender: UIButton) {
        switch sender.tag {
        case 11://QQ
            print("QQ login")
            ShareSDK.getUserInfo(SSDKPlatformType.typeQQ, onStateChanged: { (state, user, err) in
                switch state.rawValue {
                case 1:print("成功")
                self.headImg.sd_setImage(with: URL.init(string: (user?.icon)!))
                self.userName.text = user?.nickname
                case 2:print("失败信息:",err! as Error)
                default:break
                }
            })


        case 12://微信
            print("WeChat login")
            ShareSDK.getUserInfo(SSDKPlatformType.typeWechat, onStateChanged: { (state, user, err) in
                switch state.rawValue {
                case 1:print("成功")
                self.headImg.sd_setImage(with: URL.init(string: (user?.icon)!))
                self.userName.text = user?.nickname
                case 2:print("失败信息:",err! as Error)
                default:break
                }
            })
        case 13://微博
            print("Sina login")
            ShareSDK.getUserInfo(SSDKPlatformType.typeSinaWeibo, onStateChanged: { (state, user, err) in
                switch state.rawValue {
                case 1:print("成功")
                self.headImg.sd_setImage(with: URL.init(string: (user?.icon)!))
                self.userName.text = user?.nickname
                case 2:print("失败信息:",err! as Error)
                default:break
                }
            })

        default:
            break
        }

    }





    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
}
