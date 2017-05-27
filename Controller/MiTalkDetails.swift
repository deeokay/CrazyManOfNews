//
//  MiTalkDetails.swift
//  Aimi-V1.1
//
//  Created by iMac for iOS on 2017/3/29.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UIKit

class MiTalkDetails: HideTabbarController,UITableViewDelegate,UITableViewDataSource {
    var alertView = UIAlertController()
    var shareMenu = DeeShareMenu()
    var customView = CustomMenu()
    var commentView = WriteComment()
    var commentArr = NSMutableArray()
    var hotCommentArr = NSMutableArray()
    var arr = NSArray()
    var model = MiTalkModel()
    var delegate:MiTalk?
    @IBOutlet weak var TB: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TB.register(UINib.init(nibName: "MiTalkCell", bundle: nil), forCellReuseIdentifier: "MiTalkCell")
        self.TB.register(UINib.init(nibName: "MiTalkMenuCell", bundle: nil), forCellReuseIdentifier: "MiTalkMenuCell")
        self.TB.register(UINib.init(nibName: "LeftCell", bundle: nil), forCellReuseIdentifier: "LeftCell")
        self.TB.register(UINib.init(nibName: "RightCell", bundle: nil), forCellReuseIdentifier: "RightCell")
        
        self.TB.tableFooterView = UIView()
        self.setReportView()
        let dView = DeeSetView()
        commentView = dView.creatCommentView(controller: self)
        dView.sendCallBack = {
            //评论成功回调
            self.getCommentList()
            DeeShareMenu.messageFrame(msg: NSLocalizedString("评论成功!", comment: ""), view: self.view)
        }
        
        shareMenu = DeeShareMenu()
        alertView = shareMenu.shareSysMenu()
        self.setCustomView()
        self.setReportView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getCommentList()
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
    
    func setCustomView() -> Void {
        customView = Bundle.main.loadNibNamed("CustomMenu", owner: self, options: nil)?.last as! CustomMenu
        self.customView.loading = {
            self.showHud(in: self.view, hint: "分享中...", yOffset: 0, interaction: false)
        }
        self.customView.handlingResult = {
            self.hideHud()
        }
        customView.frame = CGRect.init(x: 0, y: UIheight, width: UIwidth, height: UIheight * 0.4)
        self.shareImg = UIImage.init(named: "logo")!
        //缺省分享模型
        customView.successToShareCallback = {
            self.customView.mj_origin = CGPoint.init(x: 0, y: UIheight)
            AimiFunction.shareReward(controller: self)
        }
        self.view.addSubview(customView)
        let refreshModel = ActionModel()
        refreshModel.img = UIImage.init(named: "刷新内容")!
        refreshModel.title = NSLocalizedString("刷新", comment: "")
        refreshModel.action = {
            self.getCommentList()
            UIView.animate(withDuration: 0.2, animations: {
                self.customView.mj_origin = CGPoint.init(x: 0, y: UIheight)
            })
        }
        let adjustText = ActionModel()
        adjustText.title = NSLocalizedString("调整字体", comment: "")
        adjustText.img = UIImage.init(named: "字体设置")!
        adjustText.action = {
            
            //调整字体操作
            
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
        let shieldU = ActionModel()
        shieldU.title = NSLocalizedString("屏蔽用户", comment: "")
        shieldU.img = UIImage.init(named: "屏蔽用户")!
        shieldU.action = {
            AimiFunction.shield(id: self.model.uid, type: 4, success: {
                self.delegate?.shieldModel = self.model
                self.delegate?.shieldUser = true
                DeeShareMenu.messageFrame(msg: Locale.cast(str: "屏蔽用户成功!"), view: self.view)
            })
            self.customView.hideView(complete: {
            })
        }
        let shieldC = ActionModel()
        shieldC.title = NSLocalizedString("屏蔽内容", comment: "")
        shieldC.img = UIImage.init(named: "屏蔽内容")!
        shieldC.action = {
            AimiFunction.shield(id: self.model.fid, type: 3, success: {
                self.delegate?.shieldModel = self.model
                self.delegate?.shieldContent = true
                DeeShareMenu.messageFrame(msg: Locale.cast(str: "屏蔽内容成功!"), view: self.view)
            })
            self.customView.hideView(complete: {
            })
        }
        self.customView.actionArr.append(refreshModel)
//        self.customView.actionArr.append(adjustText)
        self.customView.actionArr.append(report)
        self.customView.actionArr.append(shieldU)
        self.customView.actionArr.append(shieldC)
        customView.cancelAction = {
            UIView.animate(withDuration: 0.3, animations: {
                self.customView.mj_origin = CGPoint.init(x: 0, y: UIheight)
                self.view.backgroundColor = UIColor.clear
                self.view.alpha = 1
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return commentArr.count
        default:
            return hotCommentArr.count
        }
    }
    
    @IBAction func replyClick(_ sender: UIBarButtonItem) {
        self.commentView.aid = self.model.fid
        self.commentView.sendType = "comment"
        self.commentView.contentType = "3"
        self.commentView.ruid = self.model.uid
        self.commentView.textView.becomeFirstResponder()
    }
    
    
    var normalCommentArr = NSArray()
    func getCommentList() -> Void {
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let dic = ["aid":self.model.fid,"type":3,"uid":uid]
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/comment", dic: dic as NSDictionary, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                DeeShareMenu.messageFrame(msg: NSLocalizedString("服务器错误", comment: ""), view: self.view)
                print("解析米聊JSON失败!")
                return
            }
            
            guard json.object(forKey: "error") as? Int == 0 else{
                print("越界请求!")
                return
            }
            
            
            if let jsonArr = json.object(forKey: "body") as? NSArray{
                self.commentArr.removeAllObjects()
                for i in jsonArr{
                    let tmp = i as! NSDictionary
                    let model = CommentModel()
                    model.setValuesForKeys(tmp as! [String : Any])
                    self.commentArr.add(model)
                }
            }
            
            if let jsonArr = json.object(forKey: "hot") as? NSArray{
                self.hotCommentArr.removeAllObjects()
                for i in jsonArr{
                    let tmp = i as! NSDictionary
                    let model = CommentModel()
                    model.setValuesForKeys(tmp as! [String : Any])
                    self.hotCommentArr.add(model)
                }
            }
            self.TB.reloadData()
            
        }, fail: { (error) in
            print(error)
        }, Pro: { (pro) in
            print(pro)
        })
    }
    
    
    var show_more = false
    var shareImg = UIImage()
    var shareTitle = String()
    var shareUrl = String()
    var shareDesc = String()
    var shareType = SSDKContentType.webPage
    func share() -> Void {
        
        shareMenu.shareDic = DeeShareMenu.shareContent(shareThumImage: &shareImg, shareTitle: shareDesc, shareDescr: shareTitle, url: shareUrl, shareType: shareType)
        shareMenu.stateHandler = DeeShareMenu.stateHandle(controller: self, success: {
            self.shareType = SSDKContentType.webPage
        }, fail: {
            self.shareType = SSDKContentType.text
        })
        self.present(alertView, animated: true, completion: nil)
    }
    
