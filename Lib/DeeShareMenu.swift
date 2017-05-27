//
//  shareMenu.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/27.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import Foundation
import MMPopupView
class DeeShareMenu:NSObject {
    var shareDic = NSMutableDictionary()
    var stateHandler : SSDKShareStateChangedHandler?
    var supportSharePlatform = NSArray.init(objects: SSDKPlatformType.subTypeWechatTimeline,SSDKPlatformType.subTypeWechatSession,SSDKPlatformType.typeSinaWeibo,SSDKPlatformType.typeQQ)
    var nameArr = ["朋友圈","微信好友","新浪微博","QQ"]
     func shareMMpopMenu() -> MMSheetView{
        var arr = [MMPopupItem]()
        for number in 0..<self.supportSharePlatform.count{
            let item = MMPopupItem.init()
            item.highlight = true
            item.title = self.nameArr[number]
            item.handler = {(num) in
                let tmp = self.supportSharePlatform[number] as! SSDKPlatformType
                ShareSDK.share(SSDKPlatformType.init(rawValue: tmp.rawValue)!, parameters: self.shareDic, onStateChanged: self.stateHandler)
            }
            arr.append(item)
        }
        let alertView = MMSheetView.init(title:  "选择你要分享的平台", items: arr)
        return alertView!
    }

    func shareSysMenu() -> UIAlertController{
        var arr = [MMPopupItem]()
        for number in 0..<self.supportSharePlatform.count{
            let item = MMPopupItem.init()
            item.highlight = true
            item.title = self.nameArr[number]
            item.handler = {(num) in
                let tmp = self.supportSharePlatform[number] as! SSDKPlatformType
                ShareSDK.share(SSDKPlatformType.init(rawValue: tmp.rawValue)!, parameters: self.shareDic, onStateChanged: self.stateHandler)
            }
            arr.append(item)
        }
        let alertView = UIAlertController.init(title: "选择你要分享的平台", message: "分享平台选择", preferredStyle: .alert)
        for number in 0..<self.supportSharePlatform.count{
            let item = UIAlertAction.init(title: self.nameArr[number], style: .default, handler: { (action) in
                let tmp = self.supportSharePlatform[number] as! SSDKPlatformType
                ShareSDK.share(SSDKPlatformType.init(rawValue: tmp.rawValue)!, parameters: self.shareDic, onStateChanged: self.stateHandler)
            })
            alertView.addAction(item)
        }
        alertView.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        return alertView
    }



    class func shareContent(shareThumImage:inout UIImage,shareTitle:String,shareDescr:String,url:String,shareType:SSDKContentType) -> NSMutableDictionary{
        let shareParames = NSMutableDictionary()
        shareParames.ssdkSetupShareParams(byText: shareDescr,images : shareThumImage,url : URL.init(string: url)!,title : shareTitle,type : shareType)
        return shareParames
    }

    class func stateHandle(controller:UIViewController,success:@escaping () -> Void,fail:@escaping () -> Void) -> SSDKShareStateChangedHandler {
        let state:SSDKShareStateChangedHandler = {(state,userData,content,err) in
            switch state{
            case SSDKResponseState.success:
                success()
                AimiFunction.shareReward(controller: controller)
            case SSDKResponseState.fail:
                print("授权失败,错误描述:\(err.debugDescription)")
                let alert = UIAlertController.init(title: NSLocalizedString("分享失败", comment: ""), message: NSLocalizedString("你可以尝试转为以下方式重新分享", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: NSLocalizedString("朕知道了", comment: ""), style: .cancel, handler: nil))
                alert.addAction(UIAlertAction.init(title: NSLocalizedString("转文字分享", comment: ""), style: .default, handler: { (action) in
                    fail()
                }))
                alert.show(controller, sender: controller)
            case SSDKResponseState.cancel:  print("操作取消")
            default:
                break
            }
        }
        return state
    }


    class func messageFrame(msg:String = NSLocalizedString("评论成功!", comment: ""),view:UIView){
        let Label = UILabel.init()
        Label.center = CGPoint.init(x: UIwidth/2, y: 80)
        Label.backgroundColor = UIColor.darkGray
        Label.textColor = UIColor.white
        Label.text = msg
        var fontSize:CGFloat = 14
        if UIwidth <= 320{
            fontSize = 11
        }
        Label.font = UIFont.boldSystemFont(ofSize: fontSize)
        Label.layer.cornerRadius = 5
        Label.clipsToBounds = true
        Label.textAlignment = .center
        view.addSubview(Label)
        DeeSetView.setAnimate(view: Label, orginW: 0, orginH: 0, pointX: UIwidth/2, pointY: 80, width: UIwidth/2.5, height: 40, key: "label")
        UIView.animate(withDuration: 3, animations: {
            Label.alpha = 0
        }, completion: { b in
            Label.removeFromSuperview()
        })
    }

    

    class func showShankeMenu( Yes :@escaping ()->Void,No: @escaping ()->Void,ViewController:UIViewController,keepWarning:Bool){
        if keepWarning{
            let alert = UIAlertController.init(title: NSLocalizedString("开启摇一摇", comment: ""), message: NSLocalizedString("检测到你在摇晃,是否需要开启摇一摇分享功能?", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("不再提醒", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action) in
                No()
            }))
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("下次提醒", comment: ""), style: UIAlertActionStyle.destructive, handler: { (action) in
            }))
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("现在开启", comment: ""), style: UIAlertActionStyle.default, handler: { (action) in
                Yes()
            }))
            
            ViewController.present(alert, animated: true, completion: { 
                alert.removeFromParentViewController()
            })
        }
    }
}









