//
//  Mishow.swift
//  AimiHealth
//
//  Created by apple on 2016/12/9.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit
import GPUImage
import Kingfisher
import MJRefresh
import AFNetworking
import pop
class Mishow: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIViewControllerPreviewingDelegate  {
    @IBOutlet weak var CV: UICollectionView!
    var gpuImage = GPUImagePicture()
    var cachePic = NSMutableArray()
    var cacheVideo = NSMutableArray()
    var uid = UserDefaults.standard.integer(forKey: "uid")
    override func viewDidLoad() {
        super.viewDidLoad()
        let header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: nil)
        header?.setTitle(NSLocalizedString("用力拉用力拉!!!", comment: ""), for: .idle)
        header?.setTitle(NSLocalizedString("没有任何数据可以刷新!!!", comment: ""), for: .noMoreData)
        header?.setTitle(NSLocalizedString("服务器都快炸了!!!", comment: ""), for: .refreshing)
        header?.setTitle(NSLocalizedString("一松手就洗个脸!!!", comment: ""), for: .pulling)
        header?.isAutomaticallyChangeAlpha = true
        header?.refreshingBlock = {
            if AFNetworkReachabilityManager.shared().networkReachabilityStatus.rawValue != 0{
                self.picPageCount = 1
                self.videoPageCount = 1
                self.pictureArr.removeAll()
                self.videoArr.removeAll()
                self.resetLoad = false
                self.requestPic = false
                self.requestVideo = false
                self.created = false
                self.loadPictures()
                self.loadVideos()
                self.CV.mj_header.endRefreshing()
                self.cachePic.removeAllObjects()
                self.cacheVideo.removeAllObjects()
                self.isLoaded = true
                
            }
            else{
                DeeShareMenu.messageFrame(msg: NSLocalizedString("请检查网络!", comment: ""), view: self.view)
                self.CV.mj_header.endRefreshing()
            }
        }
        CV.mj_header = header
        let footer = MJRefreshAutoNormalFooter.init {
            if self.picPageCount == 1 && self.videoPageCount == 1{
                self.videoArr.removeAll()
                self.pictureArr.removeAll()
                self.resetLoad = false
            }
            self.loadPictures()
            self.loadVideos()
            self.requestPic = false
            self.requestVideo = false
            self.created = false
            self.CV.mj_footer.endRefreshing()
        }
        footer?.setTitle(NSLocalizedString("推我上去看天下!", comment: ""), for: .willRefresh)
        footer?.setTitle(NSLocalizedString("别眨眼!!!", comment: ""), for: .refreshing)
        footer?.setTitle(NSLocalizedString("放手也是爱!过后我还在!", comment: ""), for: .pulling)
        self.CV.mj_footer = footer
        let bar = self.tabBarController as! Tabbar
        bar.action3 = {
            if self.CV.mj_header.isRefreshing() {
                return
            } else {
                if bar.selectedIndex == 1{
//                    if self.modelArr.count != 0{
//                        self.CV.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: UICollectionViewScrollPosition.top, animated: false)
//                    }
                    self.CV.mj_header.beginRefreshing()
                    self.CV.mj_footer.resetNoMoreData()
                }
            }
        }
        
