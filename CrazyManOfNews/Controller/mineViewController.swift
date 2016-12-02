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
import SwiftTheme
import GPUImage
class mineViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet var userName: UILabel!
    @IBOutlet var headImg: UIImageView!
    @IBOutlet var TB: UITableView!
    @IBOutlet var headimgBGView: UIView!
    @IBOutlet var blurImage: UIImageView!
    var platformArray = NSMutableArray()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.TB.register(UINib.init(nibName: "preferencesCell", bundle: nil), forCellReuseIdentifier: "preferencesCell")
        headimgBGView.theme_backgroundColor = ThemeColorPicker.init(colors: "#FFF","#AAA")
        headImg.layer.borderWidth = 2
        self.headImg.layer.cornerRadius = self.headImg.frame.width / 2
        getUserInfo(platForm: SSDKPlatformType.init(rawValue: UInt.init(UserDefaults.standard.integer(forKey: currentPlatform)))!, num: UserDefaults.standard.integer(forKey: currentPlatform))

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "mineCell") as! mineCell
            cell.function1.theme_backgroundColor = ThemeColorPicker(colors: "#FAFFFF","#B8B8B8")
            cell.function2.theme_backgroundColor = ThemeColorPicker(colors: "#FAFFFF","#B8B8B8")
            cell.function3.theme_backgroundColor = ThemeColorPicker(colors: "#FAFFFF","#B8B8B8")
            cell.bgView.theme_backgroundColor = ThemeColorPicker.init(colors: "#FF0000","#686868")
            cell.function3Event = {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Collect") as! Collect
                self.navigationController?.pushViewController(vc, animated: true)
            }
            cell.function2Event = {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "collectNews") as! collectNews
                self.navigationController?.pushViewController(vc, animated: true)
            }
            cell.function1Event = {
                let center = UNUserNotificationCenter.current()
                let content = UNMutableNotificationContent.init()
                content.title = "你收到一条新的通知!"
                content.body = "新闻推送功能将会在下版本推出,感谢您的使用"
                content.sound = UNNotificationSound.default()
                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: TimeInterval.init(0.5), repeats: false)
                let request = UNNotificationRequest.init(identifier: "myMessage", content: content, trigger: trigger)
                center.add(request) { (error) in
                    print("成功推送了一条消息!")
                }
            }
            return cell
        }
        else if indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "preferencesCell") as! preferencesCell
            cell.label.text = "夜间模式"
            cell.switch.isOn = UserDefaults.standard.bool(forKey: "nightMode")
            cell.event = {
                if cell.switch.isOn{
                    UserDefaults.standard.set(true, forKey: "nightMode")
                    ThemeManager.setTheme(index: 1)
                }
                else{
                    UserDefaults.standard.set(false, forKey: "nightMode")
                    ThemeManager.setTheme(index: 0)
                }
            }
            return cell
        }
        else if indexPath.row == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "preferencesCell") as! preferencesCell
            cell.label.text = "摇一摇分享"
            cell.switch.isOn = UserDefaults.standard.bool(forKey: "shankeShare")
            cell.event = {
                if cell.switch.isOn{
                    UserDefaults.standard.set(true, forKey: "shankeShare")
                }
                else{
                    UserDefaults.standard.set(false, forKey: "shankeShare")
                }
            }
            return cell
        }
        else if indexPath.row == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: "preferencesCell") as! preferencesCell
            cell.label.text = "省流量模式(不自动加载Gif图)"
            cell.switch.isOn = UserDefaults.standard.bool(forKey: "saveMode")
            cell.event = {
                if cell.switch.isOn{
                    UserDefaults.standard.set(true, forKey: "saveMode")
                }
                else{
                    UserDefaults.standard.set(false, forKey: "saveMode")
                }
            }

            return cell
        }
        else{
            var cell = tableView.dequeueReusableCell(withIdentifier: "none")
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "none")
            switch indexPath.row {
            case 4:
                cell?.textLabel?.text = "清除缓存"
            case 5:
                cell?.textLabel?.text = "用户反馈"
            case 6:
                cell?.textLabel?.text = "使用帮助"
            case 7:
                cell?.textLabel?.text = "关于"
            default:
                break
            }
            return cell!
        }

    }
    //MARK: TableView点击行为
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let cell = tableView.cellForRow(at: IndexPath.init(row: indexPath.row, section: 0))
        switch indexPath.row {
        case 4:
            let alert = UIAlertController.init(title: "清除缓存", message: "加载内容时会更消耗更多的流量", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
            alert.addAction(UIAlertAction.init(title: "确定", style: UIAlertActionStyle.default, handler: { (action) in
                self.earseCache()
            }))
            self.present(alert, animated: true, completion: nil)
        case 5:
            UIApplication.shared.open(URL.init(string: "mailto://qianjiehao@qq.com")!, options: [:], completionHandler: nil)
        case 6:
            break
        //help
        case 7://about
            break
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
            getUserInfo(platForm: SSDKPlatformType.typeQQ, num: sender.tag)
        case 12://微信
            print("WeChat login")
            getUserInfo(platForm: SSDKPlatformType.typeWechat, num: sender.tag)
        case 13://微博
            print("Sina login")
            getUserInfo(platForm: SSDKPlatformType.typeSinaWeibo, num: sender.tag)
        default:
            break
        }
    }
    var recordPlatformNum:UInt = 0
    var externalPlatformNum:UInt = 0
    func getUserInfo(platForm:SSDKPlatformType,num:Int) -> Void {
        do {
                try ShareSDK.getUserInfo(platForm, onStateChanged: { (state, user, err) in
                switch state.rawValue {

                case 1:print("成功")

                UserDefaults.standard.set(platForm.rawValue, forKey: currentPlatform)
                let image = UIImage.animatedImage(withAnimatedGIFURL: URL.init(string: (user?.icon)!))
                self.recordPlatformNum = (platForm.rawValue)
                self.externalPlatformNum = (platForm.rawValue)
                self.headImg.image = image
                self.userName.text = user?.nickname
                let gaussian = GPUImageGaussianBlurFilter.init()
                gaussian.blurPasses = 1
                gaussian.blurRadiusInPixels = 5
                gaussian.forceProcessing(atSizeRespectingAspectRatio: (image?.size)!)
                gaussian.useNextFrameForImageCapture()
                let gpuImage = GPUImagePicture.init(image: image)
                gpuImage?.addTarget(gaussian)
                gpuImage?.processImage()
                self.blurImage.image = gaussian.imageFromCurrentFramebuffer()






                case 2:print("失败信息:",err! as Error)
                UserDefaults.standard.set(0, forKey: currentPlatform)
                self.headImg.image = nil
                self.blurImage.image = nil
                self.userName.text = "客官大人怎还不登录?"
                default:break
                }
            })

        } catch {
            print("请求错误!")
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 60
        }
        else{
            return 50
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.TB.reloadRows(at: [IndexPath.init(row: 2, section: 0)], with: .none)
        //        let animation = CATransition.init()
        //        animation.duration = 1
        //        animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
        //        animation.type = kCATransitionFade
        //        animation.subtype = kCATransitionFade
        //        self.blurImage.layer.add(animation, forKey: "animation")
        //        self.headImg.layer.add(animation, forKey: "animation2")
        if recordPlatformNum != externalPlatformNum{
            getUserInfo(platForm: SSDKPlatformType.init(rawValue: UInt.init(UserDefaults.standard.integer(forKey: currentPlatform)))!, num: UserDefaults.standard.integer(forKey: currentPlatform))
        }


    }

    override func viewDidDisappear(_ animated: Bool) {
        UserDefaults.standard.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        GPUImageContext.sharedFramebufferCache().purgeAllUnassignedFramebuffers()

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "author"{
            let vc = segue.destination as! platformAuth
            vc.superVC = self
        }
    }
    
}
