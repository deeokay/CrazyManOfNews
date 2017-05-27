//
//  CommentDetails.swift
//  AimiHealth
//
//  Created by apple on 2017/1/6.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
import MMPopupView
import MJRefresh
import AFNetworking
import Kingfisher
class CommentDetails: HideTabbarController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate {
    var model = ArticleModel()
    var commentView = WriteComment()
    var alertView = UIAlertController()
    var shareMenu = DeeShareMenu()
    var aid = NSInteger()
    var reply = NSDictionary()
    var replyList = NSArray()
    var contentType = NSString()
    var uid = UserDefaults.standard.integer(forKey: "uid")
    @IBOutlet weak var writeCommentBtn: UIButton!
    @IBOutlet weak var TB: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setReportView()
        self.writeCommentBtn.layer.borderColor = UIColor.lightGray.cgColor
        self.navigationItem.title = NSLocalizedString("评论详情", comment: "")
        UIApplication.shared.applicationSupportsShakeToEdit = true
        self.TB.register(UINib.init(nibName: "CC", bundle: nil), forCellReuseIdentifier: "CC")
        shareMenu = DeeShareMenu()
        alertView = shareMenu.shareSysMenu()
        writeCommentBtn.layer.borderWidth = 1
        let dView = DeeSetView()
        commentView = dView.creatCommentView(controller: self)
        self.commentView.textView.delegate = self
        dView.sendCallBack = {
            self.getReplyList()
            DeeShareMenu.messageFrame(msg:NSLocalizedString("评论成功!", comment: ""), view: self.view)
        }
        // Do any additional setup after loading the view.
        let header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: nil)
        header?.setTitle(NSLocalizedString("用力拉用力拉!!!", comment: ""), for: .idle)
        header?.setTitle(NSLocalizedString("没有任何数据可以刷新!!!", comment: ""), for: .noMoreData)
        header?.setTitle(NSLocalizedString("服务器都快炸了!!!", comment: ""), for: .refreshing)
        header?.setTitle(NSLocalizedString("一松手就洗个脸!!!", comment: ""), for: .pulling)
        header?.isAutomaticallyChangeAlpha = true
        header?.refreshingBlock = {
            if AFNetworkReachabilityManager.shared().networkReachabilityStatus.rawValue != 0{
                self.getReplyList()
                self.TB.mj_header.endRefreshing()
            }
            else{
                DeeShareMenu.messageFrame(msg: NSLocalizedString("请检查网络!", comment: ""), view: self.view)
                self.TB.mj_header.endRefreshing()
            }
        }
        TB.mj_header = header

    }

    @IBAction func refreshComment(_ sender: Any) {
        self.getReplyList()
    }
    func getReplyList() -> Void {
        let cid = reply.object(forKey: "cid") as! NSNumber
        let dic = ["cid":cid.intValue,"uid":self.uid]
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/onecomment", dic: dic as NSDictionary, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                print("解析失败!")
                DeeShareMenu.messageFrame(msg: NSLocalizedString("读取评论失败!", comment: ""), view: self.view)
                return
            }
            let body = json.object(forKey: "body") as! NSArray
            self.reply = body[0] as! NSDictionary
            self.replyList = self.reply.object(forKey: "reply") as! NSArray
            self.TB.reloadData()
            if self.replyList.count != 0{
            }

        }, fail: { (err) in
            print(err.localizedDescription)
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


    override func viewDidDisappear(_ animated: Bool) {
        DeeSetView().releaseKeyboardObserver()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.getReplyList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func refreshClick(_ sender: Any) {
        self.getReplyList()
    }

    @IBAction func backClick(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return self.replyList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CC", for: indexPath) as! CC
        var likeDic = NSMutableDictionary()
        var zan:NSNumber = 0
        var hot:NSNumber = 0
        if indexPath.section == 0{
            cell.img.kf.setImage(with: URL.init(string: self.reply.object(forKey: "avatar") as! String))
            cell.nickName.text = self.reply.object(forKey: "username") as! String?
            cell.commentContent.text = self.reply.object(forKey: "content") as! String?
            cell.commentContent.font = UIFont.systemFont(ofSize: 14)
            cell.time.text = reply.object(forKey: "create_time") as! String?
            cell.building.text = "\n"
            let likeCout = self.reply.object(forKey: "hot") as! NSNumber
            cell.like_Count.setTitle(likeCout.stringValue, for: .normal)
            cell.quickCommentAction = {self.writeComment()}
            let cid = self.reply.object(forKey: "cid") as! NSNumber
            let ruid = self.reply.object(forKey: "uid") as! NSNumber
            likeDic = ["uid":self.uid,"id":cid,"ruid":ruid,"type":self.contentType]
            zan = self.reply.object(forKey: "zan") as! NSNumber
            hot = self.reply.object(forKey: "hot") as! NSNumber
            cell.reportAction = {
                self.reportView.id = cid.intValue
                self.reportView.type = 4
                UIView.animate(withDuration: 0.3, animations: { 
                    self.reportView.alpha = 1
                })
            }
        }
        else{
            let replyDic = replyList[indexPath.row] as! NSDictionary
            cell.modelDic = replyDic
            cell.quickCommentAction = {
                    //回复楼主
                    self.commentView.aid = self.aid
                    self.commentView.cid = self.reply.object(forKey: "cid") as! NSInteger
                    self.commentView.contentType = self.contentType
                    self.commentView.rrid = replyDic.object(forKey: "rid") as! NSInteger
                    self.commentView.rname = replyDic.object(forKey: "username") as! String
                    self.commentView.sendType = "type"
                    if indexPath.section == 0{
                        self.commentView.ruid = 0
                    }
                    else{
                        print(replyDic,"回复的字典")
                        self.commentView.ruid = replyDic.object(forKey: "uid") as! NSInteger
                    }
                    //回复自己变评论楼主
                    if replyDic.object(forKey: "uid") as! NSInteger == self.uid{
                        print("回复自己了",self.commentView.cid)
                        self.commentView.ruid = 0
                        self.commentView.cid = self.reply.object(forKey: "cid") as! NSInteger
                    }
                    self.commentView.textView.becomeFirstResponder()

            }
            cell.img .kf.setImage(with: URL.init(string: replyDic.object(forKey: "avatar") as! String))
            cell.nickName.text = replyDic.object(forKey: "username") as! String?
            let rname = replyDic.object(forKey: "rname") as! NSString
            let content = replyDic.object(forKey: "content") as! NSString
            if rname.length > 0 && rname as String != replyDic.object(forKey: "username") as! String?{
                cell.commentContent.text = NSLocalizedString("回复", comment: "") + (rname as String) + " : " + (content as String)
            }else{
                cell.commentContent.text = replyDic.object(forKey: "content") as! String?
            }
            cell.commentContent.font = UIFont.systemFont(ofSize: 13)
            cell.time.text = replyDic.object(forKey: "create_time") as! String?
            cell.building.text = ""
            cell.contentView.backgroundColor = UIColor.lightText
            let ruid =  replyDic.object(forKey: "uid") as! NSNumber
            let rid = replyDic.object(forKey: "rid") as! NSNumber
            likeDic = ["uid":self.uid,"id":rid,"ruid":ruid,"type":1]
            hot = replyDic.object(forKey: "hot") as! NSNumber
            zan = replyDic.object(forKey: "zan") as! NSNumber
        }
        if hot.isEqual(to: 0){
            cell.like_Count.setTitle("", for: .normal)
        }
        else{
            cell.like_Count.setTitle(" \(hot.intValue)", for: .normal)
        }
        if zan.isEqual(to: 0){
            cell.like_Count.setTitleColor(UIColor.lightGray, for: .normal)
            cell.like_Count.setImage(UIImage.init(named: "like"), for: .normal)
        }
        else{
            cell.like_Count.setTitleColor(UIColor.red, for: .normal)
            cell.like_Count.setImage(UIImage.init(named: "liked"), for: .normal)
        }
        
        cell.reportAction = {
            self.reportView.id = self.reply.object(forKey: "cid") as! Int
            self.reportView.type = 4
            UIView.animate(withDuration: 0.3, animations: {
                self.reportView.alpha = 1
            })
        }


        cell.clickLikeCountActtion = {
            AimiFunction.checkLogin(controller: self, success: { 
                if zan.isEqual(to: 1){
                    DeeShareMenu.messageFrame(msg: NSLocalizedString("你已经赞过啦!", comment: ""), view: self.view)
                }
                else{
                    cell.like_Count.isUserInteractionEnabled = false
                    DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/favour", dic: likeDic, success: { (data) in
                        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                            DeeShareMenu.messageFrame(msg: NSLocalizedString("点赞失败!", comment: ""), view: self.view)
                            return
                        }
                        let err = json.object(forKey: "error") as! NSNumber
                        if err.isEqual(to: 0){
                            cell.like_Count.isUserInteractionEnabled = true
                            self.getReplyList()
                        }
                    }, fail: { (err) in
                        cell.like_Count.isUserInteractionEnabled = true
                    }, Pro: { (pro) in
                    })
                }
            })
        }
        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.commentView.aid = self.aid
        self.commentView.cid = self.reply.object(forKey: "cid") as! NSInteger
        self.commentView.contentType = self.contentType
        self.commentView.sendType = "type"
        if indexPath.row == 0{
            self.commentView.ruid = 0
        }
        else{
            let replyDic = replyList[indexPath.row] as! NSDictionary
            self.commentView.rrid = replyDic.object(forKey: "rid") as! NSInteger
            self.commentView.rname = replyDic.object(forKey: "username") as! String
            self.commentView.ruid = replyDic.object(forKey: "uid") as! NSInteger
            print("这里的RUID=", replyDic.object(forKey: "uid") as! NSInteger)
            if replyDic.object(forKey: "uid") as! NSInteger == self.uid{
                print("回复自己了",self.commentView.cid)
                self.commentView.ruid = 0
                self.commentView.cid = self.reply.object(forKey: "cid") as! NSInteger
            }
        }
        //回复自己变评论楼主
        self.commentView.textView.becomeFirstResponder()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return UIView()
        default:
            let v = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 150, height: 20))
            let t = UILabel.init(frame: CGRect.init(x: 10, y: 5, width: 150, height: 20))
            t.textColor = UIColor.black
            t.font = UIFont.boldSystemFont(ofSize: 14)
            t.text = NSLocalizedString("回复列表", comment: "")
            v.addSubview(t)
            v.backgroundColor = UIColor.lightGray
            return v
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return 30

        }
    }



    @IBAction func showCommentView(_ sender: Any) {
        self.commentView.rname = ""
        self.commentView.ruid = 0
        self.commentView.rrid = 0
            writeComment()
    }

    func writeComment() -> Void {
            self.commentView.sendType = "type"
            self.commentView.aid = self.aid
            self.commentView.cid = self.reply.object(forKey: "cid") as! NSInteger
            self.commentView.contentType = self.contentType
            self.commentView.textView.becomeFirstResponder()
    }


    
    
    
}
