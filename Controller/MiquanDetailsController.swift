//
//  MiquanDetailsController.swift
//  Aimi-V1.1
//
//  Created by Ivanlee on 2017/4/17.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData
import MJExtension
import MMPopupView
import SwiftyJSON
import SnapKit
import WebKit
import AVFoundation

var audioID = 0
class MiquanDetailsController: HideTabbarController, UIGestureRecognizerDelegate {
    
    // 导航栏
    @IBOutlet weak var navTitleBtn: UIButton!
    var model = ArticleModel()
    var delegate:Miquan?
    // 正文
    var contentWebView: WKWebView!
    var contentHeight: CGFloat = 0.0
    var player = AVPlayer()
    var shadowTimer = Timer()
    var audioView = Audio()
    // 底部工具栏
    var bottomView: BottomView!
    var customView = CustomMenu()
    
    lazy var cust:CustomMenu = {
        self.setupShareArea()
        return self.customView
    }()
    
    
    var adjustView: AdjustView!
    // 评论
    var commentTableView: UITableView!
    var commentArr = Array<JSON>()
    var hotCommentArr = Array<JSON>()
    var writeCommentArea = WriteComment()
    // 分享
    var shareImg = UIImage()
    var shareTitle = String()
    var shareUrl = String()
    var shareDesc = String()
    var shareType = SSDKContentType.webPage
    // 举报
    var reportView = Report()
    // 收藏
    var isCollected = false
    // 历史记录
    var needToRecord = true
    let uid: Int = UserDefaults.standard.integer(forKey: "uid")

