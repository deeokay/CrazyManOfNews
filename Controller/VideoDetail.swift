//
//  VideoDetail.swift
//  test
//
//  Created by apple on 2016/12/15.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher
class VideoDetail: HideTabbarController,GDTMobInterstitialDelegate,UITextViewDelegate {
    var offLineMode = false
    var isPayed = false
    var typeStr = NSString()
    var VIP = false
    var DVIP = false
    
    @IBOutlet weak var barrageSwitch: UIButton!
    @IBOutlet weak var PV: UIView!
    var playerItem:AVPlayerItem!
    var avplayer:AVPlayer!
    var playerLayer:AVPlayerLayer!
    var link:CADisplayLink!
    var playerView : Player?
    var vid = NSInteger()
    var iscollected = false
    var isLoaded = false
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var player: UIView!
    @IBOutlet weak var barrageView: UIView!
    @IBOutlet weak var writeCommentBtn: UIButton!
    var model = VideoModel()
    var task = URLSessionDownloadTask()
    var commentView = WriteComment()
    var comments = NSMutableArray()
    var interstitialObj = GDTMobInterstitial()
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        defer{
            let collect = action.init(picName: "收藏引导",delegate: self)
            collect.point = collect
            collect.insertGuidePic()
        }
        audioID = 0
        showAnimate()
        self.view.alpha = 0
        self.setReportView()
        self.vid = model.vid
        self.barrageSwitch.layer.cornerRadius = 5
        let backGest = UISwipeGestureRecognizer.init(target: self, action: #selector(self.edgeToBack(_:)))
        backGest.direction = .right
        self.PV?.addGestureRecognizer(backGest)
        self.VIP = UserDefaults.standard.bool(forKey: "VIP")
        self.DVIP = UserDefaults.standard.bool(forKey: "DVIP")
        let dView = DeeSetView()
        commentView = dView.creatCommentView(controller: self)
        dView.sendCallBack = {
            DeeShareMenu.messageFrame(msg: "评论成功!", view: self.view)
        }
        UIApplication.shared.applicationSupportsShakeToEdit = true
        playerView = Bundle.main.loadNibNamed("Player", owner: self, options: nil)?.last as! Player!
        self.writeCommentBtn.layer.borderColor = UIColor.gray.cgColor
        var url = URL(string: model.url)
        self.barrageSwitch.setImage(UIImage.init(named: NSLocalizedString("关弹幕", comment: "")), for: .normal)
        let fileManager = FileManager.default
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
        let creatPath = path?.appending("/Cupiday.AimiHealth/video")
        if !fileManager.fileExists(atPath: creatPath!){
            do {
                try fileManager.createDirectory(atPath: creatPath!, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
                print("创建文件夹失败!")
            }
        }
        else{
            print("Video已存在!")
        }
        
        let dest = path?.appending("/Cupiday.AimiHealth/video/\(self.model.vid).mp4")
        let dic = ["uid":UserDefaults.standard.integer(forKey: "uid"),"id":model.vid,"type":2] as NSDictionary
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/control", dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                print("读取收藏Json失败!")
                return
            }
            if json.object(forKey: "error") as! Int == 0 {
                if json.object(forKey: "zan") as! Int == 1{
                    self.collectBtn.setImage(UIImage.init(named: "collection-icon-selected"), for: .selected)
                    self.collectBtn.isSelected = true
                    self.iscollected = true
                } else {
                    self.collectBtn.setImage(UIImage.init(named: "collection-icon"), for: .normal)
                    self.collectBtn.isSelected = false
                    self.iscollected = false
                }
            }
        }, fail: { (err) in
            print("请求收藏接口失败!",err.localizedDescription)
            self.collectBtn.isSelected = !self.collectBtn.isSelected
        }) { (pro) in
        }
        
        
        
        interstitialObj = GDTMobInterstitial.init(appkey: "1105939483", placementId: "8020820072631605")
        interstitialObj.delegate = self
        interstitialObj.isGpsOn = false
        interstitialObj.loadAd()
        if fileManager.fileExists(atPath: dest!){
            url = NSURL.init(fileURLWithPath: dest!) as URL
            offLineMode = true
            DeeShareMenu.messageFrame(msg: NSLocalizedString("当前离线播放!", comment: ""), view: self.view)
            self.toolBar.isHidden = (self.playerView?.PVhidden)!
        }
        else{
            let urlRequst = URLRequest.init(url: url!)
            if UserDefaults.standard.bool(forKey: "downloadWhilePlaying"){
                let session = URLSession.shared
                task = session.downloadTask(with: urlRequst, completionHandler: { (location, res, error) in
                    if error == nil {
                        do {
                            try fileManager.moveItem(atPath: (location?.path)!, toPath: dest!)
                        } catch _ {
                            DeeShareMenu.messageFrame(msg: NSLocalizedString("保存视频失败!", comment: ""), view: self.view)
                        }
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("下载视频成功!!", comment: ""), view: self.view)
                    }
                })
                task.resume()
            }
        }
        
        self.getCommentList()
        playerItem = AVPlayerItem(url: url!) // 创建视频资源
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        self.avplayer = AimiPlayer.share.player
        self.avplayer.replaceCurrentItem(with: playerItem)
        playerLayer = AVPlayerLayer(player: avplayer)
        //设置模式
        playerView?.backAction = {
            self.releaseVideo()
        }
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        playerLayer.contentsScale = UIScreen.main.scale
        self.playerView?.playerLayer = self.playerLayer
        self.player?.layer.insertSublayer(playerLayer, at: 0)
        self.playerView?.delegate = self
        self.link = CADisplayLink(target: self, selector: #selector(update))
        self.link.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        playerView?.frame = self.PV.bounds
        self.showHint(in: self.PV, hint: "小爱正在拼命加载中...", duration: Double(HUGE), yOffset: 0)
        playerView?.playBtn.isHidden = true
        self.PV.addSubview(playerView!)
        self.playerView?.slideAction = {
            if self.timer_closePV.isValid == true{
                self.timer_closePV.invalidate()
            }
        }
        self.playerView?.touchUpSliderAction = {
            self.second = 2
            self.timer_closePV = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.hiddenPV), userInfo: nil, repeats: true)
        }
        setCustomView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AimiPlayer.share.player.pause()
        self.timer.fireDate = Date.init(timeIntervalSince1970: TimeInterval(HUGE))
    }
    
    var delegate:Mishow?
    func releaseVideo() -> Void {
        if self.offLineMode == false && UserDefaults.standard.bool(forKey: "downloadWhilePlaying"){
            self.task.cancel()
        }
        self.playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
        self.playerItem.removeObserver(self, forKeyPath: "status")
        self.avplayer.currentItem?.cancelPendingSeeks()
        self.avplayer.currentItem?.asset.cancelLoading()
        self.avplayer.replaceCurrentItem(with: nil)
        self.avplayer.pause()
        AimiPlayer.share.player = AVPlayer()
        self.timer.invalidate()
        self.timer_closePV.invalidate()
        self.link.invalidate()
        self.dismiss(animated: true, completion: {
//            self.delegate?.closeAnimate(complete: () -> Void)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !isLoaded{
            DeeSetView.showAnimate(controller: self,picName: "launcher.jpg")
            self.isLoaded = true
        }
    }
    
    
    lazy var custom : CustomMenu = {
        return self.setCustomView()
    }()
    func setCustomView() -> CustomMenu {
        let customView = Bundle.main.loadNibNamed("CustomMenu", owner: self, options: nil)?.last as! CustomMenu
        customView.loading = {
            self.showHud(in: self.view, hint: "分享中...", yOffset: 0, interaction: false)
        }
        customView.handlingResult = {
            self.hideHud()
        }
        customView.frame = CGRect.init(x: 0, y: UIheight, width: UIwidth, height: UIheight * 0.4)
        
        customView.successToShareCallback = {
            self.showHint(in: self.view, hint: Locale.cast(str: "分享成功!"), duration: 1, yOffset: 0)
            customView.hideView(complete: {
            })
        }
        customView.failToShareCallback = {
            self.hideHud()
            self.showHint(in: self.view, hint: Locale.cast(str: "分享失败!"), duration: 1, yOffset: 0)
        }
        self.view.addSubview(customView)
        let report = ActionModel()
        report.img = UIImage.init(named: "举报")!
        report.title = NSLocalizedString("举报", comment: "")
        report.action = {
            UIView.animate(withDuration: 0.3, animations: {
                self.reportView.alpha = 1
            })
            customView.hideView(complete: {
            })
            
        }
        let shieldU = ActionModel()
        shieldU.title = NSLocalizedString("屏蔽用户", comment: "")
        shieldU.img = UIImage.init(named: "屏蔽用户")!
        shieldU.action = {
            AimiFunction.shield(id: self.model.uid, type: 4, success: {
                self.delegate?.shieldModel = self.model
                self.delegate?.shieldUser = true
                DeeShareMenu.messageFrame(msg: Locale.cast(str: "屏蔽用户成功!"), view: self.view)
            })
            customView.hideView(complete: {
            })
        }
        let shieldC = ActionModel()
        shieldC.title = NSLocalizedString("屏蔽内容", comment: "")
        shieldC.img = UIImage.init(named: "屏蔽内容")!
        shieldC.action = {
            AimiFunction.shield(id: self.model.vid, type: 2, success: {
                self.delegate?.shieldModel = self.model
                self.delegate?.shieldContent = true
                DeeShareMenu.messageFrame(msg: Locale.cast(str: "屏蔽内容成功!"), view: self.view)
            })
            customView.hideView(complete: {
            })
        }
        customView.actionArr.append(report)
        customView.actionArr.append(shieldU)
        customView.actionArr.append(shieldC)
        
        customView.cancelAction = {
            self.playerView?.playAndPause((self.playerView?.playBtn)!)
        }
        shareUrl = model.url
        self.shareImg = UIImage.init(named: "logo")!
        DispatchQueue.global().async {
            if let url = URL.init(string: self.model.imgUrl){
                guard let data = try? Data.init(contentsOf: url) else{
                    return
                }
                self.shareImg = UIImage.init(data: data)!
                customView.shareModel = ShareModel.init(url: self.model.url, img: self.shareImg, type: SSDKContentType.auto)
            }
        }
        return customView
    }
    
    var reportView = Report()
    func setReportView() -> Void {
        self.reportView = Bundle.main.loadNibNamed("Report", owner: self, options: nil)?.first as! Report
        reportView.frame.size = CGSize.init(width: UIwidth * 0.5, height: UIheight * 0.4)
        reportView.center = self.view.center
        reportView.alpha = 0
        self.view.addSubview(self.reportView)
        reportView.id = self.vid
        reportView.type = 3
        reportView.submitAction = {
            let alert = UIAlertController.init(title: NSLocalizedString("提示", comment: ""), message: NSLocalizedString("感谢您的举报！我们会在24小时内做出处理，如情况属实，我们会立即删除。", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "朕知道了", style: .destructive, handler: { (action) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.reportView.alpha = 0
                })
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        IQKeyboardManager.sharedManager().enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = true
    }
    
    
    @IBAction func showComment(_ sender: Any) {
        self.commentView.aid = self.model.vid
        self.commentView.sendType = "comment"
        self.commentView.contentType = "2"
        self.commentView.ruid = self.model.uid
        self.commentView.textView.becomeFirstResponder()
    }
    
    @IBAction func showCommentDetails(_ sender: Any) {
        self.playerView?.playAndPause((self.playerView?.playBtn)!)
        self.playerView?.playBtn.setImage(UIImage.init(named: "播放"), for: .normal)
        let vc = storyboard?.instantiateViewController(withIdentifier: "PicAndVideoCommentView") as! PicAndVideoCommentView
        vc.aid = self.model.vid
        vc.contentType = "2"
        self.navigationController?.pushViewController(vc, animated:  true)
    }
    
    @IBOutlet weak var collectBtn: UIButton!
    @IBAction func collectBtnClick(_ sender: Any) {
        
        if UserDefaults.standard.bool(forKey: "isLogin") {
            let uid = UserDefaults.standard.integer(forKey: "uid")
            var parameters = NSDictionary()
            var url = ""
            if self.iscollected == false {
                parameters = ["uid": uid,"vid": self.model.vid]
                url = "https://aimi.cupiday.com/\(AIMIversion)/vfavorite"
            }
            else{
                parameters = ["uid": uid,"vid": self.model.vid]
                url = "https://aimi.cupiday.com/\(AIMIversion)/delfavour"
            }
            
            
            DeeRequest.requestPost(url: url, dic: parameters, success: { (data) in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                    print("解析数据失败!")
                    return
                }
                if (json.object(forKey: "error") as! NSNumber).isEqual(to: 0){
                    if (json.object(forKey: "message") as! String) == "收藏成功"{
                        self.collectBtn.isSelected = true
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("收藏成功!", comment: ""), view: self.view)
                        self.iscollected = true
                    }
                    else if (json.object(forKey: "message") as! String) == "删除成功"{
                        self.collectBtn.isSelected = false
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("删除收藏成功!", comment: ""), view: self.view)
                        self.iscollected = false
                    }
                }
                else{
                    print("解析失败!")
                }
            }, fail: { (err) in
                
            }, Pro: {(pro) in
                
            })
        }
        else{
            DeeShareMenu.messageFrame(msg: Locale.cast(str: "未登录请到历史处查看!"), view: self.view)
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake{
            if UserDefaults.standard.bool(forKey: "shankeShare"){
                share()
                self.playerView?.playBtn.setImage(UIImage.init(named: "播放"), for: .normal)
            }
            else{
                DeeShareMenu.showShankeMenu(Yes: {
                    UserDefaults.standard.set(true, forKey: "shankeShare")
                }, No: {
                    keepWarning = false
                }, ViewController: self, keepWarning: keepWarning)
            }
        }
    }
    
    var shareImg = UIImage()
    var shareTitle = String()
    var shareUrl = String()
    @IBAction func shareClick(_ sender: Any) {
        share()
    }
    enum MyError: Error {
        case FailToSharePic
    }
    func share() -> Void {
        self.playerView?.playAndPause((self.playerView?.playBtn)!)
        self.playerView?.playBtn.setImage(UIImage.init(named: "播放"), for: .normal)
        self.custom.showView {
        }
    }
    var timer = Timer()
    func commentList() -> Void {
        self.barrageView.isHidden = false
        DispatchQueue.global().async {
            self.timer = Timer.init(timeInterval: TimeInterval(1), target: self, selector: #selector(self.showBarrage), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer, forMode: .commonModes)
            RunLoop.current.run()
        }
    }
    
    var barrageModel = NSDictionary()
    func getCommentList() -> Void {
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let dic = ["aid":self.vid,"type":2,"uid":uid]
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/comment", dic: dic as NSDictionary as NSDictionary, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                DeeShareMenu.messageFrame(msg: NSLocalizedString("读取弹幕失败!", comment: ""), view: self.view)
                return
            }
            let barrageList = json.object(forKey: "body") as! NSArray
            for i in barrageList{
                let tmp = i as! NSDictionary
                var bModel = self.barrageModel
                let avatar = tmp.object(forKey: "avatar") as! String
                let content = tmp.object(forKey: "content") as! String
                bModel = ["avatar":avatar,"content":content]
                self.comments.add(bModel)
            }
            self.commentList()
        }, fail: { (err) in
            DeeShareMenu.messageFrame(msg: NSLocalizedString("读取弹幕失败!", comment: ""), view: self.view)
        }) { (pro) in
        }
    }
    
    var i  = 0
    var distance:CGFloat = -1
    func showBarrage() -> Void {
        if i == comments.count{
            timer.invalidate()
            return
        }
        else{
            self.distance *= -1
            let img = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
            let msg = UILabel.init(frame: CGRect.init(x: 35, y: 5, width: UIwidth / 3 - 20, height: 30))
            msg.font = UIFont.systemFont(ofSize: 15)
            msg.numberOfLines = 1
            let model = self.comments.object(at: self.i) as! NSDictionary
            img.clipsToBounds = true
            img.layer.cornerRadius = 15
            img.kf.setImage(with: URL.init(string: model.object(forKey: "avatar") as! String))
            msg.textColor = UIColor.white
            msg.font = UIFont.boldSystemFont(ofSize: 15)
            msg.lineBreakMode = .byCharWrapping
            msg.text = (model.object(forKey: "content") as! String)
            var size = msg.sizeThatFits(CGSize.init(width: UIwidth / 3 - 15, height: 30))
            size.width = min(size.width,UIwidth / 3 - 15)
            msg.frame.size = size
            let v = UIView.init(frame: CGRect.init(x: 0, y: 0, width: msg.frame.size.width + 45, height: 30))
            v.backgroundColor = UIColor.init(red: 24/255, green: 24/255, blue: 24/255, alpha: 0.7)
            v.clipsToBounds = true
            v.layer.cornerRadius = 15
            let radom = arc4random_uniform(6) + 1
            let bg = UIView.init(frame: CGRect.init(x: 10 + distance * 5, y:CGFloat(UIheight * CGFloat(radom)), width: msg.frame.size.width + 45, height: 30))
            bg.backgroundColor = UIColor.clear
            v.addSubview(msg)
            bg.addSubview(v)
            bg.addSubview(img)
            self.barrageView.addSubview(bg)
            i += 1
            UIView.animate(withDuration: TimeInterval(CGFloat(radom) * 20), animations: {
                bg.frame.origin = CGPoint.init(x: 10 + self.distance * 5, y: -200)
                
            }, completion: { (b) in
                if b{
                    bg.removeFromSuperview()
                }
            })
        }
    }
    

    
    func edgeToBack(_ sender: UISwipeGestureRecognizer) {
        self.releaseVideo()
    }
    
    
    @IBAction func tabClick(_ sender: Any) {
        self.commentView.textView.resignFirstResponder()
        self.playerView?.PVhidden = !(self.playerView?.PVhidden)!
        self.toolBar.isHidden = (self.playerView?.PVhidden)!
        if self.playerView?.PVhidden != true{
            timer_closePV.invalidate()
            second = 3
            timer_closePV = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.hiddenPV), userInfo: nil, repeats: true)
        }
    }
    var timer_closePV = Timer()
    var second = 3
    func hiddenPV() -> Void {
        second -= 1
        if second == 0{
            timer_closePV.invalidate()
            self.playerView?.PVhidden = true
            self.toolBar.isHidden = (self.playerView?.PVhidden)!
            second = 3
        }
    }
    
    @IBOutlet weak var line: NSLayoutConstraint!
    override var shouldAutorotate: Bool{
        return false
    }
    
    
    @IBAction func closeBarrageView(_ sender: Any) {
        self.barrageView.isHidden = !self.barrageView.isHidden
        if self.barrageView.isHidden{
            self.barrageSwitch.setImage(UIImage.init(named: NSLocalizedString("开弹幕", comment: "")), for: .normal)
        }
        else{
            self.barrageSwitch.setImage(UIImage.init(named: NSLocalizedString("关弹幕", comment: "")), for: .normal)
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        if keyPath == "loadedTimeRanges"{
            //            通过监听AVPlayerItem的"loadedTimeRanges"，可以实时知道当前视频的进度缓冲
            let loadedTime = avalableDurationWithplayerItem()
            let totalTime = CMTimeGetSeconds(playerItem.duration)
            let percent = loadedTime/totalTime
            
            self.playerView?.progressView.progress = Float(percent)
        }else if keyPath == "status"{
            if playerItem.status == AVPlayerItemStatus.readyToPlay{
                // 只有在这个状态下才能播放
                self.avplayer.play()
                self.hideHud()
                playerView?.playBtn.isHidden = true
                self.playerView?.PVhidden = true
                self.toolBar.isHidden = true
            }else{
                print("加载异常")
                self.showHint(in: self.PV, hint: "客官大人你网络太差啦,稍候再试试吧!", duration: 2, yOffset: 0)
            }
        }
    }
    
    
    func interstitialDidDismissScreen(_ interstitial: GDTMobInterstitial!) {
        interstitialObj.loadAd()
    }
    func interstitialSuccess(toLoadAd interstitial: GDTMobInterstitial!) {
        print("成功读取广告")
    }
    func interstitialFail(toLoadAd interstitial: GDTMobInterstitial!, error: Error!) {
        print("读取广告失败")
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func avalableDurationWithplayerItem()->TimeInterval{
        guard let loadedTimeRanges = avplayer?.currentItem?.loadedTimeRanges,let first = loadedTimeRanges.first else {fatalError()}
        let timeRange = first.timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSecound = CMTimeGetSeconds(timeRange.duration)
        let result = startSeconds + durationSecound
        return result
    }
    
    func update(){
        if !(self.playerView?.playing)!{
            return
        }
        let currentTime = CMTimeGetSeconds(self.avplayer.currentTime())
        let totalTime   = TimeInterval(playerItem.duration.value) / TimeInterval(playerItem.duration.timescale)
        let timeStr = "\(formatPlayTime(currentTime))/\(formatPlayTime(totalTime))"
        playerView?.timeLabel.text = timeStr
        // 滑动不在滑动的时候
        if !(self.playerView?.sliding)!{
            // 播放进度
            self.playerView?.Slider.value = Float(currentTime/totalTime)
        }
    }
    
    func formatPlayTime(_ secounds:TimeInterval)->String{
        if secounds.isNaN{
            return "00:00"
        }
        let Min = Int(secounds / 60)
        let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showAnimate() {
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        imageView.center = CGPoint.init(x: UIwidth / 2, y: UIheight / 2)
        imageView.image = UIImage.init(named: "封面")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = UIheight * 0.3
        self.view.addSubview(imageView)
        UIView.animate(withDuration: 0.7, animations: {
            imageView.bounds = CGRect.init(x: 0, y: 0, width: UIheight * 1.2, height: UIheight * 1.2)
            imageView.alpha = 0
            self.view.alpha = 1
        }, completion: nil)
    }
    
    
}

extension VideoDetail:PlayerDelegate{
    // 滑动滑块 指定播放位置
    func Player(_ playerView:Player,SliderTouchUpOut Slider:UISlider){
        //当视频状态为AVPlayerStatusReadyToPlay时才处理
        if self.avplayer.status == AVPlayerStatus.readyToPlay{
            let duration = Slider.value * Float(CMTimeGetSeconds(self.avplayer.currentItem!.duration))
            let seekTime = CMTimeMake(Int64(duration), 1)
            self.avplayer.seek(to: seekTime, completionHandler: { (b) in
                playerView.sliding = false
            })
        }
    }
    
    func Player(_ playerView:Player,playAndPause playBtn:UIButton){
        if !playerView.playing{
            self.avplayer.pause()
            //            if !self.VIP && !self.DVIP{
            interstitialObj.present(fromRootViewController: self)
            //            }
            self.playerView?.PVhidden = false
            self.toolBar.isHidden = (self.playerView?.PVhidden)!
        }else{
            if self.avplayer.status == AVPlayerStatus.readyToPlay{
                self.avplayer.play()
                self.playerView?.PVhidden = true
                self.toolBar.isHidden = (self.playerView?.PVhidden)!
            }
        }
    }
    
}
