//
//  PicDetail.swift
//  AimiHealth
//
//  Created by apple on 2016/12/10.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit
import MMPopupView
import Kingfisher
class PicDetail: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,GDTMobInterstitialDelegate,UITextViewDelegate,UIScrollViewDelegate{
    @IBOutlet weak var toolbar: UIToolbar!
    var timer = Timer()
    var typeStr = NSString()
    var iid = NSInteger()
    var VIP = false
    var DVIP = false
    var i  = 0
    @IBOutlet weak var barrageSwitch: UIButton!
    var payed = false
    var iconUrl = ""
    var comments = NSMutableArray()
    var isCollected = false
    var isLoaded = false
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var payVC: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var CV: UICollectionView!
    var imageArr = NSMutableArray()
    var model = PictureModel()
    var commentView = WriteComment()
    var bgView = UIView()
    var delegate:Mishow?
    override func viewDidLoad() {
        super.viewDidLoad()
        defer{
            let pic = action.init(picName: "图片引导",delegate: self)
            pic.point = pic
            pic.insertGuidePic()
        }
        UIApplication.shared.isIdleTimerDisabled = true
        setReportView()
        self.allHide = true
        self.iid = model.iid
        self.imageArr = model.url
        interstitialObj = GDTMobInterstitial.init(appkey: "1105939483", placementId: "8020820072631605")
        interstitialObj.delegate = self
        self.barrageSwitch.layer.cornerRadius = 5
        VIP = UserDefaults.standard.bool(forKey: "VIP")
        DVIP = UserDefaults.standard.bool(forKey: "DVIP")
        self.CV.delegate = self
        self.CV.dataSource = self
        self.view.alpha = 0
        self.writeCommentBtn.layer.borderColor = UIColor.lightGray.cgColor
        let dView = DeeSetView()
        commentView = dView.creatCommentView(controller: self)
        dView.sendCallBack = {
            DeeShareMenu.messageFrame(msg: NSLocalizedString("评论成功!", comment: ""), view: self.view)
        }
        UIApplication.shared.applicationSupportsShakeToEdit = true
        //        if !VIP && !DVIP{
        checkAdCount()
        //        }
        getCommentList()
        let dic = ["uid":UserDefaults.standard.integer(forKey: "uid"),"id":model.iid,"type":1] as NSDictionary
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/control", dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                print("读取收藏Json失败!")
                return
            }
            if json.object(forKey: "error") as! Int == 0 {
                if json.object(forKey: "zan") as! Int == 1{
                    self.collectBtn.setImage(UIImage.init(named: "collection-icon-selected"), for: .selected)
                    self.collectBtn.isSelected = true
                    self.isCollected = true
                } else {
                    self.collectBtn.setImage(UIImage.init(named: "collection-icon"), for: .normal)
                    self.collectBtn.isSelected = false
                    self.isCollected = false
                }
            }
        }, fail: { (err) in
            print("请求收藏接口失败!",err.localizedDescription)
        }) { (pro) in
        }
    }
    var reportView = Report()
    func setReportView() -> Void {
        self.reportView = Bundle.main.loadNibNamed("Report", owner: self, options: nil)?.first as! Report
        reportView.frame.size = CGSize.init(width: UIwidth * 0.5, height: UIheight * 0.4)
        reportView.center = self.view.center
        reportView.alpha = 0
        self.view.addSubview(self.reportView)
        reportView.id = self.model.iid
        reportView.type = 2
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
//            AimiFunction.shareReward(controller: self)
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
            UIView.animate(withDuration: 0.2, animations: {
                self.reportView.alpha = 1
                customView.mj_origin = CGPoint.init(x: 0, y: UIheight)
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
            AimiFunction.shield(id: self.model.iid, type: 1, success: {
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
        return customView
    }
    
    
    
    var barrageModel = NSDictionary()
    func getCommentList() -> Void {
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let dic = ["aid":self.iid,"type":1,"uid":uid]
        print(dic)
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/comment", dic: dic as NSDictionary, success: { (data) in
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
    
    override func viewDidAppear(_ animated: Bool) {
        if !isLoaded{
        DeeSetView.showAnimate(controller: self,picName: "launcher.jpg")
            self.isLoaded = true
        }
    }
    
    func checkAdCount() -> Void {
        if !UserDefaults.standard.bool(forKey: "VIP") || !self.payed || !UserDefaults.standard.bool(forKey: "DVIP"){
            let count = UserDefaults.standard.integer(forKey: "Count")
            var AD = UserDefaults.standard.integer(forKey: "AD")
            print(count,AD)
            if AD == count{
                //show AD
                self.showPay = true
            }
                //            else if AD > count{
                //                UserDefaults.standard.set(0, forKey: "AD")
                //                UserDefaults.standard.synchronize()
                //            }
            else{
                AD += 1
                UserDefaults.standard.set(AD, forKey: "AD")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        DeeSetView().releaseKeyboardObserver()
        IQKeyboardManager.sharedManager().enable = true
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true , animated: true)
        IQKeyboardManager.sharedManager().enable = false
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake{
            if UserDefaults.standard.bool(forKey: "shankeShare"){
                shareBtnClick(self as UIViewController)
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
    
    func commentList() -> Void {
        DispatchQueue.global().async {
            self.timer = Timer.init(timeInterval: 1, target: self, selector: #selector(self.showBarrage), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer, forMode: .commonModes)
            RunLoop.current.run()
        }
    }
    
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
            if size.width > UIwidth / 3 - 15{
                size.width = UIwidth / 3 - 15
            }
            msg.frame.size = size
            let v = UIView.init(frame: CGRect.init(x: 0, y: 0, width: msg.frame.size.width + 45, height: 30))
            v.backgroundColor = UIColor.init(red: 24/255, green: 24/255, blue: 24/255, alpha: 0.7)
            v.clipsToBounds = true
            v.layer.cornerRadius = 15
            let bg = UIView.init(frame: CGRect.init(x: 10 + distance * 5, y: UIheight + 30, width: msg.frame.size.width + 45, height: 30))
            bg.backgroundColor = UIColor.clear
            DispatchQueue.main.async {
                v.addSubview(msg)
                bg.addSubview(v)
                bg.addSubview(img)
                self.topView.addSubview(bg)
            }
            i += 1
            UIView.animate(withDuration: 20, animations: {
                bg.frame.origin = CGPoint.init(x: 10 + self.distance * 5, y: -140) //view.frame.size.height + 20
            }, completion: { (b) in
                if b{
                    bg.removeFromSuperview()
                }
            })
        }
    }
    
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArr.count
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if self.CV.indexPathsForVisibleItems.first?.row == self.imageArr.count - 1{
            DeeShareMenu.messageFrame(msg: NSLocalizedString("已到最后一页", comment: ""), view: self.view)
        }
        
        if let cell = self.CV.visibleCells.first as? PicDetailCell{
            self.cellImg = cell.img
            cell.scView.zoomScale = 1
            let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(self.doubleTap(tap:)))
            doubleTap.numberOfTapsRequired = 2
            self.doubleTapEvent = {
                if cell.scView.zoomScale == 3{
                    UIView.animate(withDuration: 0.3, animations: {
                        cell.scView.zoomScale = 1
                    })
                }
                else{
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.scView.zoomScale = 3
                    })
                }
            }
            cell.scView.addGestureRecognizer(doubleTap)
        }
        let index = self.CV.indexPathsForVisibleItems.first?.row
        let step = 1/Float(imageArr.count - 1)
        let x = slider.value / step
        if index != nil && index != Int(x){
            slider.value = (Float(index!) / Float(imageArr.count - 1))
        }
        
        if index != nil{
            if index! > guardIndex {
                if payed == false{
                    showPay = true
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PicDetailCell", for: indexPath) as! PicDetailCell
        cell.loading.startAnimating()
        let url = URL.init(string: imageArr.object(at: indexPath.row) as! String)
        cell.img.kf.setImage(with: url) { (img, error, cacheType, url) in
            cell.loading.stopAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                cell.img.alpha = 1
            })
        }
        if indexPath.row == 0{
            self.cellImg = cell.img
            let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(self.doubleTap(tap:)))
            
            doubleTap.numberOfTapsRequired = 2
            self.doubleTapEvent = {
                if cell.scView.zoomScale == 3{
                    UIView.animate(withDuration: 0.3, animations: {
                        cell.scView.zoomScale = 1
                    })
                }
                else{
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.scView.zoomScale = 3
                    })
                }
            }
            cell.scView.addGestureRecognizer(doubleTap)
        }
        UIView.animate(withDuration: 0.3, animations: {
            cell.scView.contentSize = cell.img.frame.size
        })
        
        //            singleTap.require(toFail: doubleTap)
        //        }
        cell.scView.zoomScale = 1
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(self.singleTap(tap:)))
        cell.scView.addGestureRecognizer(singleTap)
        singleTap.numberOfTapsRequired = 1
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: UIwidth, height: UIheight)
    }
    
    
    var cellImg:UIImageView?
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.cellImg
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = self.CV.visibleCells.first as? PicDetailCell
        if cell != nil{
            UIView.animate(withDuration: 0.3, animations: {
                cell?.scView.zoomScale = 1
            })
        }
    }
    
    
    var allHide = true{
        didSet{
            self.progressBar.isHidden = allHide
            self.toolbar.isHidden = allHide
        }
    }
    var doubleTapEvent = {Void()}
    func singleTap(tap:UITapGestureRecognizer) -> Void {
        if commentView.textView.isFirstResponder{
            commentView.textView.resignFirstResponder()
        }
        else{
            self.allHide = !self.allHide
        }
    }
    
    func doubleTap(tap:UITapGestureRecognizer){
        self.doubleTapEvent()
    }
    
    
    
    var guardIndex = 999
    @IBAction func sliderAction(_ sender: Any) {
        let step = 1/Float(imageArr.count - 1)
        let x = Int(slider.value / step)
        if x > guardIndex{
            self.CV.scrollToItem(at: IndexPath.init(item: guardIndex + 1, section: 0), at: .right, animated: true)
            slider.value = Float(guardIndex + 1) * step
        }else{
            self.CV.scrollToItem(at: IndexPath.init(item: x, section: 0), at: .right, animated: true)
        }
        
    }
    
    