    // MARK: - 生命周期
    @available(iOS 9.0, *)
    func setActions() -> NSArray {
        var status = "先收藏"
        var type = UIPreviewActionStyle.default
        if self.isCollected{
            status = "删除收藏"
            type = .destructive
        }
        let a2 = UIPreviewAction.init(title: status, style: type) { (action, vc) in
            self.navigationController?.pushViewController(vc, animated: true)

            if UserDefaults.standard.bool(forKey: "isLogin") {
                if self.isCollected == false {
                    self.setArticleCollected(is: true)
                    self.bottomView.collectBtn.isSelected = true
                } else {
                    self.setArticleCollected(is: false)
                    self.bottomView.collectBtn.isSelected = false
                }
            } else {
                DeeShareMenu.messageFrame(msg: Locale.cast(str: "未登录请到历史处查看!"), view: self.view)
            }
        }
        return [a2]
    }
    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem]{
        return setActions() as! [UIPreviewActionItem]
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        UIApplication.shared.applicationSupportsShakeToEdit = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        defer{
            let fontsize = action.init(picName: "字体大小",delegate: self)
            fontsize.point = fontsize
            fontsize.insertGuidePic()
            let collect = action.init(picName: "收藏引导",delegate: self)
            collect.point = collect
            collect.insertGuidePic()
        }
        // 底部工具条
        setupBottomView()
        // 顶部导航栏
        setupNavBar()
        // 评论列表
        setupCommentTableView()
        // 网页正文
        if model.article_type == 0 { setupContentWebView() }
            // 音频文章
            else { setupAudioView() }
        // 分享
        setupShareArea()
        // 其他初始化
        setupOtherInitaialzations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
    }

    // MARK: - 页面初始化
    private func setupBottomView() {
        fetchCollectionInfo()
        bottomView = Bundle.main.loadNibNamed("BottomView", owner: self, options: nil)?.first as! BottomView
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(44)
        }
        // 进行评论
        bottomView.showCommentView = {
            self.writeCommentArea.aid = self.model.aid
            self.writeCommentArea.sendType = "comment"
            self.writeCommentArea.contentType = "0"
            self.writeCommentArea.ruid = self.model.uid
            self.writeCommentArea.textView.becomeFirstResponder()
        }
        // 评论展示
        bottomView.jumpToCommentArea = {
            // 去除tableView头部后单纯的评论内容的高度
            let commentHeight: CGFloat = self.commentTableView.contentSize.height - self.contentHeight
            // tableView可见内容的高度
            let tableHeight: CGFloat = UIheight - 64.0 - 44.0
            UIView.animate(withDuration: 0.3, animations: {
                if self.model.article_type == 0 {
                    if self.commentTableView.contentOffset.y < (self.contentHeight - tableHeight) {
                        // 评论够一整页就显示评论开头，不够一整页就显示到底
                        if commentHeight > tableHeight {
                            self.commentTableView.contentOffset.y = self.contentHeight
                        } else {
                            self.commentTableView.contentOffset.y = self.commentTableView.contentSize.height - tableHeight
                        }
                    } else {
                        self.commentTableView.contentOffset.y = 0.0
                    }
                } else {
                    if self.commentTableView.contentOffset.y >= UIheight * 0.6 - 20 {
                        self.commentTableView.contentOffset.y = 0.0
                    } else {
                        self.commentTableView.contentOffset.y = UIheight * 0.6 - 20
                    }
                }
            })
        }
        // 收藏
        bottomView.collectBtnClick = {
            if UserDefaults.standard.bool(forKey: "isLogin") {
                if self.isCollected == false {
                    self.setArticleCollected(is: true)
                    self.bottomView.collectBtn.isSelected = true
                } else {
                    self.setArticleCollected(is: false)
                    self.bottomView.collectBtn.isSelected = false
                }
            } else {
                DeeShareMenu.messageFrame(msg: Locale.cast(str: "未登录请到历史处查看!"), view: self.view)
            }
        }
        // 分享
        bottomView.shareBtnClick = {
            self.rightTopMoreAction()   // 和右上角的按钮功能一样
        }
    }
    
    private func setupNavBar() {
        if model.article_type == 0 {
            navTitleBtn.alpha = 0.0
            navTitleBtn.setTitle(model.title, for: .normal)
            navTitleBtn.setTitleColor(UIColor.black, for: .normal)
            navTitleBtn.titleLabel?.font = UIFont.init(name: "STHeitiSC-Medium", size: 15.0)
        }
    }
    
    private func setupContentWebView() {
        contentWebView = WKWebView.init(frame: UIScreen.main.bounds)
        // 防止出现多个滚动条
        contentWebView.scrollView.isScrollEnabled = false
        contentWebView.navigationDelegate = self
        guard let link = URL.init(string: model.link) else {
            DeeShareMenu.messageFrame(msg: Locale.cast(str: "没有网页数据"), view: self.view)
            return
        }
        contentWebView.load(URLRequest.init(url: link))
    }
    
    private func setupAudioView() {
        commentTableView.snp.remakeConstraints { (make) in
            make.edges.equalTo(view).inset(UIEdgeInsets.init(top: 0, left: 0, bottom: 44, right: 0))
        }
        // 导航栏透明
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        audioView = Bundle.main.loadNibNamed("Audio", owner: self, options: nil)?.last as! Audio
        audioView.frame = CGRect.init(x: 0, y: 0, width: UIwidth, height: UIheight * 0.6 - 64)
        audioView.delegate = self
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
        commentTableView.tableHeaderView = audioView
        UIView.animate(withDuration: 0.5) {
            self.audioView.alpha = 1.0
            self.commentTableView.alpha = 1.0
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
        loadAudioData()
    }
    
    //摇一摇分享
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake{
            if UserDefaults.standard.bool(forKey: "shankeShare"){
                UIApplication.shared.keyWindow?.endEditing(true)
                self.customView.showView(complete: {
                    self.z = true
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
    
    private func setupCommentTableView() {
        
        commentTableView = UITableView()
        view.addSubview(commentTableView)
        commentTableView.backgroundColor = UIColor.white
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.tag = 101
        commentTableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view).inset(UIEdgeInsets.init(top: 64, left: 0, bottom: 44, right: 0))
        }
        commentTableView.tableFooterView = UIView()
        commentTableView.layoutIfNeeded()
        // 正文页面加载完成之前，隐藏评论数据
        commentTableView.alpha = 0.0
        commentTableView.register(UINib.init(nibName: "CC", bundle: nil), forCellReuseIdentifier: "CC")
        // 评论网络数据
        loadCommentData()
        // 举报框
        setupReportView()
    }
    
    func setupShareArea() {
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
//            self.customView.shareModel = ShareModel.init(url: link, img: self.shareImg, type: SSDKContentType.auto)
            self.customView.shareModel = ShareModel.init(text: "爱米 爱她 爱健康", title: self.model.title, url: link, img: self.shareImg, type: .auto)
        }
        customView.successToShareCallback = {
            self.customView.hideView(complete: {
                self.z = false
            })
            self.showHint(in: self.view, hint: Locale.cast(str: "分享成功!"), duration: 1, yOffset: 0)
        }
        self.customView.loading = {
            self.showHud(in: self.view, hint: "分享中...", yOffset: 0, interaction: false)
        }
        self.customView.handlingResult = {
            self.hideHud()
        }
        customView.failToShareCallback = {
            self.hideHud()
            self.showHint(in: self.view, hint: Locale.cast(str: "分享失败!"), duration: 1, yOffset: 0)
        }
        view.addSubview(customView)
        let refreshModel = ActionModel()
        refreshModel.img = UIImage.init(named: "刷新内容")!
        refreshModel.title = Locale.cast(str: "刷新")
        refreshModel.action = {
            self.loadCommentData()
            self.setupContentWebView()
            UIView.animate(withDuration: 0.2, animations: {
                self.customView.mj_origin = CGPoint.init(x: 0, y: UIheight)
            })
        }
        adjustView = Bundle.main.loadNibNamed("AdjustView", owner: self, options: nil)?.first as! AdjustView
        var size = UserDefaults.standard.object(forKey: "contentSize") as! String
        switch size {
        case "85%":
            adjustView.progress.value = 0.0
        case "100%":
            adjustView.progress.value = 0.33
        case "110%":
            adjustView.progress.value = 0.66
        case "130%":
            adjustView.progress.value = 1.0
        default:
            break
        }
        adjustView.adjustTextSize = {
            var pro: Float = 0.0
            switch self.adjustView.progress.value {
            case 0.0...0.16:
                size = "85%"
                pro = 0.0
            case 0.17...0.49:
                size = "100%"
                pro = 0.33
            case 0.5...0.82:
                size = "110%"
                pro = 0.66
            case 0.83...1.0:
                size = "130%"
                pro = 1.0
            default:
                break
            }
            self.adjustView.progress.value = pro
            self.contentWebView.evaluateJavaScript("document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(size)'", completionHandler: nil)
            self.contentHeight = 0.0
            self.contentWebView.frame.size = CGSize.init(width: UIwidth, height: self.contentHeight)
            self.contentWebView.evaluateJavaScript("document.body.scrollHeight") { (height, err) in
                guard let h = height else {
                    print("获取高度失败！")
                    return
                }
                print(h)
                self.contentHeight = h as! CGFloat
                self.contentWebView.frame.size = CGSize.init(width: UIwidth, height: self.contentHeight)
                self.commentTableView.tableHeaderView = self.contentWebView
            }
            UserDefaults.standard.set(size, forKey: "contentSize")
            UserDefaults.standard.synchronize()
        }
        let adjustText = ActionModel()
        adjustText.title = Locale.cast(str: "调整字体")
        adjustText.img = UIImage.init(named: "字体设置")!
        adjustText.action = {
            self.view.addSubview(self.adjustView)
            self.adjustView.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.view.snp.bottom)
                make.left.equalTo(self.view.snp.left)
                make.right.equalTo(self.view.snp.right)
                make.height.equalTo(self.view.snp.height).multipliedBy(0.2)
            }
            self.view.bringSubview(toFront: self.adjustView)
            UIView.animate(withDuration: 0.3, animations: {
                self.customView.mj_origin = CGPoint.init(x: 0, y: UIheight)
                self.adjustView.alpha = 1
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            })
        }
        let report = ActionModel()
        report.title = Locale.cast(str: "举报")
        report.img = UIImage.init(named: "举报")!
        report.action = {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.addSubview(self.reportView)
                self.reportView.alpha = 1
                self.customView.mj_origin = CGPoint.init(x: 0, y: UIheight)
            })
        }
        let shield = ActionModel()
        shield.title = Locale.cast(str: "屏蔽")
        shield.img = UIImage.init(named: "屏蔽内容")!
        shield.action = {
            AimiFunction.shield(id: self.model.aid, type: 0, success: {
                self.delegate?.shieldModel = self.model
                self.delegate?.shieldContent = true
                DeeShareMenu.messageFrame(msg: Locale.cast(str: "屏蔽成功!"), view: self.view)
            })
            self.customView.hideView(complete: {
                self.z = false
            })
        }
        customView.cancelAction = {
            self.z = false
        }
        customView.actionArr.append(refreshModel)
        if model.article_type == 0 {
            customView.actionArr.append(adjustText)
        }
        customView.actionArr.append(report)
        customView.actionArr.append(shield)
    }
    
    private func setupReportView() {
        
        reportView = Bundle.main.loadNibNamed("Report", owner: self, options: nil)?.first as! Report
        reportView.frame.size = CGSize.init(width: UIwidth * 0.5, height: UIheight * 0.4)
        reportView.center = self.view.center
        reportView.alpha = 0
        reportView.submitAction = {
            let alert = UIAlertController.init(title: Locale.cast(str: "提示"), message: Locale.cast(str: "感谢您的举报！我们会在24小时内做出处理，如情况属实，我们会立即删除。"), preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: Locale.cast(str: "朕知道了"), style: .destructive, handler: { (action) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.reportView.alpha = 0
                })
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func setupOtherInitaialzations() {
        // 存放到历史记录
        if self.needToRecord{
            DispatchQueue.global().async {
                let saveDic = self.model.mj_keyValues()
                _ = AimiData.addDictionaryToCoreData(aid: self.model.aid, type: 1, dic: saveDic!)
            }
        }
        // 写评论页面
        let setView = DeeSetView()
        writeCommentArea = setView.creatCommentView(controller: self)
        setView.sendCallBack = {
            self.loadCommentData()
            DeeShareMenu.messageFrame(msg: NSLocalizedString("评论成功!", comment: ""), view: self.view)
        }
    }
    
    // 点击右上角“…”按钮
    @IBAction func moreAction(_ sender: UIButton) {
        rightTopMoreAction()
    }
    
    
    var z = false
    func rightTopMoreAction() {
        UIApplication.shared.keyWindow?.endEditing(true)
        if z{
            self.cust.hideView(complete: {
                self.z = false
            })
        }
        else{
            self.cust.showView(complete: {
                self.z = true
            })
        }
        reportView.id = model.aid
        reportView.type = 1
    }
    
    // 点击标题栏回到顶部
    @IBAction func goTop(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) { 
            self.commentTableView.contentOffset.y = 0.0
        }        
    }
}


