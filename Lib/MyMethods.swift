//
//  MyMethods.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/13.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import Foundation
import AFNetworking
import Kingfisher
import pop
class action:NSObject{
    var name:String = ""
    var delegate:UIViewController?
    var point : Any?
    var guidePic = UIImageView()
    var dic = [String:Bool]()
    init(picName:String,delegate:UIViewController) {
        self.name = picName
        self.delegate = delegate
    }
    func insertGuidePic() -> Void {
        self.dic = UserDefaults.standard.value(forKey: "guide") as! [String:Bool]
        guard dic[self.name] == true else{
            print("毋须加入引导的页面")
            return
        }
        delegate?.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        delegate?.navigationController?.navigationBar.shadowImage = UIImage()
        self.guidePic = UIImageView.init(frame: UIScreen.main.bounds)
        self.guidePic.image = UIImage.init(named: self.name)
        self.guidePic.isUserInteractionEnabled = true
        delegate?.view.addSubview(guidePic)
        let tap = UITapGestureRecognizer.init(target: self.point, action: #selector(self.closeGuidePic(tap:)))
        self.guidePic.addGestureRecognizer(tap)
    }
    
    func closeGuidePic(tap:UITapGestureRecognizer) -> Void {
        self.guidePic.removeFromSuperview()
        dic[self.name] = false
        UserDefaults.standard.setValue(self.dic, forKey: "guide")
        UserDefaults.standard.synchronize()

        
    }
}
class DeeRequest{
    class func requestGet(url:String,dic:NSDictionary,success: @escaping (_ data:Data)->Void,fail: @escaping (_ error:Error)->Void,Pro: @escaping (_ progress:Int64)->Void)-> Void{
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.cachePolicy = .useProtocolCachePolicy
        manager.requestSerializer.timeoutInterval = 15
        manager.responseSerializer = AFHTTPResponseSerializer()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        manager.get(url, parameters: dic, progress: {(p) in
        }, success: { (task, data) in
            success (data as! Data)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }) { (task, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            fail (error )
        }
    }
    
    class func requestPost(url:String,dic:NSDictionary,success: @escaping (_ data:Data)->Void,fail: @escaping (_ error:Error)->Void,Pro: @escaping (_ progress:Int64)->Void)-> Void{
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.cachePolicy = .useProtocolCachePolicy
        manager.requestSerializer.timeoutInterval = 15
        manager.responseSerializer = AFHTTPResponseSerializer()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        manager.post(url, parameters: dic, progress: {(p) in
        }, success: { (task, data) in
            success (data as! Data)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }) { (task, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            fail (error )
        }
    }
}


class DeeSetView:NSObject {
    class func showAnimate(controller:UIViewController,picName:String) {
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        imageView.center = CGPoint.init(x: UIwidth / 2, y: UIheight / 2)
        imageView.image = UIImage.init(named: picName)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = imageView.image?.iv_drawRectWithRoundedCorner(radius: UIheight * 0.6, size: CGSize.init(width: UIheight * 1.2, height: UIheight * 1.2))
        controller.view.addSubview(imageView)
        UIView.animate(withDuration: 1, animations: {
            imageView.bounds = CGRect.init(x: 0, y: 0, width: UIheight * 1.2, height: UIheight * 1.2)
            imageView.alpha = 0
            controller.view.alpha = 1
        }, completion: { (f) in
            if f{
                imageView.removeFromSuperview()
            }
        })
    }
    
    class func setAnimate(view:UIView,orginW:CGFloat,orginH:CGFloat,pointX:CGFloat,pointY:CGFloat,width:CGFloat,height:CGFloat,key:String) -> Void{
        let animate = POPSpringAnimation.init(propertyNamed: kPOPViewSize)
        animate?.toValue = NSValue.init(cgSize: CGSize.init(width: width, height: height))
        animate?.springBounciness = 15
        animate?.springSpeed = 6
        view.frame.size = CGSize.init(width: orginW, height: orginH)
        view.center.x = pointX
        view.center.y = pointY
        animate?.beginTime = CACurrentMediaTime()
        animate?.springBounciness = 10
        UIView.animate(withDuration: 0.5, animations: {
            view.pop_add(animate, forKey: key)
        }, completion: nil)
    }

    class func setCellAnimate(controller:UIViewController, view:UIView,image:UIImage,centerX:CGFloat,centerY:CGFloat,disapperX:CGFloat,disapperY:CGFloat,complete: @escaping ()->Void) -> Void{
        let imageView = UIImageView.init(image: image)
        imageView.bounds = CGRect.init(x: 0, y: 0, width: 50, height: 50)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.center.x = centerX
        imageView.center.y = centerY
        controller.view.addSubview(imageView)
        UIView.animate(withDuration: 0.3, animations: {
            imageView.bounds = CGRect.init(x: 0, y: 0, width: UIwidth, height: UIheight)
            view.isUserInteractionEnabled = false
            controller.tabBarController?.tabBar.isUserInteractionEnabled = false
        }) { (finish) in
            if finish{
                view.isUserInteractionEnabled = true
                controller.tabBarController?.tabBar.isUserInteractionEnabled = true
                imageView.removeFromSuperview()
                complete()
            }
        }
    }

    var sendCallBack = {Void()}
    var commentView = WriteComment()
    var bgView = UIView()
     func creatCommentView(controller:UIViewController) -> WriteComment{
        self.commentView = Bundle.main.loadNibNamed("WriteComment", owner: self, options: nil)?.first as! WriteComment
        self.bgView = UIView.init(frame: CGRect.init(x: 0, y: UIheight , width: UIwidth, height: UIwidth / 3))
        commentView.frame = bgView.bounds
        bgView.addSubview(commentView)
        commentView.contentMode = .scaleToFill
        controller.view.addSubview(bgView)
        commentView.sendAction = {
            self.sendCallBack()
            NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyboard(not:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeKeyboard(not:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        return commentView
    }

    func releaseKeyboardObserver() -> Void {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func closeKeyboard(not:Notification) -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView.mj_origin = CGPoint.init(x: 0, y: UIheight)
        }, completion: { (b) in
            if b{
                self.bgView.isHidden = true
            }
        })
    }
    func showKeyboard(not:Notification) -> Void {
        let rect = not.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        self.bgView.isHidden = false 
        UIView.animate(withDuration: 0.3) {
            self.bgView.mj_origin = CGPoint.init(x: 0, y: UIheight - rect.cgRectValue.height - UIwidth / 3)
            self.bgView.alpha = 1
        }
    }
}


