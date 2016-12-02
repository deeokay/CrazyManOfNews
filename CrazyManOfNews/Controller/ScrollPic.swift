//
//  ScrollPic.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/14.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import UIImage_animatedGif
import MJRefresh
import SDWebImage
class ScrollPic: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate {
    var showIndex : Int?
    var url : String?
    var shareMenu = UIAlertController()
    var commentsEvent = {Void()}
    var likeEvent = {Void()}
    var unlikeEvent = {Void()}
    @IBOutlet var VC: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Picture Detail"
        menu = DeeShareMenu()
        self.shareMenu =  menu.shareMenu()
        UIApplication.shared.applicationSupportsShakeToEdit = true
        self.becomeFirstResponder()
    }

    var finish = UILabel()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "scrollCell", for: indexPath) as! scrollCell
        let model = self.superVC?.picArr.object(at: indexPath.row) as! picModel
        var data = NSData()
        SDWebImageManager.shared().cachedImageExists(for: URL.init(string: model.img!), completion: { bool in
            if bool == true {
                print("存在缓存")
                let cacheKey = SDWebImageManager.shared().cacheKey(for: URL.init(string: model.img!))
                if ((cacheKey?.lengthOfBytes(using: String.Encoding.unicode)) != nil) {
                    let cachePath = SDImageCache.shared().defaultCachePath(forKey: cacheKey)
                    if ((cachePath?.lengthOfBytes(using: String.Encoding.unicode)) != nil){
                        do {
                            try data = NSData.init(contentsOfFile: cachePath!)
                            cell.img.sd_addActivityIndicator()
                            cell.img.image = UIImage.init(data: data as Data)
                            cell.img.sd_removeActivityIndicator()
                        } catch  {
                            print("未知错误 !")

                        }
                    }
                }
            }
            else{
                print("不存在缓存")
                cell.img.sd_addActivityIndicator()
                cell.img.sd_setImage(with: URL.init(string: model.img!), completed: { (image, error, cacheTyple, url) in
                    cell.img.sd_removeActivityIndicator()
                })

            }
        })
        cell.scView.contentSize = cell.img.frame.size
        cell.imgTitle.text = model.title
        return cell
    }

    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.superVC!.picArr.count
    }

    //MARK: 返回
    var superVC : Pictrues?
    @IBAction func backToPictures(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.VC.alpha = 0
    }


    override func viewDidAppear(_ animated: Bool) {
        VC.scrollToItem(at: IndexPath.init(row: showIndex!, section: 0), at: .centeredHorizontally, animated: false)
        UIView.animate(withDuration: 1, animations: {
            self.VC.alpha = 1
        }, completion: {(b) in
            if b{
                UIView.animate(withDuration: 0.5, animations: { 
                    self.toolBar.isHidden = false
                })
            }
        })
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        return CGSize.init(width: width, height: height - 40)
    }


    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == (self.superVC?.picArr.count)! - 1 {
            superVC?.loadPICs(completionBlock: {
                self.superVC?.pageCnt += 1
                self.VC.reloadData()
            })
        }
    }
    @IBAction func savePhoto(_ sender: AnyObject) {
        let cell = self.VC.visibleCells.first as? scrollCell
        UIImageWriteToSavedPhotosAlbum((cell?.img.image!)!, self, #selector(self.image(image:didFinishSavingWithErrorerror:contextInfo:)), nil)
    }
    @objc private func image(image: UIImage, didFinishSavingWithErrorerror:NSError?,contextInfo:AnyObject) {
        if (didFinishSavingWithErrorerror == nil){
            finish = DeeShareMenu.messageFrame(Label: &finish)
            finish.alpha = 1
            self.view.addSubview(finish)
            UIView.animate(withDuration: 2, animations: {
                self.finish.alpha = 0
            }, completion: { (bool) in
                self.finish.removeFromSuperview()
            })
            print("保存成功!")
        }
        else{
            print(didFinishSavingWithErrorerror!)
        }
    }
    var menu = DeeShareMenu()
    var contentType = SSDKContentType.image
    @IBAction func sharePic(_ sender: AnyObject) {
        let model = self.superVC?.picArr.object(at: (VC.indexPathsForVisibleItems.first?.row)!) as! picModel
        var img = UIImage.animatedImage(withAnimatedGIFURL: URL.init(string: model.img!))
        menu.shareDic = DeeShareMenu.shareContent(shareThumImage: &img, shareTitle: model.title, shareDescr: model.ct, url: model.img, shareType: contentType)
        menu.stateHandler = DeeShareMenu.stateHandle(controller: self, success: {
            if self.contentType == SSDKContentType.text{
                self.contentType = SSDKContentType.image
            }
        }, fail: {
            self.contentType = SSDKContentType.text
        })
        self.present(shareMenu, animated: true, completion: nil)
    }

    //MARK: 摇一摇分享
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake{
            if shareShare{
                sharePic(self as UIViewController)
            }
            else{
                DeeShareMenu.showShankeMenu(Yes: {
                    shareShare = true
                }, No: {
                    self.keepWarning = false
                }, ViewController: self, keepWarning: keepWarning)
            }
        }

    }

    @IBAction func likeClick(_ sender: Any) {
    }
    var keepWarning = true

    @IBAction func unlikeClick(_ sender: Any) {
    }

    @IBAction func commentsClick(_ sender: Any) {
    }

    @IBOutlet var unlikeBtn: UIBarButtonItem!
    @IBOutlet var likeBtn: UIBarButtonItem!
    @IBOutlet var commentsBtn: UIBarButtonItem!

    @IBOutlet var toolBar: UIToolbar!

    
}
