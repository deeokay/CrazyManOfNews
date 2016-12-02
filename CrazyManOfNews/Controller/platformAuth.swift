//
//  platformAuth.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/26.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit

class platformAuth: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var platformArray = NSMutableArray()
    @IBOutlet var TB: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let platformArray = NSArray.init(objects: SSDKPlatformType.typeQQ,SSDKPlatformType.typeSinaWeibo)
        for i in 0..<platformArray.count{
            let dict = NSMutableDictionary.init(dictionary: self.dictWithPlatformName(platformType: i))
            let tmp = platformArray.object(at: i) as! SSDKPlatformType
            dict.setValue(tmp.rawValue, forKey: "AuthPlatformTypeKey")
            self.platformArray.add(dict)
            print(dict.allKeys,dict.allValues)
        }








    }
    func dictWithPlatformName(platformType:Int) -> NSMutableDictionary {
        var imageName = NSString.init()
        var platformName = NSString.init()
        let dict = NSMutableDictionary.init(capacity: 1)
        switch platformType {
        case 0:
            imageName = "UMS_qq_iocn"
            platformName = "QQ"
        case 1:
            imageName = "UMS_sina_icon"
            platformName = "新浪"
        default:
            break

        }
        dict.setValue(imageName , forKey: "AuthPlatformIconNameKey")
        dict.setValue(platformName, forKey: "AuthPlatformNameKey")
        return dict
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return platformArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dict = platformArray.object(at: indexPath.row) as! NSDictionary
        let cell = tableView.dequeueReusableCell(withIdentifier: "platformCell") as! platformCell
        cell.platformLabel.text = dict.object(forKey: "AuthPlatformNameKey") as! String?
        cell.platformType = Int(dict.object(forKey: "AuthPlatformTypeKey") as! UInt)
        cell.platformSwitch.isOn = self.checkIsLogin(platformType: SSDKPlatformType.init(rawValue: UInt(cell.platformType))!)

        print(cell.platformType)
        cell.event = {
            self.switchAction(platformType: cell.platformType, platformSwitch: cell.platformSwitch)
        }
        return cell

    }


    func switchAction(platformType:Int,platformSwitch: UISwitch) -> Void {
        if platformSwitch.isOn{
            ShareSDK.authorize(SSDKPlatformType.init(rawValue: UInt(platformType))!, settings: nil, onStateChanged:  { (state,usrinfo,err)  in
                switch state{
                case SSDKResponseState.success: print("授权成功")
                case SSDKResponseState.fail: print("授权失败,错误描述:\(err)")
                case SSDKResponseState.cancel:  print("操作取消")
                default:
                    break
                }
                })
        }
        else{
            ShareSDK.cancelAuthorize(SSDKPlatformType.typeQQ)
        }
    }
    func checkIsLogin(platformType:SSDKPlatformType) -> Bool {
        if  (ShareSDK.hasAuthorized(SSDKPlatformType.typeQQ))
        {
            print("auth SUCCESS",platformType.rawValue)
            return true
        }
        else{
            print("auth FAIL",platformType.rawValue)
            return false
        }
    }


    @IBAction func test(_ sender: AnyObject) {
        // 1.创建分享参数
        let shareParames = NSMutableDictionary()
        shareParames.ssdkSetupShareParams(byText: "分享内容",
                                          images : UIImage(named: "Ve.jpg"),
                                          url : NSURL(string:"http://mob.com") as URL!,
                                          title : "分享标题",
                                          type : SSDKContentType.image)

        //2.进行分享
        ShareSDK.share(SSDKPlatformType.typeQQ, parameters: shareParames) { (state : SSDKResponseState, nil, entity : SSDKContentEntity?, error :Error?) in

            switch state{

            case SSDKResponseState.success: print("分享成功")
            case SSDKResponseState.fail:    print("授权失败,错误描述:\(error)")
            case SSDKResponseState.cancel:  print("操作取消")

            default:
                break
            }
        }


    }
    
    
}