        if let arr_pictures = UserDefaults.standard.value(forKey: MishowCache_pictures) as? NSMutableArray{
            print("解析图片缓存")
            for i in arr_pictures{
                let tmp = i as! NSDictionary
                let model = PictureModel()
                model.setValuesForKeys(tmp as! [String: AnyObject])
                self.pictureArr.append(model)
            }
        }
        if let arr_videos = UserDefaults.standard.value(forKey: MishowCache_videos) as? NSMutableArray{
            print("解析视频缓存")
            for i in arr_videos{
                let tmp = i as! NSDictionary
                let model = VideoModel()
                model.setValuesForKeys(tmp as! [String: AnyObject])
                self.videoArr.append(model)
            }
        }
        if self.videoArr.count == 0 && self.pictureArr.count == 0{
            self.CV.mj_header.beginRefreshing()
            print("没有缓存,刷新数据!")
        }
        else{
            creatArr()
            print("发现缓存,合并缓存!")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIwidth/3 - 1, height: UIwidth/3 - 1)
    }
    
    func register3D_Cell(cell:UICollectionViewCell) -> Void {
        if #available(iOS 9.0, *) {
            if self.traitCollection.forceTouchCapability == UIForceTouchCapability.available{
                self.registerForPreviewing(with: self, sourceView: cell)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowPic", for: indexPath) as! ShowPic
        self.register3D_Cell(cell: cell)
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.userImg.layer.cornerRadius = (UIwidth/3 - 9) * 0.1
        let obj = modelArr.object(at: indexPath.row) as! DeeMedia
        cell.userImg.kf.setImage(with: URL.init(string: obj.avatar))
        cell.userNickname.text = obj.username
        if obj.isKind(of: PictureModel.self){
            let model = obj as! PictureModel
            let imgUrl = model.url.firstObject as! String
            cell.img.kf.setImage(with: URL.init(string: imgUrl), placeholder: UIImage.init(named: "logo"), options: nil, progressBlock: nil, completionHandler: { (img, err, cache, url) in
            })
            cell.playBtn.isHidden = true
        }
        else{
            let model = obj as! VideoModel
            cell.playBtn.isHidden = false
            cell.img.kf.setImage(with: URL.init(string: model.imgUrl), placeholder: UIImage.init(named: "logo"), options: nil, progressBlock: nil, completionHandler: { (img, err, cache, url) in
            })
        }
        return cell
    }
    
    
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.backgroundColor = UIColor.black
        let obj = self.modelArr.object(at: indexPath.row) as! DeeMedia
        if obj.isKind(of: PictureModel.self){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PicDetail") as! PicDetail
            vc.delegate = self
            vc.model = obj as! PictureModel
            let nav = UINavigationController.init(rootViewController: vc)
            self.present(nav, animated: false, completion: {
                DispatchQueue.main.async {
                    _ = AimiData.addDictionaryToCoreData(aid: obj.iid, type: 2, dic: obj.mj_keyValues())
                }
            })
        }
        else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoDetail") as! VideoDetail
            vc.model = obj as! VideoModel
            vc.delegate = self
            let nav = UINavigationController.init(rootViewController: vc)
            self.present(nav, animated: false, completion: {
                DispatchQueue.main.async {
                    _ = AimiData.addDictionaryToCoreData(aid: obj.vid, type: 3, dic: obj.mj_keyValues())
                }
            })
        }
    }
    
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.view.backgroundColor = UIColor.black
        let indexPath = self.CV.indexPath(for: previewingContext.sourceView as! UICollectionViewCell)
        let obj = self.modelArr.object(at: (indexPath?.row)!) as! DeeMedia
        let nav = UINavigationController.init(rootViewController: viewControllerToCommit)
        if obj.isKind(of: PictureModel.self){
            self.present(nav, animated: false, completion: {
                DispatchQueue.main.async {
                    _ = AimiData.addDictionaryToCoreData(aid: obj.iid, type: 2, dic: obj.mj_keyValues())
                }
            })
        }
            else{
                self.present(nav, animated: false, completion: {
                    DispatchQueue.main.async {
                        _ = AimiData.addDictionaryToCoreData(aid: obj.vid, type: 3, dic: obj.mj_keyValues())
                    }
                })
        }
    }

    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        self.view.backgroundColor = UIColor.black
        let indexPath = self.CV.indexPath(for: previewingContext.sourceView as! UICollectionViewCell)
        let obj = self.modelArr.object(at: (indexPath?.row)!) as! DeeMedia
        if obj.isKind(of: PictureModel.self){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PicDetail") as! PicDetail
            vc.delegate = self
            vc.model = obj as! PictureModel
            return vc
        }
        else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoDetail") as! VideoDetail
            vc.model = obj as! VideoModel
            vc.delegate = self
            return vc
        }
    }


    
    var picPageCount = 1
    var requestPic = false
    var pictureArr = [PictureModel]()
    var lastpage = Int()
    func loadPictures() -> Void {
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let dic:NSDictionary = ["page":picPageCount,"uid":uid,"version":"\(AISubMIversion)","channel":AimiChannel]
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/images", dic: dic, success: { (data) in
            //        let dic:NSDictionary = ["page":picPageCount,"uid":uid,"version":"v1.0"]
            //        DeeRequest.requestGet(url: "https://aimi.cupiday.com/images", dic: dic, success: { (data) in
            print("请求图集列表成功!")
            guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                print("解析图集JSON失败!")
                return
            }
            
            guard json.object(forKey: "error") as! Int == 0 else{
                self.CV.mj_footer.endRefreshingWithNoMoreData()
                print("请求越界!!!")
                return
            }
            if let total = json.object(forKey: "total") as! Int?{
                self.picTotal = total
            }
            self.lastpage = json.object(forKey: "lastpage") as! Int
            let arr = json.object(forKey: "data") as! NSArray
            for i in arr{
                let tmp = i as! NSDictionary
                let model = PictureModel()
                model.setValuesForKeys(tmp as! [String: AnyObject])
                self.pictureArr.append(model)
                self.cachePic.add(tmp)
            }
            self.requestPic = true
            self.picPageCount += 1
            if self.requestVideo == true{
                self.creatArr()
            }
            
            
        }, fail: { (error) in
            print(error.localizedDescription)
            self.CV.mj_footer.endRefreshing()
        }) { (progress) in
            
        }
    }
    
    var picTotal = Int()
    var videoTotal = Int()
    var shieldContent = false
    var shieldUser = false
    var shieldModel = DeeMedia()
    override func viewWillAppear(_ animated: Bool) {
        self.CV.alpha = 1
        if shieldContent{
            self.modelArr = AimiFunction.shieldContentRefresh(sourceArr: self.modelArr, model: self.shieldModel)
            self.CV.reloadData()
            self.shieldContent = false
        }
        if shieldUser{
            self.modelArr = AimiFunction.shieldUserRefresh(sourceArr: self.modelArr, model: self.shieldModel)
            self.CV.reloadData()
            self.shieldUser = false
        }
    }
    
    var videoPageCount = 1
    var requestVideo = false
    var videoArr = [VideoModel]()
    func loadVideos() -> Void {
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let dic:NSDictionary = ["page":picPageCount,"version":"\(AISubMIversion)","uid":uid,"channel":AimiChannel]
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/video", dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                print("解析视频JSON失败!")
                return
            }
            
            guard json.object(forKey: "error") as! Int? != 1 else{
                self.CV.mj_footer.endRefreshingWithNoMoreData()
                print("请求越界!!!")
                return
            }
            if let total = json.object(forKey: "total") as! Int?{
                self.picTotal = total
            }
            
            let arr = json.object(forKey: "data") as! NSArray
            for i in arr{
                let tmp = i as! NSDictionary
                let model = VideoModel()
                model.setValuesForKeys(tmp as! [String: AnyObject])
                self.videoArr.append(model)
                self.cacheVideo.add(tmp)
            }
            
            self.videoPageCount += 1
            self.requestVideo = true
            if self.requestPic == true{
                self.creatArr()
            }
        }, fail: { (error) in
            print(error.localizedDescription)
        }) { (progress) in
        }
    }
    
    var isLoaded = false
    var i = 0
    var p = 0
    var resetLoad = false
    var created = false
    var modelArr = NSMutableArray()
    func creatArr() -> Void {
        DispatchQueue.global().sync {
            if created == false{
                if resetLoad == false{
                    self.modelArr.removeAllObjects()
                    self.CV.reloadData()
                    resetLoad = true
                    self.i = 0
                    self.p = 0
                }
                
                while videoArr.count != 0 && pictureArr.count != 0{
                    if i == 5{
                        i = 0
                    }
                    else{
                        i += 1
                    }
                    if i == 5{
                        if videoArr.count != 0{
                            modelArr.add(videoArr.first!)
                            videoArr.removeFirst()
                        }
                    }
                    else{
                        if pictureArr.count != 0{
                            modelArr.add(pictureArr.first!)
                            pictureArr.removeFirst()
                        }
                        
                    }
                }
                if pictureArr.count != 0 && videoArr.count == 0 && self.lastpage == self.picPageCount - 1{
                    for _ in pictureArr{
                        if pictureArr.count != 0{
                            modelArr.add(pictureArr.first!)
                            pictureArr.removeFirst()
                        }
                    }
                }
                UserDefaults.standard.setValue(self.cacheVideo, forKey: MishowCache_videos)
                UserDefaults.standard.setValue(self.cachePic, forKey: MishowCache_pictures)
                UserDefaults.standard.synchronize()
                DeeShareMenu.messageFrame(msg: NSLocalizedString("加载列表成功!", comment: ""), view: self.view)
                if self.isLoaded{
                    self.tabBarController?.tabBar.items?[1].badgeValue = nil
                }
                DispatchQueue.main.async {
                    self.CV.reloadData()
                }
                self.created = true
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        print("收到了内存警告")
        KingfisherManager.shared.cache.clearMemoryCache()
    }
    
}
