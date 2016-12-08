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
import CoreData
import MMPopupView
class ScrollPic: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, UIImagePickerControllerDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate {
    var showIndex : Int?
    var url : String?
    var shareMenu = MMSheetView()
    var commentsEvent = {Void()}
    @IBOutlet var VC: UICollectionView!
    var delegate : AppDelegate?
    var context : NSManagedObjectContext?
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = UIApplication.shared.delegate as! AppDelegate?
        context = delegate?.persistentContainer.viewContext
        self.navigationItem.title = "Picture Detail"
        menu = DeeShareMenu()
        self.shareMenu =  menu.shareMMpopMenu()

    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "scrollCell", for: indexPath) as! scrollCell
        cell.layer.borderWidth = 3
        cell.layer.masksToBounds = true
        let model = self.superVC?.picArr.object(at: indexPath.row) as! picModel
        var data = NSData()
        if model.isGif{
            cell.loading.startAnimating()
            DispatchQueue.global().async {
                let image = UIImage.animatedImage(withAnimatedGIFURL: URL.init(string: model.img!))
                DispatchQueue.main.async {
                    cell.img.image = image
                    cell.loading.stopAnimating()
                }
            }
        }
        else{
            SDWebImageManager.shared().cachedImageExists(for: URL.init(string: model.img!), completion: { bool in
                if bool == true {
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
                                cell.img.sd_setImage(with: URL.init(string: model.img!), completed: { (image, error, cacheTyple, url) in
                                    cell.img.sd_removeActivityIndicator()
                                })
                            }
                        }
                    }
                }
                else{
                    cell.img.sd_addActivityIndicator()
                    cell.img.sd_setImage(with: URL.init(string: model.img!), completed: { (image, error, cacheTyple, url) in
                        cell.img.sd_removeActivityIndicator()
                    })
                }
            })
        }
        cell.scView.zoomScale = 1
        return cell
    }
    var event = {Void()}
    func doubleTap(tap:UITapGestureRecognizer){
        self.event()
    }
    var cellImg:UIImageView?
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.cellImg
    }
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        self.cellImg?.center = scrollView.center
//    }


    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.superVC!.picArr.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIwidth, height: (UIheight - 84))
    }

    //MARK: 返回
    var superVC : Pictrues?

    @IBAction func backToWarehouse(_ sender:
        Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.VC.alpha = 0
        self.toolBar.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        VC.scrollToItem(at: IndexPath.init(row: showIndex!, section: 0), at: .centeredHorizontally, animated: false)
        UIView.animate(withDuration: 0.5, animations: {
            self.VC.alpha = 1
        }, completion: {(b) in
            if b{
                let p = (self.VC.indexPathsForVisibleItems.first?.row)
                self.solveRow(row: p!)
                UIView.animate(withDuration: 0.5, animations: {
                    self.toolBar.alpha = 1
                })
            }
        })
    }



    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let p = (self.VC.indexPathsForVisibleItems.first?.row)
        {
            solveRow(row: p)
        }
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
        if cell?.img.image != nil{
            UIImageWriteToSavedPhotosAlbum((cell?.img.image!)!, self, #selector(self.image(image:didFinishSavingWithErrorerror:contextInfo:)), nil)
        }
    }

    @objc private func image(image: UIImage, didFinishSavingWithErrorerror:NSError?,contextInfo:AnyObject) {
        if (didFinishSavingWithErrorerror == nil){
            DeeShareMenu.messageFrame(controller: self)
        }
        else{
            print(didFinishSavingWithErrorerror!)
        }
    }
    var menu = DeeShareMenu()
    var contentType = SSDKContentType.image
    @IBAction func sharePic(_ sender: AnyObject) {
        let model = self.superVC?.picArr.object(at: (VC.indexPathsForVisibleItems.first?.row)!) as! picModel
        let cell = self.VC.visibleCells.first as! scrollCell
        var img = cell.img.image
        self.menu.shareDic = DeeShareMenu.shareContent(shareThumImage: &img, shareTitle: model.title, shareDescr: model.ct, url: model.img, shareType: self.contentType)
        menu.stateHandler = DeeShareMenu.stateHandle(controller: self, success: {
            if self.contentType == SSDKContentType.text{
                self.contentType = SSDKContentType.image
            }
        }, fail: {
            self.contentType = SSDKContentType.text
        })
        self.shareMenu.show()
    }

    //MARK: 摇一摇分享
    var keepWarning = true
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake{
            if UserDefaults.standard.bool(forKey: "shankeShare"){
                sharePic(self as UIViewController)
            }
            else{
                DeeShareMenu.showShankeMenu(Yes: {
                    UserDefaults.standard.set(true, forKey: "shankeShare")
                }, No: {
                    self.keepWarning = false
                }, ViewController: self, keepWarning: keepWarning)
            }
        }
    }

    //MARK: 初始化行标和工具栏
    func solveRow(row:Int) -> Void {
        self.navigationItem.title = "第\(row + 1)张 / 共\(self.superVC!.picArr.count)张"
        let model = self.superVC?.picArr.object(at: row) as! picModel
        if model.isGif{
            self.isGif.tintColor = UIColor.blue
        }
        self.unlikeBtn.tintColor = UIColor.lightGray
        self.likeBtn.tintColor = UIColor.lightGray
        self.unlikeBtn.isEnabled = true
        self.likeBtn.isEnabled = true
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Model")
        let entity = NSEntityDescription.entity(forEntityName: "Model", in: context!)
        request.entity = entity
        let arr = try! context?.fetch(request)
        for i in arr!{
            let tmp = i as! Model
            if tmp.id == model.id!{
                if tmp.isLike{
                    self.unlikeBtn.isEnabled = false
                    self.likeBtn.tintColor = UIColor.black
                    self.likeBtn.isEnabled = true
                }
                else{
                    self.unlikeBtn.isEnabled = true
                    self.unlikeBtn.tintColor = UIColor.black
                    self.likeBtn.isEnabled = false
                }
                continue
            }
        }
        let cell = self.VC.visibleCells.first as! scrollCell
        self.cellImg = cell.img
        cell.imgTitle.text = model.title
        cell.scView.contentSize = CGSize.init(width: cell.img.frame.width, height: cell.img.frame.height)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.doubleTap(tap:)))
        tap.numberOfTapsRequired = 2
        self.event = {
            if cell.scView.zoomScale == 2{
                cell.scView.contentSize = CGSize.init(width: cell.img.frame.width, height: cell.img.frame.height)
                cell.scView.zoomScale = 1
            }
            else{
                cell.scView.zoomScale = 2
            }
        }
        cell.img.addGestureRecognizer(tap)
    }


    //MARK: 点赞
    @IBAction func likeClick(_ sender: Any) {
        let p = self.VC.indexPathsForVisibleItems.first!.row
        let model = self.superVC?.picArr.object(at: p) as! picModel
        if self.likeBtn.tintColor != UIColor.black{
            let entity = NSEntityDescription.insertNewObject(forEntityName: "Model", into: context!)
            entity.setValue(1, forKey: "isLike")
            entity.setValue(model.id!, forKey: "id")
            entity.setValue(model.img!, forKey: "url")
            entity.setValue(model.title!, forKey: "title")
            entity.setValue(model.isGif, forKey: "isGif")
            do {
                try context?.save()
                DeeShareMenu.messageFrame(msg: "嘿嘿嘿我知道你会喜欢的!", controller: self)
                self.likeBtn.tintColor = UIColor.black
                self.unlikeBtn.isEnabled = false
            } catch let err as NSError {
                print("点赞失败!",err)
                DeeShareMenu.messageFrame(msg: "哎哟,点like失败哦!", controller: self)
                self.likeBtn.tintColor = UIColor.lightGray
            }
        }
    }

    //MARK: 点踩
    @IBAction func unlikeClick(_ sender: Any) {
        let p = self.VC.indexPathsForVisibleItems.first!.row
        let model = self.superVC?.picArr.object(at: p) as! picModel
        if self.unlikeBtn.tintColor != UIColor.black{
            let entity = NSEntityDescription.insertNewObject(forEntityName: "Model", into: context!)
            entity.setValue(0, forKey: "isLike")
            entity.setValue(model.id!, forKey: "id")
            entity.setValue(model.img!, forKey: "url")
            entity.setValue(model.title!, forKey: "title")
            entity.setValue(model.isGif, forKey: "isGif")
            do {
                try context?.save()
                self.unlikeBtn.tintColor = UIColor.black
                self.likeBtn.isEnabled = false
                DeeShareMenu.messageFrame(msg: "我替你扔到黑名单里啦!", controller: self)
            } catch let err as NSError {
                print("点踩失败!",err)
                DeeShareMenu.messageFrame(msg: "失败~看来不让你讨厌啊!", controller: self)
                self.unlikeBtn.tintColor = UIColor.lightGray
            }
        }
    }

    @IBOutlet var unlikeBtn: UIBarButtonItem!
    @IBOutlet var likeBtn: UIBarButtonItem!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var isGif: UIBarButtonItem!

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.toolBar.isUserInteractionEnabled = false
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.toolBar.isUserInteractionEnabled = true
    }

    
}
