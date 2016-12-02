//
//  shareMenu.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/27.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import Foundation
import SDWebImage
import MMPopupView
class DeeShareMenu {
    var shareDic = NSMutableDictionary()
    var stateHandler : SSDKShareStateChangedHandler?
//    func shareMenu() -> UIAlertController{
//        let alertView = UIAlertController.init(title: "分享到:", message: "选择你要分享的平台", preferredStyle: UIAlertControllerStyle.actionSheet)
//        let app = UIApplication.shared.delegate as! AppDelegate
//        for number in 0..<app.supportSharePlatform.count{
//
//            let action = UIAlertAction.init(title: app.nameArr[number] , style: UIAlertActionStyle.default, handler: { (action) in
//                let tmp = app.supportSharePlatform[number] as! SSDKPlatformType
//                ShareSDK.share(SSDKPlatformType.init(rawValue: tmp.rawValue)!, parameters: self.shareDic, onStateChanged: self.stateHandler)
//            })
//            alertView.addAction(action)
//        }
//        alertView.addAction(UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
//        return alertView
//    }

    func shareMMpopMenu() -> MMSheetView{
//        let alertView = UIAlertController.init(title: "分享到:", message: "选择你要分享的平台", preferredStyle: UIAlertControllerStyle.actionSheet)
        let app = UIApplication.shared.delegate as! AppDelegate
        var arr = [MMPopupItem]()
        for number in 0..<app.supportSharePlatform.count{
            let item = MMPopupItem.init()
            item.highlight = true
            item.title = app.nameArr[number]
            item.handler = {(num) in
                let tmp = app.supportSharePlatform[number] as! SSDKPlatformType
                ShareSDK.share(SSDKPlatformType.init(rawValue: tmp.rawValue)!, parameters: self.shareDic, onStateChanged: self.stateHandler)
            }
            arr.append(item)
        }
        let alertView = MMSheetView.init(title:  "选择你要分享的平台", items: arr)

        return alertView!
    }

    class func shareContent(shareThumImage:inout UIImage?,shareTitle:String?,shareDescr:String?,url:String?,shareType:SSDKContentType) -> NSMutableDictionary{
        let shareParames = NSMutableDictionary()
        shareParames.ssdkSetupShareParams(byText: shareDescr!,images : shareThumImage!,url : URL.init(string: url!)!,title : shareTitle!,type : shareType)

        return shareParames
    }

    class func stateHandle(controller:UIViewController,success:@escaping () -> Void,fail:@escaping () -> Void) -> SSDKShareStateChangedHandler {
        let state:SSDKShareStateChangedHandler = {(state,userData,content,err) in
            switch state{
            case SSDKResponseState.success:
                success()
                let alert = MMAlertView.init(confirmTitle: "分享成功!", detail: "Success to share!")
                alert?.show()

            case SSDKResponseState.fail:
                print("授权失败,错误描述:\(err.debugDescription)")
                let item1 = MMPopupItem.init()
                item1.title = "朕知道了"
                item1.highlight =  true
                let item2 = MMPopupItem.init()
                item2.title = "转文字分享"
                item2.handler = {(b) in
                    fail()

                }
                let arr = [item1,item2]
                let alert = MMAlertView.init(title: "分享失败", detail: "你可以尝试转为以下方式重新分享", items: arr)
                alert?.type = .alert
                alert?.show()

            case SSDKResponseState.cancel:  print("操作取消")
            default:
                break
            }
        }
        return state
    }


    class func messageFrame(msg:String = "保存成功!",controller:UIViewController){
        let Label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: UIwidth/2, height: 40))
        Label.center = CGPoint.init(x: UIwidth/2, y: UIheight - 100)
        Label.backgroundColor = UIColor.darkGray
        Label.textColor = UIColor.white
        Label.text = msg
        Label.font = UIFont.boldSystemFont(ofSize: 14)
        Label.layer.cornerRadius = 25
        Label.clipsToBounds = true
        Label.textAlignment = .center
        controller.view.addSubview(Label)
        UIView.animate(withDuration: 3, animations: {
            Label.alpha = 0
        }, completion: { b in
            Label.removeFromSuperview()
        })
    }


    class func getImage(url:String) -> UIImage{
        var data = NSData()
        var image = UIImage()
        SDWebImageManager.shared().cachedImageExists(for: URL.init(string: url), completion: { bool in
            if bool == true {
                print("存在缓存")
                let cacheKey = SDWebImageManager.shared().cacheKey(for: URL.init(string: url))
                if ((cacheKey?.lengthOfBytes(using: String.Encoding.unicode)) != nil) {
                    let cachePath = SDImageCache.shared().defaultCachePath(forKey: cacheKey)
                    if ((cachePath?.lengthOfBytes(using: String.Encoding.unicode)) != nil){
                        do {
                            try data = NSData.init(contentsOfFile: cachePath!)
                            image = UIImage.init(data: data as Data)!
                        } catch  {
                            print("未知错误 !")
                        }
                    }
                }
            }
            else{
                print("不存在缓存")
                image = UIImage.sd_image(with: try! Data.init(contentsOf: URL.init(string: url)!))!
            }
        })
        return image
    }


    class func showShankeMenu( Yes :@escaping ()->Void,No: @escaping ()->Void,ViewController:UIViewController,keepWarning:Bool){
        if keepWarning{
            let alert = UIAlertController.init(title: "开启摇一摇", message: "检测到你在摇晃,是否需要开启摇一摇分享功能?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction.init(title: "不再提醒", style: UIAlertActionStyle.cancel, handler: { (action) in
                No()
            }))
            alert.addAction(UIAlertAction.init(title: "下次提醒", style: UIAlertActionStyle.destructive, handler: { (action) in
            }))
            alert.addAction(UIAlertAction.init(title: "现在开启", style: UIAlertActionStyle.default, handler: { (action) in
                Yes()
            }))
            
            ViewController.present(alert, animated: true, completion: { 
                alert.removeFromParentViewController()
            })
            
        }
    }
}









