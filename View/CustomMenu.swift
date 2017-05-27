//
//  CustomMenu.swift
//  AimiHealth
//
//  Created by apple on 2017/2/28.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
class ActionModel{
    var title = String()
    var img = UIImage()
    var action = {Void()}
}
class shareModel{
    var shareImg = UIImage()
    var shareTitle = String()
    var shareUrl = String()
    var shareDesc = String()
    var shareType = UInt()
}
class CustomMenu: UIView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var customButton: UICollectionView!
    @IBOutlet weak var shareCV: UICollectionView!
    var actionArr = [ActionModel]()
    override func awakeFromNib() {
        self.shareCV.register(UINib.init(nibName: "CustomMenuCell", bundle: nil), forCellWithReuseIdentifier: "CustomMenuCell")
        self.customButton.register(UINib.init(nibName: "CustomMenuCell", bundle: nil), forCellWithReuseIdentifier: "CustomMenuCell")

    }
    var cancelAction = {Void()}
    @IBAction func cancelAction(_ sender: Any) {
        self.hideView { 
            self.cancelAction()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == shareCV{
            return 4
        }
        else{
            return actionArr.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomMenuCell", for: indexPath) as! CustomMenuCell
        if collectionView == shareCV{
        cell.btn.text = nameArr[indexPath.row]
        cell.img.image = UIImage.init(named: "\(nameArr[indexPath.row])")
        }
        else{
            let model = actionArr[indexPath.row]
            cell.img.image = model.img
            cell.btn.text = model.title
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = self.frame.height * 0.4 - 8
        return CGSize.init(width: height / 1.3, height: height)
    }
    
    
    func showView(view:CustomMenu,height:CGFloat,complete:@escaping ()->Void) -> Void{
        UIView.animate(withDuration: 0.5, animations: {
            view.mj_origin = CGPoint.init(x: 0, y:UIheight - height)
        }) { (com) in
            if com{
                complete()
            }
        }
    }
    func hideView(view:CustomMenu,complete:@escaping ()->Void) -> Void{
        UIView.animate(withDuration: 0.5, animations: {
            view.mj_origin = CGPoint.init(x: 0, y:UIheight)
        }) { (com) in
            if com{
                complete()
            }
        }
    }
    
    func showView(complete:@escaping ()->Void) -> Void{
        UIView.animate(withDuration: 0.5, animations: {
            self.mj_origin = CGPoint.init(x: 0, y:UIheight - self.mj_h)
        }) { (com) in
            if com{
                complete()
            }
        }
    }
    
    func hideView(complete:@escaping ()->Void) -> Void{
        UIView.animate(withDuration: 0.5, animations: {
            self.mj_origin = CGPoint.init(x: 0, y:UIheight)
        }) { (com) in
            if com{
                complete()
            }
        }
    }
    
    
    var handlingResult = {Void()}
    var loading = {Void()}
    var successToShareCallback = {Void()}
    var failToShareCallback = {Void()}
    var shareModel = ShareModel()
    var nameArr = ["微信好友","QQ","朋友圈","新浪微博","Twitter","Instagram","Whatsapp","Google+"]
    var supportSharePlatform = NSArray.init(objects: SSDKPlatformType.subTypeWechatSession,SSDKPlatformType.typeQQ,SSDKPlatformType.subTypeWechatTimeline,SSDKPlatformType.typeSinaWeibo,SSDKPlatformType.typeTwitter,SSDKPlatformType.typeInstagram,SSDKPlatformType.typeWhatsApp,SSDKPlatformType.typeGooglePlus )
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == shareCV
        {
            
            loading()
            let dic = NSMutableDictionary()
            switch indexPath.row {
            case 3://新浪微博
                dic.ssdkSetupSinaWeiboShareParams(byText: self.shareModel.shareText, title: self.shareModel.shareTitle, image: self.shareModel.shareImg, url: URL.init(string: self.shareModel.shareUrl), latitude: Double(), longitude: Double(), objectID: nil, type: self.shareModel.shareType)
            case 4:
                dic.ssdkSetupTwitterParams(byText: self.shareModel.shareText, images: self.shareModel.shareImg, latitude: Double(), longitude: Double(), type: .auto)
            default:
                dic.ssdkSetupShareParams(byText: self.shareModel.shareText, images: self.shareModel.shareImg, url: URL.init(string: self.shareModel.shareUrl), title: self.shareModel.shareTitle, type: self.shareModel.shareType)
            }
            dic.ssdkEnableUseClientShare()
            ShareSDK.share(self.supportSharePlatform[indexPath.row] as! SSDKPlatformType, parameters: dic, onStateChanged: { (state, dic, contentEntity, err) in
                self.handlingResult()
                switch state {
                case SSDKResponseState.success:
                    self.successToShareCallback()
                case SSDKResponseState.fail:
                    self.failToShareCallback()
                case SSDKResponseState.cancel:
                    self.failToShareCallback()
                default:
                    break
                }
                print("分享结果:",err?.localizedDescription)
            })
        }
        else{
            let model = actionArr[indexPath.row]
            model.action()
        }
    }

}
class ShareModel : NSObject{
    var shareText = String()
    var shareTitle = String()
    var shareUrl = String()
    var shareImg = UIImage()
    var shareType = SSDKContentType.auto
    override init() {
        print("生成分享模型!")
    }
    convenience init(text:String = "爱米 爱她 爱健康\n\(APP_URL)",title:String = "爱米 爱她 爱健康\n\(APP_URL)",url:String,img:UIImage,type:SSDKContentType) {
        self.init()
        self.shareText = text
        self.shareTitle = title
        self.shareUrl = url
        self.shareImg = img
        self.shareType = type
    }
    
}
