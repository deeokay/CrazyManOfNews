//
//  ChangePhotosViewController.swift
//  AimiHealth
//
//  Created by ivan on 17/2/27.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
import AFNetworking
import ZLPhotoBrowser
import CRMediaPickerController
class IVImageModel: NSObject {
    /*
     参数解释
     1. 要上传的图片
     2. 对应网站上[upload.php中]处理文件的字段
     3. 要保存在服务器上的[文件名]
     */
    static var image: UIImage? = nil
    static var field: String? = nil
    static var imageName: String? = nil
}

class ChangePhotosViewController: UIViewController,UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UICollectionViewDelegateFlowLayout,CRMediaPickerControllerDelegate {
    
    // CollectionView默认显示的图片数组
    var photoArray: Array<UIImage> = [UIImage.init(named: "add_circle")!]
    // 选中的图片的索引
    var selectedIndex: IndexPath = IndexPath(row: 0, section: 0)
    // 最后选中的头像的数据格式
    var finalPhotoData = Data()
    // 订制Cell的IdentifierID
    let cellID = "PhotoCell"
    // 是不是从注册页面进来的
    var justRegisted: Bool = false
    
    var userName: String = ""
    var password: String = ""

    @IBOutlet weak var collectView: UICollectionView!
    @IBOutlet weak var finishBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        // 数组的图片初始化完毕
        for index in 1...17 {
            
            photoArray.append(UIImage.init(named: "\(index)")!)
        }
        if self.justRegisted == false {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("关闭", comment: ""), style: .done, target: self, action: #selector(ChangePhotosViewController.iv_goBack))
        }
        
        // 下面按钮的点击事件
        self.finishBtn.addTarget(self, action: #selector(iv_finish), for: UIControlEvents.touchUpInside)
        
        self.configCollectionView()
        
        // 添加子视图
        self.view.addSubview(collectView)
        self.view.addSubview(finishBtn)
    }
    
