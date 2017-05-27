//
//  Tabbar.swift
//  AimiHealth
//
//  Created by apple on 2016/12/15.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit
import WZLBadge
class Tabbar: UITabBarController {
    
    var action1 = {Void()}
    var action2 = {Void()}
    var action3 = {Void()}
    var action4 = {Void()}
    var action5 = {Void()}
    
    @IBOutlet weak var tabbar: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = UIColor.init(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)//选中999999
        let selectColor = UIColor.init(red: 82/255, green: 171/255, blue: 244/255, alpha: 1)//选中999999
        
        
        let tabBarTitles = ["新闻","媒体","图库","我的"]
        let pic = ["米圈","米秀","米聊","米粉"]

        for (index, title) in tabBarTitles.enumerated() {
            print("LLLLLL",pic[index])
            self.tabbar.items?[index].image = UIImage.init(named: pic[index])?.withRenderingMode(.alwaysOriginal)
            self.tabbar.items?[index].selectedImage = UIImage.init(named: pic[index] + "选中")?.withRenderingMode(.alwaysOriginal)
            self.tabbar.items?[index].setTitleTextAttributes([NSForegroundColorAttributeName : color], for: UIControlState.normal)
            self.tabbar.items?[index].setTitleTextAttributes([NSForegroundColorAttributeName : selectColor], for: UIControlState.selected)
        }
        
        
                self.tabbar.items?[1].badgeValue = Locale.cast(str: "热")
        self.requestAllBadge()
        let timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.requestAllBadge), userInfo: nil, repeats: true)
        DispatchQueue.global().async {
            RunLoop.current.add(timer, forMode: .commonModes)
            RunLoop.current.run()
            
        }

    }
    
    func requestAllBadge() -> Void {
        self.UpdateArticle()
//        self.UpdatePictures()
//        self.UpdateVideos()
    }
    
    func UpdateArticle() -> Void {
        let urlString = "https://aimi.cupiday.com/\(AIMIversion)/article"
        let dic:NSDictionary = ["page":1,"version":AISubMIversion,"channel":13]
        DeeRequest.requestGet(url: urlString, dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data , options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                print("解析文章增量JSON失败!")
                return
            }
            
            guard json.object(forKey: "error") as! Int == 0 else{
                print("请求文章增量错误")
                return
            }
            
            if let total = json.object(forKey: "total") as! Int?{
                let updateNum = total - UserDefaults.standard.integer(forKey: "MiquanTotal")
                print("文章更新数量:",updateNum)
                guard updateNum > 0 else{
                    self.tabbar.items?[0].clearBadge()
                    return
                }
//                self.tabBar.items?[0].badgeValue = String(updateNum)
                self.tabbar.items?[0].showBadge(with: .new, value: 0, animationType: WBadgeAnimType.breathe)
                UserDefaults.standard.set(total, forKey: "MiquanTotal")
                UserDefaults.standard.synchronize()
            }
            
        }, fail: { (error) in
            print(error.localizedDescription)
        }, Pro: { (pro) in
        })
    }
    
    func UpdateVideos() -> Void {
        let dic:NSDictionary = ["page":1,"version":"\(AIMIversion)"]
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/video", dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                print("解析视频增量JSON失败!")
                return
            }
            
            guard json.object(forKey: "error") as! Int? != 1 else{
                print("请求视频增量错误")
                return
            }
            if let total = json.object(forKey: "total") as! Int?{
                self.videoTotal = total
                self.requestVideo = true
                if self.requestPic == true{
                    self.creatArr()
                }
            }
            
            
        }, fail: { (error) in
            print(error.localizedDescription)
        }) { (progress) in
        }
    }
    
    var picTotal = Int()
    var videoTotal = Int()
    var requestVideo = false
    var requestPic = false
    
    func UpdatePictures() -> Void {
        let dic:NSDictionary = ["page":1,"version":"\(AIMIversion)"]
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/images", dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                print("解析图集增量JSON失败!")
                return
            }
            
            guard json.object(forKey: "error") as! Int == 0 else{
                print("请求图片增量错误")
                return
            }
            if let total = json.object(forKey: "total") as! Int?{
                self.picTotal = total
                self.requestPic = true
                if self.requestVideo == true{
                    self.creatArr()
                }
            }
        }, fail: { (error) in
            print(error.localizedDescription)
        }) { (progress) in
        }
    }
    
    var resetLoad = false
    var created = false
    func creatArr() -> Void {
        if created == false{
            let total = self.picTotal + videoTotal
            let update = total - UserDefaults.standard.integer(forKey: "MixiuTotal")
            print("图集/视频更新数量:",update)
            guard update > 0 else{
                self.tabbar.items?[1].badgeValue = nil
                return
            }
            self.tabbar.items?[1].badgeValue = String(" ")
            UserDefaults.standard.set(total, forKey: "MixiuTotal")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 11:
            action1()
        case 12:
            action2()
        case 13:
            action3()
        case 14:
            action4()
        case 15:
            action5()
        default:
            break
        }
    }
}