    func showCustomView() -> Void {
        UIView.animate(withDuration: 0.3) {
            self.customView.mj_origin = CGPoint.init(x: 0, y: UIheight * 0.6)
        }
    }
    
    func hideCustomView() -> Void {
        UIView.animate(withDuration: 0.3) {
            self.customView.mj_origin = CGPoint.init(x: 0, y: UIheight)
            self.reportView.alpha = 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                return UITableViewAutomaticDimension
            default:
                return 40
            }
        }
        else{
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MiTalkCell") as! MiTalkCell
                cell.model = self.model
                return cell
            }
                
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MiTalkMenuCell") as! MiTalkMenuCell
                cell.moreAction = {
                     self.show_more = !self.show_more
                    if self.show_more{
                        self.showCustomView()
                    }
                    else{
                        self.hideCustomView()
                    }
                }
                cell.shareAction = {
                    print("点击了分享")
                    self.show_more = !self.show_more
                    if self.show_more{
                        self.showCustomView()
                    }
                    else{
                        self.hideCustomView()
                    }
                }
//                 判断用户有没有点赞、收藏
                let dic = ["uid":UserDefaults.standard.integer(forKey: "uid"),"id":model.fid,"type":3] as NSDictionary
                DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/control", dic: dic, success: { (data) in
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                        print("读取收藏Json失败!")
                        return
                    }
                    if json.object(forKey: "error") as! Int == 0 {
                        if json.object(forKey: "zan") as! Int == 1{
                            cell.collectBtn.setImage(UIImage.init(named: "收藏-1"), for: .selected)
                            cell.collectBtn.isSelected = true
                            cell.didCollect = true
                        } else {
                            cell.collectBtn.setImage(UIImage.init(named: "收藏"), for: .normal)
                            cell.collectBtn.isSelected = false
                            cell.didCollect = false
                        }
                    }
                }, fail: { (err) in
                    print("请求收藏接口失败!",err.localizedDescription)
                }) { (pro) in
                }
                cell.collectAction = {
                    
                    if UserDefaults.standard.bool(forKey: "isLogin") {
                        let uid = UserDefaults.standard.integer(forKey: "uid")
                        var parameters = NSDictionary()
                        var url = ""
                        if cell.collectBtn.isSelected == false {
                            parameters = ["uid": uid,"fid": self.model.fid]
                            url = "https://aimi.cupiday.com/\(AIMIversion)/ffavorite"
                        }
                        else{
                            parameters = ["uid": uid,"fid": self.model.fid]
                            url = "https://aimi.cupiday.com/\(AIMIversion)/delfavour"
                        }
                        
                        
                        DeeRequest.requestPost(url: url, dic: parameters, success: { (data) in
                            guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                                print("解析数据失败!")
                                return
                            }
                            if (json.object(forKey: "error") as! NSNumber).isEqual(to: 0){
                                if (json.object(forKey: "message") as! String) == "收藏成功"{
                                    cell.collectBtn.isSelected = true
                                    DeeShareMenu.messageFrame(msg: NSLocalizedString("收藏成功!", comment: ""), view: self.view)
                                }
                                else if (json.object(forKey: "message") as! String) == "删除成功"{
                                    cell.collectBtn.isSelected = false
                                    DeeShareMenu.messageFrame(msg: NSLocalizedString("删除收藏成功!", comment: ""), view: self.view)
                                }
                            }
                            else{
                                print("解析失败!")
                            }
                        }, fail: { (err) in
                            
                        }, Pro: {(pro) in
                            
                        })
                    }
                }
                return cell
            }
        }
        else{
            let reportAction = {
                UIView.animate(withDuration: 0.5, animations: {
                    self.reportView.alpha = 1
                })
            }
            var model = CommentModel()
            if indexPath.section == 1{
                model  = commentArr.object(at: indexPath.row) as! CommentModel
            }
            else{
                model = hotCommentArr.object(at: indexPath.row) as! CommentModel
            }
            if indexPath.row % 2 == 0{
                //leftcell
                let cell = tableView.dequeueReusableCell(withIdentifier: "LeftCell") as! LeftCell
                cell.avatar.kf.setImage(with: URL.init(string: model.avatar))
                cell.creatTime.text = model.create_time
                cell.username.text = model.username
                cell.likeBtn.titleLabel?.text = String(model.hot)
                cell.content.text = model.content
                cell.building.text = ""
                cell.reportAction = reportAction
                if model.sex == 1{
                    cell.sex.image = UIImage.init(named: "male")
                }
                else{
                    cell.sex.image = UIImage.init(named: "lady")
                }
                cell.replyAction = {
                    self.commentView.textView.becomeFirstResponder()
                }
                let likecount = model.hot
                let zan = model.zan
                if zan == 0{
                    cell.likeBtn.setTitleColor(UIColor.lightGray, for: .normal)
                }
                else{
                    cell.likeBtn.setTitleColor(UIColor.red, for: .normal)
                }
                if likecount == 0{
                    cell.likeBtn.setTitle("", for: .normal)
                }
                else{
                    cell.likeBtn.setTitle("" + String(describing: likecount), for: .normal)
                }
                var str = ""
                var replyArr = NSArray()
                let style = NSMutableParagraphStyle.init()
                style.headIndent = 5
                style.firstLineHeadIndent = 5
                style.lineSpacing = 3
                let user = NSMutableAttributedString.init()
                replyArr = model.reply as NSArray
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
                cell.replyAction = {
                    self.commentView.sendType = "type"
                    self.commentView.aid = self.model.fid
                    self.commentView.cid = model.cid
                    self.commentView.contentType = "3"
                    self.commentView.rname = ""
                    self.commentView.textView.becomeFirstResponder()
                }
                
                if model.zan == 1{
                    cell.likeBtn.setTitleColor(UIColor.red, for: .normal)
                    cell.likeBtn.setImage(UIImage.init(named: "liked"), for: .normal)
                    
                }
                else{
                    cell.likeBtn.setTitleColor(UIColor.lightGray, for: .normal)
                    cell.likeBtn.setImage(UIImage.init(named: "like"), for: .normal)
                    
                }
                cell.likeAction = {
                    if model.zan != 1{
                        AimiFunction.checkLogin(controller: self) {
                            cell.likeBtn.isUserInteractionEnabled = false
                            let uid = UserDefaults.standard.integer(forKey: "uid")
                            let cid = model.cid
                            let ruid = model.uid
                            let likeDic = ["uid":uid,"id":cid,"ruid":ruid,"type":0] as NSDictionary
                            DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/favour", dic: likeDic, success: { (data) in
                                guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                                    DeeShareMenu.messageFrame(msg: NSLocalizedString("点赞失败!", comment: ""), view: self.view)
                                    return
                                }
                                let err = json.object(forKey: "error") as! NSNumber
                                if err.isEqual(to: 0){
                                    self.getCommentList()
                                    DeeShareMenu.messageFrame(msg: NSLocalizedString("点赞成功!", comment: ""), view: self.view)
                                    cell.likeBtn.isUserInteractionEnabled = true
                                }
                                
                            }, fail: { (err) in
                                cell.likeBtn.isUserInteractionEnabled = true
                            }, Pro: { (pro) in
                            })
                        }
                    }
                    else{
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("你已经赞过啦!", comment: ""), view: self.view)
                    }
                }
                
                return cell
            }
                
            else{
                //rightcell
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightCell") as! RightCell
                cell.avatar.kf.setImage(with: URL.init(string: model.avatar))
                cell.creatTime.text = model.create_time
                cell.username.text = model.username
                cell.likeBtn.titleLabel?.text = String(model.hot)
                cell.content.text = model.content
                cell.building.text = ""
                cell.reportAction = reportAction
                if model.sex == 1{
                    cell.sex.image = UIImage.init(named: "male")
                }
                else{
                    cell.sex.image = UIImage.init(named: "lady")
                }
                cell.replyAction = {
                    self.commentView.textView.becomeFirstResponder()
                }
                let likecount = model.hot
                let zan = model.zan
                if zan == 0{
                    cell.likeBtn.setTitleColor(UIColor.lightGray, for: .normal)
                }
                else{
                    cell.likeBtn.setTitleColor(UIColor.red, for: .normal)
                }
                if likecount == 0{
                    cell.likeBtn.setTitle("", for: .normal)
                }
                else{
                    cell.likeBtn.setTitle("" + String(describing: likecount), for: .normal)
                }
                var str = ""
                var replyArr = NSArray()
                let style = NSMutableParagraphStyle.init()
                style.headIndent = 5
                style.firstLineHeadIndent = 5
                style.lineSpacing = 3
                let user = NSMutableAttributedString.init()
                replyArr = model.reply as NSArray
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
                cell.replyAction = {
                    self.commentView.sendType = "type"
                    self.commentView.aid = self.model.fid
                    self.commentView.cid = model.cid
                    self.commentView.contentType = "3"
                    self.commentView.rname = ""
                    self.commentView.textView.becomeFirstResponder()
                }
                
                if model.zan == 1{
                    cell.likeBtn.setTitleColor(UIColor.red, for: .normal)
                    cell.likeBtn.setImage(UIImage.init(named: "liked"), for: .normal)
                    
                }
                else{
                    cell.likeBtn.setTitleColor(UIColor.lightGray, for: .normal)
                    cell.likeBtn.setImage(UIImage.init(named: "like"), for: .normal)
                    
                }
                cell.likeAction = {
                    if model.zan != 1{
                        AimiFunction.checkLogin(controller: self) {
                            cell.likeBtn.isUserInteractionEnabled = false
                            let uid = UserDefaults.standard.integer(forKey: "uid")
                            let cid = model.cid
                            let ruid = model.uid
                            let likeDic = ["uid":uid,"id":cid,"ruid":ruid,"type":0] as NSDictionary
                            DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/favour", dic: likeDic, success: { (data) in
                                guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                                    DeeShareMenu.messageFrame(msg: NSLocalizedString("点赞失败!", comment: ""), view: self.view)
                                    return
                                }
                                let err = json.object(forKey: "error") as! NSNumber
                                if err.isEqual(to: 0){
                                    self.getCommentList()
                                    DeeShareMenu.messageFrame(msg: NSLocalizedString("点赞成功!", comment: ""), view: self.view)
                                    cell.likeBtn.isUserInteractionEnabled = true
                                }
                                
                            }, fail: { (err) in
                                cell.likeBtn.isUserInteractionEnabled = true
                            }, Pro: { (pro) in
                            })
                        }
                    }
                    else{
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("你已经赞过啦!", comment: ""), view: self.view)
                    }
                }
                return cell
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section != 0 else{
            return
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "CommentDetails") as! CommentDetails
        var model = CommentModel()
        if indexPath.section == 0{
            model = self.hotCommentArr[indexPath.row] as! CommentModel
        }else if indexPath.section == 1{
            model = self.commentArr[indexPath.row] as! CommentModel
        }
        vc.reply = model.mj_keyValues()
        vc.contentType = "3"
        vc.aid = self.model.fid
        print(model.reply)
        self.navigationController?.pushViewController(vc, animated:  true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: UIwidth, height: 30))
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        var str = ""
        switch section {
        case 1:
            str = NSLocalizedString("最新评论", comment: "")
        case 2:
            str = NSLocalizedString("热门评论", comment: "")
        default:
            break
        }
        label.text = str
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIwidth, height: 30))
        view.backgroundColor = UIColor.lightGray
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            if commentArr.count != 0{
                return 30
            }
            else{
                return 0
            }        case 2:
                if hotCommentArr.count != 0{
                    return 30
                }
                else{
                    return 0
            }
        default:
            return 0
        }
    }
    
    
    
}
