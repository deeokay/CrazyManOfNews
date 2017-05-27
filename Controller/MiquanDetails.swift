

//
//  MiquanDetails.swift
//  AimiHealth
//
//  Created by apple on 2016/12/9.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit
import MMPopupView
import CoreData
import AVFoundation
import MJExtension
import Kingfisher
var keepWarning = true

class MiquanDetails: MiquanDetail_SupuerVC, UIGestureRecognizerDelegate {
    @IBOutlet weak var adjustView: UIView!
    @IBOutlet weak var progress: UISlider!
    @IBOutlet weak var naviTitle: UIButton!
//    var model = ArticleModel()
    var typeStr = NSString()
    var commentView = WriteComment()
    var commentArr = NSArray()
    var hotCommentArr  = NSArray()
    var refreshLevel = 0
    var isLoaded = false
    var needToRecord = true
    var uid = UserDefaults.standard.integer(forKey: "uid")
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var TB: UITableView!
    @IBOutlet weak var writeCommentBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    var alertView = UIAlertController()
    var shareMenu = DeeShareMenu()
    var customView = CustomMenu()
//    var delegate:Miquan?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.data()
        self.setReportView()
        self.TB.tableFooterView = UIView()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        let dView = DeeSetView()
        commentView = dView.creatCommentView(controller: self)
        dView.sendCallBack = {
            self.data()
            DeeShareMenu.messageFrame(msg: NSLocalizedString("评论成功!", comment: ""), view: self.view)
        }
        

        defer{
            let fontsize = action.init(picName: "字体大小",delegate: self)
            fontsize.point = fontsize
            fontsize.insertGuidePic()
            let collect = action.init(picName: "收藏引导",delegate: self)
            collect.point = collect
            collect.insertGuidePic()
        }
        
        

        
        self.writeCommentBtn.layer.borderColor = UIColor.lightGray.cgColor
        self.webView.delegate = self
        
        shareMenu = DeeShareMenu()
        alertView = shareMenu.shareSysMenu()
        UIApplication.shared.applicationSupportsShakeToEdit = true
        let nib = UINib.init(nibName: "CC", bundle: nil)
        self.TB.register(nib, forCellReuseIdentifier: "CC")
        if model.article_type == 0 {
            self.level = 0
            self.loadWeb()
            self.naviTitle.alpha = 0
            self.naviTitle.setTitle(model.title, for: .normal)
            self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "white"), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
        else{
            self.level = 1
            self.loadAudio()
            self.naviTitle.setTitle(NSLocalizedString("语音文章", comment: ""), for: .normal)
            self.naviTitle.isHidden = false
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            
            
        }
        
        if self.needToRecord{
            DispatchQueue.global().async {
                let saveDic = self.model.mj_keyValues()
                _ = AimiData.addDictionaryToCoreData(aid: self.model.aid, type: 1, dic: saveDic!)
            }
        }
        
        
        
        self.setCustomView()
        UserDefaults.standard.set(0, forKey: transformLevel)
        UserDefaults.standard.synchronize()
        // 判断用户有没有点赞、收藏
        let dic = ["uid":UserDefaults.standard.integer(forKey: "uid"),"id":model.aid,"type":0] as NSDictionary
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/control", dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                print("读取收藏Json失败!")
                return
            }
            if json.object(forKey: "error") as! Int == 0 {
                if json.object(forKey: "zan") as! Int == 1{
                    self.collectBtn.setImage(UIImage.init(named: "collection-icon-selected"), for: .selected)
                    self.collectBtn.isSelected = true
                    self.collect = true
                } else {
                    self.collectBtn.setImage(UIImage.init(named: "collection-icon"), for: .normal)
                    self.collectBtn.isSelected = false
                    self.collect = false
                }
            }
            
        }, fail: { (err) in
            print("请求收藏接口失败!",err.localizedDescription)
        }) { (pro) in
        }
        
        let size = UserDefaults.standard.object(forKey: "contentSize") as! String
        var pro:Float = 0
        switch size {
        case "94%":
            pro = 0
        case "100%":
            pro = 0.33
        case "110%":
            pro = 0.66
        case "120%":
            pro = 1
        default:
            break
        }
        self.progress.value = pro
    }
    
    @IBAction func WebViewGoToTop(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.webView.scrollView.mj_offsetY = -64
        }
    }
    
    
    
//    var shadowTimer = Timer()
    var transformView = UIView()
