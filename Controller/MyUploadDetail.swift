//
//  MyUploadDetail.swift
//  AimiHealth
//
//  Created by apple on 2016/12/29.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit
import ZLPhotoBrowser
import AFNetworking
import MMPopupView
import AssetsLibrary
import CoreLocation
class MyUploadDetail: HideTabbarController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate {
    @IBOutlet weak var uploadBtn: UIButton!
    var picArr = [UIImage]()

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var CV: UICollectionView!
    @IBOutlet weak var desc: UITextField!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.CV.delegate = self
        self.CV.dataSource = self
        self.desc.delegate = self
        self.desc.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArr.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "uploadPicCell", for: indexPath) as! uploadPicCell
        if indexPath.row == picArr.count{
            cell.pic.image = UIImage.init(named: "add_circle")
        }
        else{
            cell.pic.image = picArr[indexPath.row]
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: UIwidth / 3 - 15, height: UIwidth / 3 - 15)
    }


    func selectPictures() -> Void {
            let mediaType = AVMediaTypeVideo
            let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: mediaType)
            if authStatus == .restricted || authStatus == .denied {
                let errorStr = "你的相机没有打开,无法拍摄照片,请打开'设置-隐私-相机',找到'爱米健康'后进行设置"
                let item1 = MMPopupItem.init()
                item1.title = NSLocalizedString("确定", comment: "")
                let item2 = MMPopupItem.init()
                item2.title = NSLocalizedString("设置", comment: "")
                item2.handler = {(index) in
                    let settingUrl = URL(string: UIApplicationOpenSettingsURLString)!
                    if UIApplication.shared.canOpenURL(settingUrl)
                    {
                        UIApplication.shared.openURL(settingUrl)
                    }
                }
                let alert = MMAlertView.init(title: "提示", detail: errorStr, items: [item1, item2])
                alert?.show()
                return
            }
        let authStatus2 = ALAssetsLibrary.authorizationStatus()
        if authStatus2 == .denied {
            let errorStr2 = "没有权限访问你的图库,请打开'设置-隐私-图库',找到'爱米健康'后进行设置"
            let item1 = MMPopupItem.init()
            item1.title = NSLocalizedString("确定", comment: "")
            let item2 = MMPopupItem.init()
            item2.title = NSLocalizedString("设置", comment: "")
            item2.handler = {(index) in
                let settingUrl = URL(string: UIApplicationOpenSettingsURLString)!
                if UIApplication.shared.canOpenURL(settingUrl)
                {
                    UIApplication.shared.openURL(settingUrl)
                }
            }
            let alert = MMAlertView.init(title: "提示", detail: errorStr2, items: [item1, item2])
            alert?.show()
            return
        }

        let actionSheet = ZLPhotoActionSheet.init()
        actionSheet.maxSelectCount = 20
        actionSheet.maxPreviewCount = 20
        actionSheet.showPreviewPhoto(withSender: self, animate: true, last: nil) { (images:[UIImage], nil) in
            self.picArr = images
            self.CV.reloadData()
            self.uploadBtn.isEnabled = true
            self.uploadBtn.backgroundColor = UIColor.init(red: 82/255, green: 171/255, blue: 244/255, alpha: 1)
        }
        
    }

    var openWarning = true
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if openWarning{
            let ok = MMPopupItem.init()
            ok.title = "本宫知道了!"
            ok.handler = { (num) in
                self.selectPictures()
            }
            let NotWarning = MMPopupItem.init()
            NotWarning.title = "不再提示"
            NotWarning.handler = { (num) in
                self.openWarning = false
                self.selectPictures()
            }
            let alert = MMAlertView.init(title: "温馨提示", detail: "上集图集照片数量不能少于五张,否则会直接拒审哦!", items: [ok,NotWarning])
            alert?.show()
        }
        else{
            self.selectPictures()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    var p:Float = 0{
        didSet{
            DispatchQueue.main.async {
                self.progressView.progress = self.p
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
    }

    @IBAction func choosePic(_ sender: Any) {
        if picArr.count >= 5 && self.desc.text! != ""{
            let stateMent = UIAlertController.init(title: NSLocalizedString("声明", comment: ""), message: NSLocalizedString("请确认上传图片没有淫秽、色情、暴力、血腥内容", comment: ""), preferredStyle: .alert)
            stateMent.addAction(UIAlertAction.init(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil))
            stateMent.addAction(UIAlertAction.init(title: NSLocalizedString("确认并上传", comment: ""), style: .default, handler: { (action) in
                self.uploadBtn.isEnabled = false
                self.uploadBtn.setTitle(NSLocalizedString("上传中,请勿关闭...", comment: ""), for: .disabled)
                self.uploadBtn.backgroundColor = UIColor.gray
                //self.loading.startAnimating()
                
                self.showHud(in: self.view, hint: "上传中...", yOffset: 0)
                let uid = UserDefaults.standard.integer(forKey: "uid")
                let dic =  ["uid":uid,"title":self.desc.text!] as NSDictionary
                AimiFunction.checkToken(success: {
                    let manager = AFHTTPSessionManager()
                    manager.requestSerializer.timeoutInterval = 10
                    manager.responseSerializer = AFHTTPResponseSerializer()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    manager.post("https://aimi.cupiday.com/user_publish_images", parameters: dic, constructingBodyWith: { (data) in
                        for i in self.picArr{
                            let imageData = UIImagePNGRepresentation(i)
                            data.appendPart(withFileData: imageData!, name: "files[]", fileName: ".png", mimeType: "image/png")
                        }
                    }, progress: { (pro ) in
                        self.p = Float(pro.completedUnitCount)/Float(pro.totalUnitCount)
                    }, success: { (dataTask, data) in
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        guard let json = try? JSONSerialization.jsonObject(with: data as! Data, options: .allowFragments) as! NSDictionary else{
                            print("解析上传图集Json失败!")
                            return
                        }
                        if json.object(forKey: "error") as! Int == 0{
                            DeeShareMenu.messageFrame(msg: NSLocalizedString("上传完成!", comment: ""), view: self.view)
                            self.picArr.removeAll()
                            self.CV.reloadData()
                            //self.loading.stopAnimating()
                            self.hideHud()
                            self.progressView.progress = 0
                            let alert = UIAlertController.init(title: NSLocalizedString("温馨提示", comment: ""), message: NSLocalizedString("上传成功", comment: ""), preferredStyle: .alert)
                            alert.addAction(UIAlertAction.init(title: NSLocalizedString("返回", comment: ""), style: .default, handler: { (action) in
                                _ = self.navigationController?.popViewController(animated: true)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }

                    }, failure: { (task, err) in
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("上传失败!", comment: ""), view: self.view)
                        //self.loading.stopAnimating()
                        self.hideHud()
                        self.uploadBtn.isEnabled = true
                        self.uploadBtn.setTitle(NSLocalizedString("上传图集", comment: ""), for: .normal)
                        print("上传失败!",err.localizedDescription)
                    })

                }, fail: {
                    print("请求上传图片接口失败!")
                }, controller: self)
            }))
            self.present(stateMent, animated: true, completion: nil)

        }
        else{
            let alert = UIAlertController.init(title: "温馨提示", message: "图片必须多于5张,并且标题不能为空", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "本宫知道了", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