    private func configCollectionView() {
        
        self.collectView.delegate = self
        self.collectView.dataSource = self
        self.collectView .register(UINib.init(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellID)
    }

    @objc private func iv_goBack() {
        // 未做修改，直接返回
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func iv_finish() {
        // 完成图片选择，把选中的图片上传到服务器，保存到UserDefault
        print("Finished.")
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let dic =  ["uid":uid] as NSDictionary
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.timeoutInterval = 10
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post("https://aimi.cupiday.com/avatar", parameters: dic, constructingBodyWith: { (data) in
            // 添加图片数据
            data.appendPart(withFileData: self.finalPhotoData, name: "avatar", fileName: ".png", mimeType: "file")
            
        }, progress: { (progress) in
            
        }, success: { (dataTask, data) in
            print("Succeed!")
            guard let json = try? JSONSerialization.jsonObject(with: data as! Data, options: .allowFragments) as! NSDictionary else{
                print("解析上传Json失败!")
                return
            }
            // 解析成功
            if json.object(forKey: "error") as! Int == 0{
                UserDefaults.standard.set(json.object(forKey: "avatar"), forKey: "userImage")
                
                if self.justRegisted == true {
                    // 如果是注册时
                    let alert = UIAlertController(title: NSLocalizedString("注册提示", comment: ""), message: NSLocalizedString("头像选择成功", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: NSLocalizedString("确定", comment: ""), style: .cancel, handler: { (action) in
                        let vc = LoginController()
                        vc.login(with: self.userName, password: self.password)
                        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    // 如果不是注册时
                    let alert = UIAlertController(title: NSLocalizedString("提示", comment: ""), message: NSLocalizedString("头像已经修改成功", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: NSLocalizedString("确定", comment: ""), style: .cancel, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                
                
            }
        }, failure: { (task, err) in
            
            let alert = UIAlertController(title: NSLocalizedString("提示", comment: ""), message: NSLocalizedString("头像未能正确修改~~(>_<)~~", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: NSLocalizedString("好吧", comment: ""), style: .cancel, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        })
        
    }
    
    // MARK: - CRMediaPickerControllerDelegate
    
    func crMediaPickerController(_ mediaPickerController: CRMediaPickerController!, didFinishPicking asset: ALAsset!, error: Error!) {
        
        IVImageModel.image = UIImage(cgImage:asset.thumbnail().takeUnretainedValue())
        self.finalPhotoData = UIImagePNGRepresentation(IVImageModel.image!)!
    }

    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: PhotoCollectionViewCell = self.collectView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PhotoCollectionViewCell
        cell.sizeToFit()
        cell.photoView.image = self.photoArray[indexPath.item]
        cell.gouXuanView.image = UIImage(named: "勾选")
        // ✔️按钮默认隐藏
        cell.gouXuanView.isHidden = true
        return cell
    
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 如果选取的不是之前的那张图片，把之前的那张图片的✔️取消
        if indexPath.row != selectedIndex.row {
            let cell: PhotoCollectionViewCell = (self.collectView.cellForItem(at: selectedIndex) as? PhotoCollectionViewCell)!
            cell.gouXuanView.isHidden = true
            // self.collectView.reloadData()
            selectedIndex = indexPath
//
        }
        // 第一个位置添加相册或者相机的头像
        if indexPath.row == 0 {
            let actionSheet = ZLPhotoActionSheet.init()
            actionSheet.maxSelectCount = 1
            actionSheet.maxPreviewCount = 20
            actionSheet.showPreviewPhoto(withSender: self, animate: true, last: nil, completion: { (images:[UIImage], nil) in
                // 保存唯一的那张照片
                IVImageModel.image = images.last!
                // 修改图片的大小为了方便上传
                /*
                let sizeChange = CGSize(width: 120, height: 120)
                UIGraphicsBeginImageContextWithOptions(sizeChange, false, 0.0)
                IVImageModel.image?.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
                IVImageModel.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                 */
                IVImageModel.image = IVImageModel.image?.iv_changeSize(to: CGSize.init(width: 120, height: 120), origin: CGPoint.zero)
                // 照片放在第二个位置上
                self.photoArray.insert(IVImageModel.image!, at: 1)
                // 初始化数据
                self.finalPhotoData = Data()
                self.finalPhotoData = UIImagePNGRepresentation(IVImageModel.image!)!
                self.collectView.reloadData()
            })
            // 新照片
        } else {
            // 选取预设的头像
            self.finalPhotoData = Data()
            let cell: PhotoCollectionViewCell = (self.collectView.cellForItem(at: indexPath) as? PhotoCollectionViewCell)!
            cell.gouXuanView.isHidden = false
            // 预设图片
            IVImageModel.image = self.photoArray[indexPath.item]
            self.finalPhotoData = UIImagePNGRepresentation(IVImageModel.image!)!
        }
        // 如果已经选取了图片，那么最下面的确认按钮就可以使用
        if IVImageModel.image != nil {
            self.finishBtn.isEnabled = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let length = UIScreen.main.bounds.size.width / 4 - 14
        return CGSize.init(width: length, height: length)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        
        switch buttonIndex {
            // 拍照
        case 0:
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            imagePicker.modalTransitionStyle = .crossDissolve
            self.present(imagePicker, animated: true, completion: nil)
            // 相册
        case 1:
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            imagePicker.modalTransitionStyle = .crossDissolve
            self.present(imagePicker, animated: true, completion: nil)
        default:
            break
        }
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        var image: UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
            image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.savePhoto(image: image, with: "userAvatar")
    }
    
    func savePhoto(image:UIImage, with imageName: String) {
        
        let imageData: Data = UIImagePNGRepresentation(image)!
        var documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        documentPath += imageName
        
        
        
        // Save to UserDefaults
        UserDefaults.standard.set(documentPath, forKey: "avatar")
        
        
        IVImageModel.image = UIImage(data: imageData as Data)!
        IVImageModel.field = "file"
        print(IVImageModel.imageName!)
        
        let dic: Dictionary = ["uid": UserDefaults.standard.object(forKey: "uid")]
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.timeoutInterval = 10
        manager.responseSerializer = AFHTTPResponseSerializer()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        manager.post("https://aimi.cupiday.com/avatar", parameters: dic, constructingBodyWith: { (data) in
            let imageData = UIImagePNGRepresentation(IVImageModel.image!)
            let imageFileName = IVImageModel.imageName;
            data.appendPart(withFileData: imageData!, name: "avatar", fileName: imageFileName!, mimeType: "image/png")
        }, progress: { (pro ) in
            
        }, success: { (dataTask, data) in
            
            guard let json = try? JSONSerialization.jsonObject(with: data as! Data, options: .allowFragments) as! NSDictionary else{
                print("解析上传Json失败!")
                return
            }
            if json.object(forKey: "error") as! Int == 0{
                UserDefaults.standard.set(json.object(forKey: "avatar"), forKey: "userImage")
                let alert: UIAlertController = UIAlertController(title: NSLocalizedString("提示", comment: ""), message: NSLocalizedString("头像已经修改成功", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                let action: UIAlertAction = UIAlertAction(title: NSLocalizedString("确定", comment: ""), style: .cancel, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            
        }, failure: { (task, err) in
            
            print(err)
        })

    }

}