//    var audioView = Audio()
    func loadAudio() -> Void {
        self.audioView = Bundle.main.loadNibNamed("Audio", owner: self, options: nil)?.last as! Audio
//        audioView.delegate = self
        audioView.frame = CGRect.init(x: 0, y: 0, width: UIwidth, height: UIheight * 0.6)
        audioView.articleImage.layer.cornerRadius = UIwidth * 0.2
        audioView.playBtn.layer.cornerRadius = UIwidth * 0.18
        audioView.title.text = model.title
        audioView.subTitle.text = model.writer
        audioView.alpha = 0
        if let bgUrl = URL.init(string: model.bgUrl){
            audioView.bgImage.kf.setImage(with: bgUrl)
        }
        if let imgUrl = URL.init(string: model.bgAvatar){
            audioView.articleImage.kf.setImage(with: imgUrl)
        }
        self.view.addSubview(audioView)
        self.view.sendSubview(toBack: self.audioView)
        UIView.animate(withDuration: 0.5) {
            self.audioView.alpha = 1
        }
        
        self.audioView.shadowAction = {
            let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
            imageView.center = self.audioView.articleImage.center
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleToFill
            self.audioView.addSubview(imageView)
            if let imgUrl = URL.init(string: self.model.bgAvatar){
                imageView.kf.setImage(with: imgUrl)
                imageView.image = imageView.image?.iv_drawRectWithRoundedCorner(radius: UIwidth * 0.5, size: CGSize.init(width: UIwidth * 1, height: UIwidth * 1))
            }
            UIView.animate(withDuration: 1, animations: {
                imageView.mj_size = CGSize.init(width: UIwidth * 1, height: UIwidth * 1)
                imageView.center = self.audioView.articleImage.center
                imageView.alpha = 0
            }, completion: { (f) in
                if f{
                    imageView.removeFromSuperview()
                }
            })
        }
        if model.aid != audioID{
            audioID = self.model.aid
            self.showHud(in: self.audioView)
            if let url = URL.init(string: model.audioUrl){
                let item = AVPlayerItem.init(url: url)
                player = AimiPlayer.share.player
                player.replaceCurrentItem(with: item)
                player.play()
                AVplaying = true
            }
            else{
                print("出现播放错误!")
                self.hideHud()
            }
        }
        else{
            self.audioView.playing = AVplaying
        }
    }
    
    
    var player = AVPlayer()
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.customView.hideView(complete: {
        })
        self.adjustView.alpha = 0
        self.reportView.alpha = 0
        if self.webView.scrollView.contentOffset.y < 0{
            self.naviTitle.alpha = 1.0 / abs(self.webView.scrollView.contentOffset.y)
        }
        else{
            self.naviTitle.alpha = 1
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.naviTitle.isHidden{
            self.naviTitle.isHidden = false
        }
    }
    
    var reportView = Report()
    func setReportView() -> Void {
        self.reportView = Bundle.main.loadNibNamed("Report", owner: self, options: nil)?.first as! Report
        reportView.frame.size = CGSize.init(width: UIwidth * 0.5, height: UIheight * 0.4)
        reportView.center = self.view.center
        reportView.alpha = 0
        self.view.addSubview(self.reportView)
        reportView.submitAction = {
            let alert = UIAlertController.init(title: NSLocalizedString("提示", comment: ""), message: NSLocalizedString("感谢您的举报！我们会在24小时内做出处理，如情况属实，我们会立即删除。", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title:NSLocalizedString("朕知道了", comment: ""), style: .destructive, handler: { (action) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.reportView.alpha = 0
                })
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func adjustTextSize(_ sender: Any) {
        var size = ""
        var pro:Float = 0
        switch self.progress.value {
        case 0...0.16:
            size = "94%"
            pro = 0
        case 0.17...0.49:
            size = "100%"
            pro = 0.33
        case 0.5...0.82:
            size = "110%"
            pro = 0.66
        case 0.82...1:
            size = "120%"
            pro = 1
        default:
            break
        }
        self.progress.value = pro
        self.webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '\(size)'")
        UserDefaults.standard.set(size, forKey: "contentSize")
        UserDefaults.standard.synchronize()
        
    }
    
    
    func setCustomView() -> Void {
        customView = Bundle.main.loadNibNamed("CustomMenu", owner: self, options: nil)?.last as! CustomMenu
        customView.frame = CGRect.init(x: 0, y: UIheight, width: UIwidth, height: UIheight * 0.4)
        self.shareImg = UIImage.init(named: "logo")!
        DispatchQueue.global().async {
            if let img = UIImage.animatedImage(withUrl: self.model.imgUrl) {
                self.shareImg = img
            }
            else{
                print("生成分享图片失败!使用老图吧~")
            }
            var link = self.model.link
            if self.model.article_type != 0 {
                link = self.model.audioUrl
            }
            self.customView.shareModel = ShareModel.init(url: link, img: self.shareImg, type: SSDKContentType.auto)
        }
        customView.successToShareCallback = {
            self.customView.hideView(complete: { 
            })
        }
        self.customView.loading = {
            self.showHud(in: self.view, hint: "分享中...", yOffset: 0, interaction: false)
        }
        self.customView.handlingResult = {
            self.hideHud()
        }
        customView.failToShareCallback = {
            self.hideHud()
            self.showHint(in: self.view, hint: "分享失败!", duration: 1, yOffset: 0)
        }
        self.view.addSubview(customView)
        let refreshModel = ActionModel()
        refreshModel.img = UIImage.init(named: "刷新内容")!
        refreshModel.title = NSLocalizedString("刷新", comment: "")
        refreshModel.action = {
            self.loadWeb()
            self.data()
            UIView.animate(withDuration: 0.2, animations: {
                self.customView.mj_origin = CGPoint.init(x: 0, y: UIheight)
            })
        }
        let adjustText = ActionModel()
        adjustText.title = NSLocalizedString("调整字体", comment: "")
        adjustText.img = UIImage.init(named: "字体设置")!
        adjustText.action = {
            self.view.bringSubview(toFront: self.adjustView)
            UIView.animate(withDuration: 0.3, animations: {
                self.customView.mj_origin = CGPoint.init(x: 0, y: UIheight)
                self.adjustView.alpha = 1
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            })
        }
        let report = ActionModel()
        report.title = NSLocalizedString("举报", comment: "")
        report.img = UIImage.init(named: "举报")!
        report.action = {
            UIView.animate(withDuration: 0.3, animations: {
                self.reportView.alpha = 1
                self.customView.mj_origin = CGPoint.init(x: 0, y: UIheight)
            })
        }
        let shield = ActionModel()
        shield.title = NSLocalizedString("屏蔽", comment: "")
        shield.img = UIImage.init(named: "屏蔽内容")!
        shield.action = {
            AimiFunction.shield(id: self.model.aid, type: 0, success: {
                self.delegate?.shieldModel = self.model
                self.delegate?.shieldContent = true
                DeeShareMenu.messageFrame(msg: Locale.cast(str: "屏蔽成功!"), view: self.view)
            })
            self.customView.hideView(complete: {
            })
        }
        
        self.customView.actionArr.append(refreshModel)
        self.customView.actionArr.append(adjustText)
        self.customView.actionArr.append(report)
        self.customView.actionArr.append(shield)
        customView.cancelAction = {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.backgroundColor = UIColor.clear
                self.view.alpha = 1
            })
        }
    }
    
    func loadWeb() -> Void {
        if let link = URL.init(string: model.link){
            webView.loadRequest(URLRequest.init(url: link))
            let size = UserDefaults.standard.object(forKey: "contentSize") as! String
            self.webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(size)'")
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        DeeSetView().releaseKeyboardObserver()
    }
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake{
            if UserDefaults.standard.bool(forKey: "shankeShare"){
                UIApplication.shared.keyWindow?.endEditing(true)
                self.customView.showView(complete: {
                })
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.hotCommentArr.count
        default:
            return self.commentArr.count
        }
    }
    
    
    @IBAction func DoubleTouchWebView(_ sender: Any) {
        if level == 2{
            level = 1
        }
        else{
            level = 2
        }
    }
    
    
    
    
    
    
    
    var show_more = false
    @IBAction func more(_ sender: Any) {
        show_more = !show_more
        if show_more{
            UIApplication.shared.keyWindow?.endEditing(true)
            self.customView.showView(complete: {
            })
        }
        else{
            self.customView.hideView(complete: {
                
            })
        }
        
    }
    
    var level = 1{
        didSet{
            UserDefaults.standard.set(level, forKey: transformLevel)
            UserDefaults.standard.synchronize()
            self.commentBtn.isEnabled = false
            if model.article_type == 0{
                transformView = self.webView
            }
            switch level {
            case 0:
                UIView.animate(withDuration: 0.3, animations: {
                    self.transformView.frame = CGRect.init(x: 0, y: 0, width: UIwidth, height: UIheight - 44)
                    self.TB.mj_origin = CGPoint.init(x: 0, y: UIheight)
                }, completion: { (finish) in
                    if finish{
                        self.TB.frame = CGRect.init(x: 0, y: UIheight, width: UIwidth, height: 0)
                        self.commentBtn.isEnabled = true
                    }
                })
            case 1:
                UIView.animate(withDuration: 0.3, animations: {
                    self.transformView.frame = CGRect.init(x: 0, y: 0, width: UIwidth, height: UIheight * 0.6)
                    self.TB.frame = CGRect.init(x: 0, y: UIheight * 0.6, width: UIwidth, height: UIheight)
                }, completion: { (finish) in
                    if finish{
                        self.commentBtn.isEnabled = true
                        self.TB.frame = CGRect.init(x: 0, y: UIheight * 0.6, width: UIwidth, height: UIheight - UIheight * 0.6 - 44)
                    }
                })
            case 2:
                UIView.animate(withDuration: 0.5, animations: {
                    self.TB.frame = CGRect.init(x: 0, y: 64, width: UIwidth, height: UIheight - 108)
                }, completion: { (finish) in
                    if finish{
                        self.commentBtn.isEnabled = true
                    }
                })
            default:
                break
            }
            self.TB.reloadData()
        }
    }
    
    func tapClick() -> Void {
        self.level = 0
    }
    
    func transform() -> Void {
        if level == 2{
            level = 1
        }
        else{
            level += 1
        }
    }
    @IBAction func jumpToCommentArea(_ sender: Any) {
        if model.article_type == 0{
            transform()
        }
        else{
            if level == 1{
                level = 2
            }
            else{
                level = 1
            }
        }
    }
    
    
    var collect = false
    @IBOutlet weak var collectBtn: UIButton!
    @IBAction func collectBtnClick(_ sender: Any) {
        self.collectBtn.isSelected = !self.collectBtn.isSelected
        if UserDefaults.standard.bool(forKey: "isLogin") {
            let uid = UserDefaults.standard.integer(forKey: "uid")
            var parameters = NSMutableDictionary()
            var url = ""
            if self.collectBtn.isSelected == true {
                parameters = ["uid": uid,"aid": self.model.aid]
                url = "https://aimi.cupiday.com/\(AIMIversion)/afavorite"
            }
            else{
                parameters = ["uid":self.uid,"aid": self.model.aid]
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
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("收藏文章成功!", comment: ""), view: self.view)
                        self.collect = true
                    }
                    else if (json.object(forKey: "message") as! String) == "删除成功"{
                        self.collectBtn.isSelected = false
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("删除收藏成功!", comment: ""), view: self.view)
                        self.collect = false
                    }
                }
                else{
                    self.collectBtn.isSelected = !self.collectBtn.isSelected
                }
            }, fail: { (error) in
                
            }, Pro: {(pro) in
            })
        }
        else{
            DeeShareMenu.messageFrame(msg: Locale.cast(str: "未登录请到历史处查看!"), view: self.view)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.adjustView.alpha = 0
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    
    
    //  评论列表
    func data() -> Void{
        let dic = ["aid":self.model.aid,"type":0,"uid":uid]
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/comment", dic: dic as NSDictionary, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                DeeShareMenu.messageFrame(msg: NSLocalizedString("服务器错误", comment: ""), view: self.view)
                print("解析数据失败!")
                return
            }
            if let arr = json.value(forKey: "body") as! NSArray?{
                self.commentArr = arr
                if !self.isLoaded{
                    self.isLoaded = true
                }
                
            }
            if let arr = json.value(forKey: "hot") as! NSArray?{
                self.hotCommentArr = arr
            }
            
            
            
            self.TB.reloadData()
            if self.refreshLevel == 0 && self.commentArr.count > 0{
                self.TB.scrollToRow(at: IndexPath.init(item: 0, section: 1), at: .top, animated: false)
            }
        }, fail: { (error) in
            print(error)
        }, Pro: { (pro) in
            print(pro)
        })
        
    }
    
    
    
    // 写评论
    @IBAction func showCommentView(_ sender: Any) {
        self.commentView.aid = self.model.aid
        self.commentView.sendType = "comment"
        self.commentView.contentType = "0"
        self.commentView.ruid = self.model.uid
        self.commentView.textView.becomeFirstResponder()
        self.refreshLevel = 0
    }
    
    var shareImg = UIImage()
    var shareTitle = String()
    var shareUrl = String()
    var shareDesc = String()
    var shareType = SSDKContentType.webPage
    
    @IBAction func shareBtnClick(_ sender: Any) {
        UIApplication.shared.keyWindow?.endEditing(true)
        self.customView.showView(complete: {
        })
        reportView.id = self.model.aid
        reportView.type = 1
    }
    func share() -> Void {
        shareMenu.shareDic = DeeShareMenu.shareContent(shareThumImage: &shareImg, shareTitle: shareDesc, shareDescr: shareTitle, url: shareUrl, shareType: shareType)
        shareMenu.stateHandler = DeeShareMenu.stateHandle(controller: self, success: {
            self.shareType = SSDKContentType.webPage
        }, fail: {
            self.shareType = SSDKContentType.text
        })
        self.present(alertView, animated: true, completion: nil)
    }
}