// MARK: - 数据加载区
fileprivate extension MiquanDetailsController {
    // 获取评论信息
    func loadCommentData() {
        let dic = ["aid": model.aid,
                   "type": 0,
                   "uid": uid]
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/comment", dic: dic as NSDictionary, success: { (data) in
            
            let jsonDict = JSON.init(data: data)
            guard jsonDict["error"].intValue == 0 else {
                DeeShareMenu.messageFrame(msg: Locale.cast(str: "加载评论信息失败！"), view: self.view)
                return
            }
            self.commentArr = jsonDict["body"].arrayValue
            self.hotCommentArr = jsonDict["hot"].arrayValue
            self.commentTableView.reloadData()
        }, fail: { (err) in
            print("请求收藏接口失败!",err.localizedDescription)
        }, Pro: { (pro) in
            print(pro)
        })
    }
    
    // 获取音频信息
    func loadAudioData() {
        if model.aid != audioID {
            audioID = self.model.aid
            self.showHud(in: self.audioView)
            if let url = URL.init(string: model.audioUrl) {
                let item = AVPlayerItem.init(url: url)
                player = AimiPlayer.share.player
                player.replaceCurrentItem(with: item)
                player.play()
                AVplaying = true
            } else {
                print("出现播放错误!")
                self.hideHud()
            }
        } else {
            self.audioView.playing = AVplaying
        }
    }
    
    // 获取收藏信息
    func fetchCollectionInfo() {
        let dic = ["uid": uid,
                   "id": model.aid,
                   "type":0]
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/control", dic: dic as NSDictionary, success: { (data) in
            
            let jsonDict = JSON.init(data: data)
            guard jsonDict["error"].intValue == 0 else { return }
            if jsonDict["zan"].intValue == 1 {
                self.bottomView.collectBtn.setImage(UIImage.init(named: "collection-icon-selected"), for: .selected)
                self.bottomView.collectBtn.isSelected = true
                self.isCollected = true
            } else {
                self.bottomView.collectBtn.setImage(UIImage.init(named: "collection-icon"), for: .normal)
                self.bottomView.collectBtn.isSelected = false
                self.isCollected = false
            }
        }, fail: { (err) in
            print("请求收藏接口失败!",err.localizedDescription)
        }) { (pro) in
        }
    }
    
    // 收藏与取消收藏
    func setArticleCollected(is trueOrFalse: Bool) {
        let parameters = ["uid": uid, "aid": model.aid]
        var url = "https://aimi.cupiday.com/\(AIMIversion)/"
        if trueOrFalse == true {
            url.append("afavorite")
        } else {
            url.append("delfavour")
        }
        DeeRequest.requestPost(url: url, dic: parameters as NSDictionary, success: { (data) in
            
            let jsonDict = JSON.init(data: data)
            DeeShareMenu.messageFrame(msg: jsonDict["message"].stringValue, view: self.view)
            guard jsonDict["error"].intValue == 0 else { return }
            self.isCollected = trueOrFalse
            
        }, fail: { (err) in
            print("请求收藏接口失败!",err.localizedDescription)
        }, Pro: {(pro) in
        })
    }
    
    // 点赞
    func setPraise(in indexPath: IndexPath, success: @escaping (_ data:Data) -> Void, fail: @escaping (_ error:Error) -> Void ) {
        AimiFunction.checkLogin(controller: self) { 
            var dic = Dictionary<String, JSON>()
            if indexPath.section == 0 {
                dic = self.hotCommentArr[indexPath.row].dictionaryValue
            } else if indexPath.section == 1 {
                dic = self.commentArr[indexPath.row].dictionaryValue
            }
            let cid = dic["cid"]?.intValue
            let ruid = dic["uid"]?.intValue
            let likeDic = ["uid": self.uid,
                           "id": cid,
                           "ruid": ruid,
                           "type": 0]
            DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/favour", dic: likeDic as NSDictionary, success: { (data) in
                success(data)
            }, fail: { (err) in
                fail(err)
            }, Pro: { (pro) in
            })
        }
    }

}

