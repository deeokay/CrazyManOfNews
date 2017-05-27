//
//  uploadVideo.swift
//  AimiHealth
//
//  Created by apple on 2017/2/17.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
import CRMediaPickerController
import AFNetworking
import MMPopupView
import AVFoundation

class uploadVideo: HideTabbarController,UITextFieldDelegate,CRMediaPickerControllerDelegate {

    var pickerView = CRMediaPickerController()
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var desc: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView = CRMediaPickerController.init()
        pickerView.delegate = self
        pickerView.cameraCaptureMode = .video
        pickerView.mediaType = .video
        pickerView.videoQualityType = .typeIFrame1280x720
        pickerView.videoMaximumDuration = 300.0
        pickerView.allowsEditing = true
        self.upload.isEnabled = false
        self.desc.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var p:Float = 0{
        didSet{
            DispatchQueue.main.async {
                self.progressView.progress = self.p
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.desc.resignFirstResponder()
        return true
    }

    @IBOutlet weak var upload: UIButton!
    @IBAction func commit(_ sender: Any) {
        if self.desc.text! != ""{
            let stateMent = UIAlertController.init(title: NSLocalizedString("声明", comment: ""), message: NSLocalizedString("请确认上传图片没有淫秽、色情、暴力、血腥内容", comment: ""), preferredStyle: .alert)
            stateMent.addAction(UIAlertAction.init(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil))
            stateMent.addAction(UIAlertAction.init(title: NSLocalizedString("确认并上传", comment: ""), style: .default, handler: { (action) in
                self.upload.isEnabled = false
                self.upload.setTitle(NSLocalizedString("上传中,请勿关闭...", comment: ""), for: .normal)
                self.upload.backgroundColor = UIColor.gray
                //self.loading.startAnimating()
                self.showHud(in: self.view, hint: "上传中...", yOffset: 0)
                let uid = UserDefaults.standard.integer(forKey: "uid")
                let dic =  ["uid":uid,"title":self.desc.text!] as NSDictionary
                let manager = AFHTTPSessionManager()
                manager.requestSerializer.timeoutInterval = 10
                manager.responseSerializer = AFHTTPResponseSerializer()
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                manager.post("https://aimi.cupiday.com/user_publish_video", parameters: dic, constructingBodyWith: { (data) in
                    data.appendPart(withFileData: self.thumbNail, name: "files[]", fileName: ".png", mimeType: "file")
                    data.appendPart(withFileData: self.videoData, name: "files[]", fileName: ".mp4", mimeType: "file")

                }, progress: { (pro ) in
                    self.p = Float(pro.completedUnitCount)/Float(pro.totalUnitCount)
                }, success: { (dataTask, data) in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    guard let json = try? JSONSerialization.jsonObject(with: data as! Data, options: .allowFragments) as! NSDictionary else{
                        print("解析上传视频Json失败!")
                        return
                    }
                    if json.object(forKey: "error") as! Int == 0{
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("上传完成!", comment: ""), view: self.view)
                        //self.loading.stopAnimating()
                        self.hideHud()
                        self.progressView.progress = 0
                        self.upload.isEnabled = false
                        self.upload.backgroundColor = UIColor.gray
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
                    self.upload.isEnabled = true
                    self.upload.setTitle(NSLocalizedString("上传视频", comment: ""), for: .normal)
                    self.upload.isEnabled = false
                    self.upload.backgroundColor = UIColor.gray
                })
            }))
            self.present(stateMent, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController.init(title: NSLocalizedString("温馨提示", comment: ""), message: NSLocalizedString("标题不能为空", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("本宫知道了", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func chooseVideo(_ sender: Any) {
        let camera = MMPopupItem.init()
        camera.title = "拍摄视频"
        camera.handler = { (action) in
            let mediaType = AVMediaTypeVideo
            let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: mediaType)
            if authStatus == .restricted || authStatus == .denied {
                let errorStr = "你的相机没有打开,无法拍摄视频,请打开'设置-隐私-相机',找到'爱米健康'后进行设置"
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
                return;
            }
            self.pickerView.sourceType = .camera
            self.pickerView.show()
        }
        let photoLibrary = MMPopupItem.init()
        photoLibrary.title = "从相册选择"
        photoLibrary.handler = { (action) in
            let authStatus = ALAssetsLibrary.authorizationStatus()
            if authStatus == .denied {
                let errorStr = "没有权限访问你的图库,请打开'设置-隐私-图库',找到'爱米健康'后进行设置"
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
            self.pickerView.sourceType = .photoLibrary
            self.pickerView.show()
        }
        let uploadWay = MMSheetView.init(title: "获取视频方式", items: [camera,photoLibrary])
        uploadWay?.show()
    }

    var videoData = Data()
    var thumbNail = Data()
    func crMediaPickerController(_ mediaPickerController: CRMediaPickerController!, didFinishPicking asset: ALAsset!, error: Error!) {
        let representation =  asset.defaultRepresentation()
        let imageBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int((representation?.size())!))
        let bufferSize = representation?.getBytes(imageBuffer, fromOffset: Int64(0),length: Int((representation?.size())!), error: nil)
        self.videoData = NSData(bytesNoCopy:imageBuffer,length:bufferSize!, freeWhenDone:true) as Data
        let img = asset.thumbnail().retain().takeUnretainedValue()
        let image = UIImage.init(cgImage: img)
        self.img.image = image
        self.thumbNail = UIImagePNGRepresentation(image)!
        self.upload.isEnabled = true
        self.upload.isEnabled = true
        self.upload.backgroundColor = UIColor.init(red: 82/255, green: 171/255, blue: 244/255, alpha: 1)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

}