//    @IBAction func savePic(_ sender: Any) {
//        let cell = self.CV.visibleCells.first as? PicDetailCell
//        if cell?.img.image != nil{
//            UIImageWriteToSavedPhotosAlbum((cell?.img.image!)!, self, #selector(self.image(image:didFinishSavingWithErrorerror:contextInfo:)), nil)
//        }
//    }
//    
//    @objc private func image(image: UIImage, didFinishSavingWithErrorerror:NSError?,contextInfo:AnyObject) {
//        if (didFinishSavingWithErrorerror == nil){
//            DeeShareMenu.messageFrame(msg: "下载成功", view: self.view)
//        }
//        else{
//            print(didFinishSavingWithErrorerror!)
//        }
//    }
    
    @IBAction func closeView(_ sender: Any) {
        topView.isHidden = !topView.isHidden
        if topView.isHidden{
            self.barrageSwitch.setImage(UIImage.init(named: NSLocalizedString("开弹幕", comment: "")), for: .normal)
        }
        else{
            self.barrageSwitch.setImage(UIImage.init(named: NSLocalizedString("关弹幕", comment: "")), for: .normal)
        }
    }
    
    func donotWatch() -> Void {
        timer.invalidate()
        self.dismiss(animated: true, completion: {
            //            self.delegate?.closeAnimate()
        })
    }
    
    @IBAction func backBtn(_ sender: Any) {
        timer.invalidate()
        self.dismiss(animated: true, completion: {
//            self.delegate?.closeAnimate(complete: <#() -> Void#>)
        })
    }
    
    var payViewController = PayViewController()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        payViewController = segue.destination as! PayViewController
        payViewController.delegate = self
    }
    
    
    
    var showPay = false{
        didSet{
            payVC.isHidden = !showPay
            DeeSetView.setAnimate(view: payVC, orginW: 0, orginH: 0, pointX: UIwidth / 2, pointY: UIheight / 2 , width: UIwidth * 0.8, height: UIheight * 5 / 9, key: "adView")
            self.CV.isScrollEnabled = !showPay
            slider.isEnabled = !showPay
            if showPay{
                self.getAD()
            }
        }
    }
    
    func getAD() -> Void {
        interstitialObj.loadAd()
    }
    
    
    func rechargeVIP() -> Void {
        AimiFunction.checkLogin(controller: self) {
            //            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TopUpVC") as! TopUpVC
            //            let vc = AcountViewController()
            let vc = MiCoinViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    func getMoreCoin() -> Void {
        self.interstitialObj.present(fromRootViewController: self)
    }
    
    
    var interstitialObj = GDTMobInterstitial()
    
    func interstitialClicked(_ interstitial: GDTMobInterstitial!) {
        self.payed = true
        self.showPay = false
        UserDefaults.standard.set(0, forKey: "AD")
        UserDefaults.standard.synchronize()
        
    }
    func interstitialSuccess(toLoadAd interstitial: GDTMobInterstitial!) {
        print("成功读取广告")
    }
    func interstitialFail(toLoadAd interstitial: GDTMobInterstitial!, error: Error!) {
        print("读取广告失败")
    }
    func interstitialDidDismissScreen(_ interstitial: GDTMobInterstitial!) {
        interstitialObj.loadAd()
    }
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = true
        timer.invalidate()
    }
    
    
    
    @IBAction func showCommentDetails(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PicAndVideoCommentView") as! PicAndVideoCommentView
        vc.aid = self.model.iid
        vc.contentType = "1"
        self.navigationController?.pushViewController(vc, animated:  true)
    }
    
    @IBOutlet weak var writeCommentBtn: UIButton!
    @IBAction func writeBtnClick(_ sender: Any) {
        self.commentView.aid = self.model.iid
        self.commentView.sendType = "comment"
        self.commentView.contentType = "1"
        self.commentView.ruid = self.model.uid
        self.commentView.textView.becomeFirstResponder()
    }
    
    var shareImg = UIImage()
    var shareTitle = String()
    var shareUrl = String()
    var shareDesc = String()
    
    @IBOutlet weak var collectBtn: UIButton!
    @IBAction func comment(_ sender: Any) {
        collectPic()
    }
    
    func collectPic() -> Void {
        //        self.collectBtn.isSelected = !self.collectBtn.isSelected
        if UserDefaults.standard.bool(forKey: "isLogin") {
            let uid = UserDefaults.standard.integer(forKey: "uid")
            var parameters: NSMutableDictionary
            var url = ""
            if self.isCollected == false {
                parameters = ["uid":uid,"iid": self.model.iid]
                url = "https://aimi.cupiday.com/\(AIMIversion)/ifavorite"
            } else {
                parameters = ["uid":uid,"iid": self.model.iid]
                url = "https://aimi.cupiday.com/\(AIMIversion)/delfavour"
            }
            
            DeeRequest.requestPost(url: url, dic: parameters as NSDictionary, success: { (data) in
                
                guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                    print("解析数据失败!")
                    return
                }
                if (json.object(forKey: "error") as! NSNumber).isEqual(to: 0){
                    if (json.object(forKey: "message") as! String) == "收藏成功"{
                        self.collectBtn.isSelected = true
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("收藏成功!", comment: ""), view: self.view)
                        self.isCollected = true
                    }
                    else if (json.object(forKey: "message") as! String) == "删除成功"{
                        self.collectBtn.isSelected = false
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("删除收藏成功!", comment: ""), view: self.view)
                        self.isCollected = false
                    }
                }
                else{
                    print("解析失败!")
                }
            }, fail: { (error) in
                
            }, Pro: {(pro) in
            })
            
        }
        else{
            DeeShareMenu.messageFrame(msg: Locale.cast(str: "未登录请到历史处查看!"), view: self.view)
        }
    }
    @IBAction func shareBtnClick(_ sender: Any) {
        let cell = self.CV.visibleCells.first as! PicDetailCell
        if let img = cell.img.image{
            shareImg = img
            shareTitle = model.title
            self.custom.shareModel = ShareModel.init(url: (cell.img.kf.webURL?.absoluteString)!, img: img, type: SSDKContentType.image)
            self.custom.showView {
            }
        }
    }
    
    
}