// MARK: - 滚动视图代理
extension MiquanDetailsController {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 隐藏弹出的多级评论页面
//        if scrollView.tag == 101 {
//            self.tapClick()
//        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        reportView.alpha = 0.0
        adjustView.alpha = 0.0
        customView.hideView {
            self.z = false
        }
        if commentTableView.contentOffset.y < 0.0 {
            navTitleBtn.alpha = 0.0
        } else if commentTableView.contentOffset.y < 64.0 {
            navTitleBtn.alpha = commentTableView.contentOffset.y / 64.0
        } else {
            navTitleBtn.alpha = 1.0
        }
    }
}

// MARK: - 正文WebView代理
extension MiquanDetailsController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.showHud(in: self.view)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideHud()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        let size = UserDefaults.standard.object(forKey: "contentSize") as! String
        contentWebView.evaluateJavaScript("document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(size)'", completionHandler: nil)
        contentWebView.evaluateJavaScript("document.body.scrollHeight") { (height, err) in
            self.contentHeight = height as! CGFloat
            self.contentWebView.frame.size = CGSize.init(width: UIwidth, height: self.contentHeight)
            self.commentTableView.tableHeaderView = self.contentWebView
            // 正文加载完成后，页面取消隐藏
            UIView.animate(withDuration: 0.5, animations: { 
                self.commentTableView.alpha = 1.0
            }, completion: { (finished) in
                self.contentWebView.scrollView.delegate = self
            })
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // 如果是跳转一个新页面
        if (navigationAction.targetFrame == nil) {
            // 直接跳转到系统自带的Safari浏览器
            UIApplication.shared.openURL(navigationAction.request.url!)
        }
        decisionHandler(.allow)
    }
    
}