// 网页加载代理
extension MiquanDetails: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.showHud(in: self.view, hint: "加载中...", yOffset: 0, interaction: false)
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.hideHud()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        let size = UserDefaults.standard.object(forKey: "contentSize") as! String
        self.webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(size)'")
        UIView.animate(withDuration: 0.5, animations: {
            webView.alpha = 1
            self.webView.scrollView.mj_offsetY = -64
        }){(f) in
            if f{
                self.webView.scrollView.delegate = self
                //                    self.naviTitle.isHidden = false
            }
            
        }
    }
}

// tableview代理、数据源
extension MiquanDetails: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: UIwidth, height: 30))
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        var str = ""
        switch section {
        case 0:
            str = NSLocalizedString("热门评论", comment: "")
            
        case 1:
            str = NSLocalizedString("最新评论", comment: "")
        default:
            break
        }
        if model.article_type == 0{
            switch level {
            case 1:
                str += NSLocalizedString("(双击底部可开关评论)", comment: "")
            case 2:
                str += NSLocalizedString("(双击底部可开关评论)", comment: "")
            default:
                break
            }
        }
        label.text = str
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIwidth, height: 30))
        if model.article_type == 0{
            let btn = UIButton.init(frame: CGRect.init(x: UIwidth - 45, y: 3, width: 40, height: 24))
            btn.layer.borderColor = UIColor.darkGray.cgColor
            btn.layer.borderWidth = 1
            btn.layer.cornerRadius = 5
            btn.clipsToBounds = true
            btn.setTitle(NSLocalizedString("隐藏", comment: ""), for: .normal)
            btn.tintColor = UIColor.blue
            view.addSubview(btn)
            btn.setTitleColor(UIColor.black, for: .normal)
            btn.addTarget(self, action: #selector(self.tapClick), for: .touchUpInside)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            btn.titleLabel?.textAlignment = .right
        }
        view.backgroundColor = UIColor.lightGray
        view.addSubview(label)
        return view
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.hotCommentArr.count == 0{
            return 0
        }
        else{
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CC", for: indexPath) as! CC
        var dic = NSDictionary()
        if indexPath.section == 0{
            dic = self.hotCommentArr[indexPath.row] as! NSDictionary
        }else if indexPath.section == 1{
            dic = self.commentArr[indexPath.row] as! NSDictionary
        }
        cell.reportAction = {
            self.reportView.id = dic.object(forKey: "cid") as! Int
            self.reportView.type = 4
            UIView.animate(withDuration: 0.3, animations: {
                self.reportView.alpha = 1
            })
        }
        cell.nickName.text = dic.object(forKey: "username") as! String?
        cell.img.kf.setImage(with: URL.init(string: dic.object(forKey: "avatar") as! String))
        cell.commentContent.text = dic.object(forKey: "content") as! String?
        let likecount = dic.object(forKey: "hot") as! NSNumber
        let zan = dic.object(forKey: "zan") as! NSNumber
        if zan.isEqual(to: 0){
            cell.like_Count.setTitleColor(UIColor.lightGray, for: .normal)
        }
        else{
            cell.like_Count.setTitleColor(UIColor.red, for: .normal)
        }
        if likecount.isEqual(to: 0){
            cell.like_Count.setTitle("", for: .normal)
        }
        else{
            cell.like_Count.setTitle("" + String(describing: likecount), for: .normal)
        }
        var str = ""
        var replyArr = NSArray()
        let style = NSMutableParagraphStyle.init()
        style.headIndent = 5
        style.firstLineHeadIndent = 5
        style.lineSpacing = 3
        let user = NSMutableAttributedString.init()
        replyArr = dic.object(forKey: "reply") as! NSArray
        if replyArr.count != 0{
            for i in  0..<replyArr.count{
                let replyDic = replyArr[i] as! NSDictionary
                let userName = replyDic.object(forKey: "username") as! NSString
                var context = replyDic["content"] as! NSString
                context = context.replacingOccurrences(of: "\n", with: " ") as NSString
                str += (userName as String) + " : " + (context as String) + "\n"
            }
            let arr = str.components(separatedBy: "\n")
            for i in arr{
                let subArr = i.components(separatedBy: " : ")
                let nickName = NSMutableAttributedString.init(string: subArr.first!)
                if nickName.length > 0{
                    nickName.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: NSRange.init(location: 0, length: nickName.length))
                    user.append(nickName)
                    user.append(NSAttributedString.init(string: " : " + subArr.last! + "\n"))
                }
            }
            
            if replyArr.count > 0{
                let show = NSMutableAttributedString.init(string: NSLocalizedString("参与更多评论...", comment: ""))
                show.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange.init(location: 0, length: show.length))
                user.append(show)
            }
            user.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange.init(location: 0, length: user.length - 1))
        }
        cell.building.attributedText = user
        cell.time.text = dic.object(forKey: "create_time") as! String?
        cell.quickCommentAction = {
            var dic = NSDictionary()
            if indexPath.section == 0{
                dic = self.hotCommentArr[indexPath.row] as! NSDictionary
            }else if indexPath.section == 1{
                dic = self.commentArr[indexPath.row] as! NSDictionary
            }
            self.commentView.sendType = "type"
            self.commentView.aid = self.model.aid
            self.commentView.cid = dic.object(forKey: "cid") as! NSInteger
            self.commentView.contentType = "0"
            self.commentView.rname = ""
            self.commentView.textView.becomeFirstResponder()
            self.refreshLevel = 1
            
        }
        
        if (dic.object(forKey: "zan") as! NSNumber).isEqual(to: 1){
            cell.like_Count.setTitleColor(UIColor.red, for: .normal)
            cell.like_Count.setImage(UIImage.init(named: "liked"), for: .normal)
            
        }
        else{
            cell.like_Count.setTitleColor(UIColor.lightGray, for: .normal)
            cell.like_Count.setImage(UIImage.init(named: "like"), for: .normal)
            
        }
        cell.clickLikeCountActtion = {
            if (dic.object(forKey: "zan") as! NSNumber).isEqual(to: 1){
            }
            else{
                AimiFunction.checkLogin(controller: self) {
                    cell.like_Count.isUserInteractionEnabled = false
                    self.uid = UserDefaults.standard.integer(forKey: "uid")
                    let cid = dic.object(forKey: "cid") as! NSNumber
                    let ruid = dic.object(forKey: "uid") as! NSNumber
                    let likeDic = ["uid":self.uid,"id":cid,"ruid":ruid,"type":0] as NSDictionary
                    DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/favour", dic: likeDic, success: { (data) in
                        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                            DeeShareMenu.messageFrame(msg: NSLocalizedString("点赞失败!", comment: ""), view: self.view)
                            return
                        }
                        let err = json.object(forKey: "error") as! NSNumber
                        if err.isEqual(to: 0){
                            self.refreshLevel = 1
                            self.data()
                            cell.like_Count.isUserInteractionEnabled = true
                        }
                    }, fail: { (err) in
                        cell.like_Count.isUserInteractionEnabled = true
                    }, Pro: { (pro) in
                    })
                }
                
            }
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CommentDetails") as! CommentDetails
        var dic = NSDictionary()
        if indexPath.section == 0{
            dic = self.hotCommentArr[indexPath.row] as! NSDictionary
        }else if indexPath.section == 1{
            dic = self.commentArr[indexPath.row] as! NSDictionary
        }
        vc.reply  = dic
        vc.contentType = "0"
        vc.aid = self.model.aid
        self.navigationController?.pushViewController(vc, animated:  true)
    }
}
