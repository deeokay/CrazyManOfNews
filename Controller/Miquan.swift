

//
//  Miquan.swift
//  AimiHealth
//
//  Created by apple on 2016/12/9.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit
import Kingfisher
import MJRefresh
import AFNetworking
import GIFImageView
import AVFoundation
import YYImage
var AVplaying = false
class Miquan: HSController,UITableViewDelegate,UITableViewDataSource,GDTNativeAdDelegate,GDTSplashAdDelegate,UIViewControllerPreviewingDelegate {
    var morining_Trigger = UserDefaults.standard.bool(forKey: "morning")
    var nativeAd = GDTNativeAd()
    var adView = UIView()
    var currentAD = GDTNativeAdData()
    @IBOutlet weak var TB: UITableView!
    var Splash = GDTSplashAd()
    override func viewDidAppear(_ animated: Bool) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        defer {
            let bb = action.init(picName: "米圈引导",delegate: self)
            bb.point = bb
            bb.insertGuidePic()
        }
        UIApplication.shared.applicationSupportsShakeToEdit = true
        self.TB.tableFooterView = UIView()
        AFNetworkReachabilityManager.shared().startMonitoring()
        //        nativeAd = GDTNativeAd.init(appkey: "1105706883", placementId: "1080215124193862")
        nativeAd.controller = self
        nativeAd.delegate = self
        self.TB.register(UINib.init(nibName: "MiquanTableViewCell", bundle: nil), forCellReuseIdentifier: "MiquanTableViewCell")
        self.TB.register(UINib.init(nibName: "MiquanS2", bundle: nil), forCellReuseIdentifier: "MiquanS2")
        self.TB.register(UINib.init(nibName: "MiquanS3", bundle: nil), forCellReuseIdentifier: "MiquanS3")
        self.TB.register(UINib.init(nibName: "GDTCell", bundle: nil), forCellReuseIdentifier: "ADcell")
        let bar = self.tabBarController as! Tabbar
        let header = MJRefreshNormalHeader.init {
            if AFNetworkReachabilityManager.shared().networkReachabilityStatus.rawValue != 0{
                self.pageCount = 1
                self.loadNews()
                self.TB.mj_header.endRefreshing()
                self.TB.mj_footer.resetNoMoreData()
            }
            else{
                DeeShareMenu.messageFrame(msg: NSLocalizedString("请检查网络!", comment: ""), view: self.view)
                self.TB.mj_header.endRefreshing()
            }
        }
        header?.setTitle(NSLocalizedString("用力拉用力拉!!!", comment: ""), for: .idle)
        header?.setTitle(NSLocalizedString("没有任何数据可以刷新!!!", comment: ""), for: .noMoreData)
        header?.setTitle(NSLocalizedString("服务器都快炸了!!!", comment: ""), for: .refreshing)
        header?.setTitle(NSLocalizedString("一松手就洗个脸!!!", comment: ""), for: .pulling)
        header?.isAutomaticallyChangeAlpha = true
        TB.mj_header = header
        let footer = MJRefreshAutoNormalFooter.init {
            self.loadNews()
            self.TB.mj_footer.endRefreshing()
        }
        footer?.setTitle(NSLocalizedString("推我上去看天下!", comment: ""), for: .willRefresh)
        footer?.setTitle(NSLocalizedString("别眨眼!!!", comment: ""), for: .refreshing)
        footer?.setTitle(NSLocalizedString("放手也是爱!过后我还在!", comment: ""), for: .pulling)
        self.TB.mj_footer = footer
        bar.action1 = {
            if self.TB.mj_header.isRefreshing() {
                return
            } else {
                if  bar.selectedIndex == 0{
                    if self.modelArr.count != 0{
                        self.TB.scrollToRow(at: IndexPath.init(item: 0, section: 0), at: .top, animated: false)
                    }
                    self.TB.mj_header.beginRefreshing()
                }
            }
        }
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status) in
            print("网络状态是",status.rawValue)
            if status.rawValue == 0{
                self.TB.mj_footer.endRefreshingWithNoMoreData()
                self.TB.mj_header.endRefreshing()
            }
            else{
                self.TB.mj_footer.resetNoMoreData()
            }
        }
        
        if let arr = (UserDefaults.standard.value(forKey: cacheNews) as! NSArray?){
            for i in arr
            {
                let model = ArticleModel()
                let tmp = i as! NSDictionary
                model.setValuesForKeys(tmp as! [String: AnyObject])
                self.modelArr.add(model)
                
            }
            print("尝试读取缓存!")
            if arr.count == 0{
                self.loadNews()
            }
        }
        
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake{
            self.mixStyle = !self.mixStyle
            self.TB.reloadData()
            UserDefaults.standard.set(self.mixStyle, forKey: "mix")
            UserDefaults.standard.synchronize()
        }
    }
    
    var isLoaded = false
    var modelArr = NSMutableArray()
    var pageCount = 1
    func loadNews() -> Void {
        nativeAd.load(5)
        let urlString = "https://aimi.cupiday.com/\(AIMIversion)/article"
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let dic:NSDictionary = ["page":pageCount,"version":AISubMIversion,"uid":uid, "channel": AimiChannel]
        DeeRequest.requestGet(url: urlString, dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data , options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                DeeShareMenu.messageFrame(msg: NSLocalizedString("服务器错误", comment: ""), view: self.view)
                print("解析数据失败!")
                return
            }
            guard json.object(forKey: "error") as! Int == 0 else{
                self.TB.mj_footer.endRefreshingWithNoMoreData()
                print("ERROR为1,应为越界请求?")
                return
            }
//            guard json.object(forKey: "total") as! Int > self.modelArr.count else{
//                print("更新个毛")
//                return
//            }
            if self.pageCount == 1{
                self.modelArr.removeAllObjects()
                self.cacheArr.removeAllObjects()
                //                self.TB.reloadData()
            }
            
            if let total = json.object(forKey: "total") as! Int?{
                UserDefaults.standard.set(total, forKey: "MiquanTotal")
                UserDefaults.standard.synchronize()
                print("NOW TOTAL IS ",UserDefaults.standard.integer(forKey: "MiquanTotal"))
            }
            
            print("deng deng deng,",json.object(forKey: "total") as! Int,self.modelArr.count)
            
            if let arr = json.value(forKey: "data") as! NSArray?
            {
                self.morningSaveDay = ((Date().description) as NSString).substring(to: 10)
                for i in arr
                {
                    let model = ArticleModel()
                    let tmp = i as! NSDictionary
                    model.setValuesForKeys(tmp as! [String: AnyObject])
                    if model.article_type == 2 && !self.morining_Trigger && self.morningSaveDay == model.publishtime.substring(to: 10) {
                        if model.aid == audioID{
                            model.isPlaying = true
                        }
                        else{
                            model.isPlaying = false
                        }
                        self.modelArr.insert(model, at: 0)
                        self.cacheArr.insert(tmp, at: 0)
                    }
                    else{
                        if model.aid == audioID{
                            model.isPlaying = true
                            self.modelArr.insert(model, at: 0)
                            self.cacheArr.insert(tmp, at: 0)
                        }
                        else{
                            model.isPlaying = false
                            self.cacheArr.add(tmp)
                            self.modelArr.add(model)
                        }

                    }
                    self.TB.reloadData()
                    self.tabBarController?.tabBar.items?[0].clearBadge()
                }
                if let count = json.object(forKey: "lastpage") as? Int{
                    if count == self.pageCount{
                        self.TB.mj_footer.endRefreshingWithNoMoreData()
                    }
                    else{
                        self.pageCount += 1
                    }
                }
                UserDefaults.standard.set(self.cacheArr, forKey: cacheNews)
                UserDefaults.standard.synchronize()
                DeeShareMenu.messageFrame(msg: NSLocalizedString("加载列表成功!", comment: ""), view: self.view)
                //                        self.TB.reloadData()
                print("NOW PAGECOUNT IS", self.pageCount)
                //                }
                //                if !UserDefaults.standard.bool(forKey: "FirstTipsForMiquan"){
                //                    let tips = UIAlertController.init(title: NSLocalizedString("温馨贴士", comment: ""), message: NSLocalizedString("文章列表支持风格切换啦!并且支持一键播放哦!\n你可以尝试以下操作:\n\0\01.摇晃手机,不用太大力哦\n2.前往个人设置选择风格\n3.长按左下方的米圈按钮", comment: ""), preferredStyle: .alert)
                //                    tips.addAction(UIAlertAction.init(title: NSLocalizedString("朕知道了", comment: ""), style: .default, handler: nil))
                //                    tips.addAction(UIAlertAction.init(title: NSLocalizedString("现在切换", comment: ""), style: .destructive, handler: { (action) in
                //                        self.mixStyle = !self.mixStyle
                //                        self.TB.reloadData()
                //                    }))
                //                    self.present(tips, animated: true, completion: {
                //                        UserDefaults.standard.set(true, forKey: "FirstTipsForMiquan")
                //                        UserDefaults.standard.synchronize()
                //                    })
                //                }
            }
            else {
                DeeShareMenu.messageFrame(msg: NSLocalizedString("请求超时!", comment: ""), view: self.view)
            }
        }, fail: { (error) in
            print(error.localizedDescription)
        }, Pro: { (pro) in
        })
    }
    
    var shieldContent = false
    var shieldModel = DeeMedia()
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
        self.mixStyle = UserDefaults.standard.bool(forKey: "mix")
        if shieldContent{
            self.modelArr = AimiFunction.shieldContentRefresh(sourceArr: self.modelArr, model: self.shieldModel)
            self.shieldContent = false
        }
        self.TB.reloadData()
    }
    
    
    var cacheArr = NSMutableArray()
    
    public func nativeAdFail(toLoad error: Error!) {
        print("拉取广告失败!",error)
    }
    
    var ADs = Set<GDTNativeAdData>()
    public func nativeAdSuccess(toLoad nativeAdDataArray: [Any]!) {
        print("成功拉取广告")
        for i in nativeAdDataArray{
            let tmp = i as! GDTNativeAdData
            ADs.insert(tmp)
        }
    }
    
    func voiceSet() -> UIImageView{
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 29, height: 29))
        imageView.animationImages = [UIImage.init(named: "voice-2")!.iv_changeSize(to: CGSize.init(width: 29, height: 29), origin: CGPoint.zero),
                                    UIImage.init(named: "voice-0")!.iv_changeSize(to: CGSize.init(width: 29, height: 29), origin: CGPoint.zero),
                                    UIImage.init(named: "voice-1")!.iv_changeSize(to: CGSize.init(width: 29, height: 29), origin: CGPoint.zero)]
        imageView.animationDuration = 0.9
        imageView.animationRepeatCount = 0
        imageView.startAnimating()
        return imageView
    }
    
    
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let indexPath = self.TB.indexPath(for: previewingContext.sourceView as! UITableViewCell)
        let model = self.modelArr.object(at: (indexPath?.row)!)
        let supportStoryBoard = UIStoryboard.init(name: "Support", bundle: nil)
        let vc = supportStoryBoard.instantiateViewController(withIdentifier: "MiquanDetailsController") as! MiquanDetailsController
        vc.model = model as! ArticleModel
        return vc
    }
    
    func register3D_Cell(cell:UITableViewCell) -> Void {
        if #available(iOS 9.0, *) {
            if self.traitCollection.forceTouchCapability == UIForceTouchCapability.available{
                self.registerForPreviewing(with: self, sourceView: cell)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
//    let playingImage = YYFrameImage.init(imagePaths: ["voice-2.png", "voice-0.png", "voice-1.png"], oneFrameDuration: 1.0, loopCount: 0)
    var mixStyle = UserDefaults.standard.bool(forKey: "mix")
    let pauseImg = UIImage.init(named: "voice")!
    let playingImage = UIImage.animatedImage(named: "play")!
    var lastIndexPath = IndexPath.init(row: 0, section: 0)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let playImage = UIImage.init(named: "voice")!
        let model = modelArr.object(at: indexPath.row) as AnyObject
        let cells = { () -> MiquanTableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "MiquanTableViewCell") as! MiquanTableViewCell
            self.register3D_Cell(cell: cell)
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            let model = self.modelArr.object(at: indexPath.row) as! ArticleModel
            let url = URL.init(string: model.imgUrl)
            cell.img.kf.setImage(with: url)
            cell.label.text = model.title
            if model.article_type == 0{
                cell.status.isHidden = true
            }
            else{
                cell.status.isHidden = false
            }
    
            
            if model.isPlaying && AVplaying && audioID == model.aid{
                cell.status.setImage(UIImage.init(named: ""), for: .normal)
                let voiceImageView = self.voiceSet()
                cell.status.addSubview(voiceImageView)
                voiceImageView.snp.makeConstraints({ (make) in
                    make.center.equalTo(cell.status.snp.center)
                })
            }
            else{
                cell.status.setImage(UIImage.init(named: "voice")!, for: .normal)
            }
            cell.pauseAction = {
                let player = AimiPlayer.share.player
                if audioID == model.aid{
                    if AVplaying{
                        player.pause()
                        AVplaying = false
                        model.isPlaying = false
//                        cell.isPlaying = false
//                        cell.status.setImage(self.pauseImg, for: .normal)
                    }
                    else{
                        AVplaying = true
                        player.play()
                        model.isPlaying = true
//                        cell.isPlaying = true
//                        cell.status.setImage(self.playingImage, for: .normal)
                    }
                }
                else{
                    if let url = URL.init(string: model.audioUrl){
                        let item = AVPlayerItem.init(url: url)
                        player.replaceCurrentItem(with: item)
                        player.play()
                        AVplaying = true
                        audioID = model.aid
//                        cell.status.setImage(self.playingImage, for: .normal)
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("马上为您播放!", comment: ""), view: self.view)
                    }
                }
                for i in self.modelArr{
                    let tmp = i as! ArticleModel
                    if tmp.aid == audioID{
                        tmp.isPlaying = true
                    }
                    else{
                        tmp.isPlaying = false

                    }
                }
                self.TB.reloadData()
                
            }

            
            if model.isLoad == false{
                model.isLoad = true
                cell.img.alpha = 0
                UIView.animate(withDuration: 1, animations: {
                    cell.img.alpha = 1
                })
            }
            return cell
        }
        let S2Cell = { () -> MiquanS2 in
            let cell = tableView.dequeueReusableCell(withIdentifier: "MiquanS2") as! MiquanS2
            self.register3D_Cell(cell: cell)
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            let model = self.modelArr.object(at: indexPath.row) as! ArticleModel
            let url = URL.init(string: model.imgUrl)
            cell.img.kf.setImage(with: url)
            cell.publishTime.text = (model.publishtime as NSString).substring(with: NSRange.init(location: 5, length: 11))
            cell.title.text = model.title
            if model.isLoad == false{
                model.isLoad = true
                cell.img.alpha = 0
                UIView.animate(withDuration: 1, animations: {
                    cell.img.alpha = 1
                })
            }
            return cell
        }
        let S3Cell = { () -> MiquanS3 in
            let cell = tableView.dequeueReusableCell(withIdentifier: "MiquanS3") as! MiquanS3
            self.register3D_Cell(cell: cell)
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            let model = self.modelArr.object(at: indexPath.row) as! ArticleModel
            let imgUrl = URL.init(string: model.imgUrl)
            cell.img.kf.setImage(with: imgUrl)
            cell.title.text = model.title
            var typeName = "性感音频"
            if model.article_type == 2{
                typeName = "早安问候"
            }
            cell.typeName.text = typeName
            cell.typeName.sizeToFit()
            cell.pauseAction = {
                let player = AimiPlayer.share.player
                if audioID == model.aid{
                    if AVplaying{
                        player.pause()
                        AVplaying = false
                        model.isPlaying = false
                        //                        cell.isPlaying = false
                        //                        cell.status.setImage(self.pauseImg, for: .normal)
                    }
                    else{
                        AVplaying = true
                        player.play()
                        model.isPlaying = true
                        //                        cell.isPlaying = true
                        //                        cell.status.setImage(self.playingImage, for: .normal)
                    }
                }
                else{
                    if let url = URL.init(string: model.audioUrl){
                        let item = AVPlayerItem.init(url: url)
                        player.replaceCurrentItem(with: item)
                        player.play()
                        AVplaying = true
                        audioID = model.aid
                        //                        cell.status.setImage(self.playingImage, for: .normal)
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("马上为您播放!", comment: ""), view: self.view)
                    }
                }
                for i in self.modelArr{
                    let tmp = i as! ArticleModel
                    if tmp.aid == audioID{
                        tmp.isPlaying = true
                        print("第\(self.modelArr.index(of: tmp))行 在播放")
                    }
                    else{
                        tmp.isPlaying = false
                        print("第\(self.modelArr.index(of: tmp))行 不在播放")
                        
                    }
                }
                self.TB.reloadData()
                
            }
            if model.aid == audioID{
                if AVplaying{
                    cell.status.setImage(self.playingImage, for: .normal)
                }
                else{
                    cell.status.setImage(self.pauseImg, for: .normal)
                }
            }
            else{
                cell.status.setImage(playImage, for: .normal)
            }
            cell.publishTime.text = (model.publishtime as NSString).substring(with: NSRange.init(location: 5, length: 11))
            cell.writter.text = model.writer
            let bgAvatar = URL.init(string: model.bgAvatar)
            cell.avatarImg.kf.setImage(with: bgAvatar)
            cell.status.layer.cornerRadius = UIwidth * 0.04
            if model.isLoad == false{
                model.isLoad = true
                cell.img.alpha = 0
                UIView.animate(withDuration: 1, animations: {
                    cell.img.alpha = 1
                })
            }
            return cell
        }
        let adCells = { () -> GDTCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ADcell") as! GDTCell
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            let ad = self.modelArr.object(at: indexPath.row) as! GDTNativeAdData
            let imgUrl = ad.properties[GDTNativeAdDataKeyImgUrl] as! String
            cell.label.text = (ad.properties[GDTNativeAdDataKeyDesc] as! String)
            let url = URL.init(string: imgUrl)
            cell.ADimg.kf.setImage(with: url)
            self.nativeAd.attach(ad, to: cell.adView)
            return cell
        }
        if model.isKind(of: ArticleModel.self)
        {
            let m = model as! ArticleModel
            if mixStyle{
                if m.article_type != 0{
                    return S3Cell()
                }
                else{
                    return S2Cell()
                }
            }
            else{
                return cells()
            }
        }
        else{
            return adCells()
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        let model = modelArr.object(at: indexPath.row) as AnyObject
        if model.isKind(of: ArticleModel.self)
        {
            return  UIwidth / 47 * 26
        }
        else{
            return UIwidth / 52 * 26
        }
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArr.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath:
        IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func refreshTB() -> Void {
        self.TB.reloadData()
    }
    
    
    var morningSaveDay = ""
    var recordAid = 0
    var not_Morning_Trigger = false
    var morning_IndexPath = IndexPath()
    var not_morning_IndexPath = IndexPath()
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let goToVC = {
            let model = self.modelArr.object(at: indexPath.row) as! ArticleModel
            let supportStoryBoard = UIStoryboard.init(name: "Support", bundle: nil)
            let vc = supportStoryBoard.instantiateViewController(withIdentifier: "MiquanDetailsController") as! MiquanDetailsController
            vc.delegate = self
            vc.model = model
            print(model.mj_keyValues())
            if model.article_type != 0{
                if self.modelArr.count > 1{
                    model.isPlaying = true
                    self.modelArr.remove(model)
                    if model.article_type == 2 && ((Date().description) as NSString).substring(to: 10) == model.publishtime.substring(to: 10) && !self.morining_Trigger{
                        self.morining_Trigger = true
                        UserDefaults.standard.set(true, forKey: "morning")
                        UserDefaults.standard.set(self.morningSaveDay, forKey: "morningDate")
                        UserDefaults.standard.synchronize()
                        self.modelArr.insert(model, at: 0)
                        self.lastIndexPath = IndexPath.init(item: 0, section: 0)
                    }
                    else{
                        if self.morining_Trigger{
                            self.modelArr.insert(model, at: 0)
                            self.lastIndexPath = IndexPath.init(item: 0, section: 0)
                        }
                        else{
                            self.modelArr.insert(model, at: 1)
                            self.lastIndexPath = IndexPath.init(item: 0, section: 1)
                        }
                    }
                }
            }
            else{
                self.recordAid = 0
                self.not_Morning_Trigger = false
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let goToAD = {
            let ad = self.modelArr.object(at: indexPath.row) as! GDTNativeAdData
            self.nativeAd.click(ad)
        }
        let model = modelArr.object(at: indexPath.row) as AnyObject
        if model.isKind(of: ArticleModel.self)
        {
            goToVC()
        }
        else{
            goToAD()
        }
    }
    
}