// MARK: - 评论列表TableView代理
extension MiquanDetailsController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.hotCommentArr.count == 0{
            return 0
        }
        else{
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.hotCommentArr.count
        default:
            return self.commentArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CC", for: indexPath) as! CC
        var dict = Dictionary<String, JSON>()
        if indexPath.section == 0 {
            dict = hotCommentArr[indexPath.row].dictionaryValue
        } else if indexPath.section == 1 {
            dict = commentArr[indexPath.row].dictionaryValue
        }
        // 基本页面布局
        cell.nickName.text = dict["username"]?.stringValue
        cell.img.kf.setImage(with: URL.init(string: (dict["avatar"]?.stringValue)!))
        cell.commentContent.text = dict["content"]?.stringValue
        // 是否点过赞
        if dict["zan"]?.intValue == 0 {
            cell.like_Count.setTitleColor(UIColor.lightGray, for: .normal)
            cell.like_Count.setImage(UIImage.init(named: "like"), for: .normal)
        } else {
            cell.like_Count.setTitleColor(UIColor.red, for: .normal)
            cell.like_Count.setImage(UIImage.init(named: "liked"), for: .normal)
        }
        // 点赞人数
        if dict["hot"]?.intValue == 0 {
            cell.like_Count.setTitle("", for: .normal)
        } else {            
            cell.like_Count.setTitle(dict["hot"]?.stringValue, for: .normal)
        }
        cell.building.backgroundColor = UIColor.init(red: 248/255, green: 248/255, blue: 234/255, alpha: 1.0)
        cell.time.text = dict["create_time"]?.stringValue
        // 对评论的回复
        let replyArr = dict["reply"]?.arrayValue
        var replyStr = String()
        let style = NSMutableParagraphStyle.init()
        style.headIndent = 5
        style.firstLineHeadIndent = 5
        style.lineSpacing = 3
        let user = NSMutableAttributedString.init()
        if replyArr?.count != 0 {
            replyArr?.forEach{ jsonDic in
                let userName = jsonDic.dictionaryValue["username"]?.stringValue
                var context = jsonDic.dictionaryValue["content"]?.stringValue
                context = context?.replacingOccurrences(of: "\n", with: " ")
                replyStr += userName! + " : " + context! + "\n"
            }
            let arr = replyStr.components(separatedBy: "\n")
            for i in arr{
                let subArr = i.components(separatedBy: " : ")
                let nickName = NSMutableAttributedString.init(string: subArr.first!)
                if nickName.length > 0{
                    nickName.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: NSRange.init(location: 0, length: nickName.length))
                    user.append(nickName)
                    user.append(NSAttributedString.init(string: " : " + subArr.last! + "\n"))
                }
            }
            let show = NSMutableAttributedString.init(string: Locale.cast(str: "参与更多评论..."))
            show.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange.init(location: 0, length: show.length))
            user.append(show)
            user.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange.init(location: 0, length: user.length - 1))
        }
        cell.building.attributedText = user
        // 进行回复
        cell.quickCommentAction = {
            self.writeCommentArea.sendType = "type"
            self.writeCommentArea.aid = self.model.aid
            self.writeCommentArea.cid = (dict["cid"]?.intValue)!
            self.writeCommentArea.contentType = "0"
            self.writeCommentArea.rname = ""
            self.writeCommentArea.textView.becomeFirstResponder()
        }
        // 点赞
        cell.clickLikeCountActtion = {
            // 自己没有点过赞
            if dict["zan"]?.intValue == 0 {
                self.setPraise(in: indexPath, success: { (data) in
                    cell.like_Count.isUserInteractionEnabled = false
                    let jsonDict = JSON.init(data: data)
                    guard jsonDict["error"].intValue == 0 else { return }
                    self.loadCommentData()
                }, fail: { (err) in
                    cell.like_Count.isUserInteractionEnabled = true
                })
            }
        }
        // 举报
        cell.reportAction = {
            self.view.addSubview(self.reportView)
            self.reportView.id = (dict["cid"]?.intValue)!
            self.reportView.type = 4
            UIView.animate(withDuration: 0.3, animations: {
                self.reportView.alpha = 1
            })
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: UIwidth, height: 30))
        label.backgroundColor = UIColor.init(white: 210, alpha: 0.8)
        label.font = UIFont.systemFont(ofSize: 15)
        var str = String()
        switch section {
        case 0:
            str = Locale.cast(str: " 热门评论")
        default:
            str = Locale.cast(str: " 最新评论")
        }
        label.text = str
        label.textColor = UIColor.darkGray
        let sectionView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIwidth, height: 30))
        sectionView.backgroundColor = UIColor.lightGray
        sectionView.addSubview(label)
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = mainStoryBoard.instantiateViewController(withIdentifier: "CommentDetails") as! CommentDetails
        var dic = Dictionary<String, JSON>()
        if indexPath.section == 0 {
            dic = self.hotCommentArr[indexPath.row].dictionaryValue
        } else if indexPath.section == 1 {
            dic = self.commentArr[indexPath.row].dictionaryValue
        }
        vc.reply  = changeToDict(dict: dic)
        vc.contentType = "0"
        vc.aid = self.model.aid
        self.navigationController?.pushViewController(vc, animated:  true)
    }
    
    private func changeToDict(dict: Dictionary<String, JSON>) -> NSDictionary {
        let tempDic = NSMutableDictionary()
        _ = dict.flatMap { (key, value) in
            if key == "reply" { }
            tempDic.setValue(value.rawValue, forKey: key)
        }
        let tempArr = NSMutableArray()
        if let dicArr = dict["reply"]?.arrayValue {
            for dic in dicArr {
                let replayDic = NSMutableDictionary()
                _ = dic.flatMap({ (key,value) in
                    replayDic.setValue(value.rawValue, forKey: key)
                })
                tempArr.add(replayDic)
            }
        }
        tempDic.setValue(tempArr, forKey: "reply")
        return tempDic as NSDictionary
    }
}
