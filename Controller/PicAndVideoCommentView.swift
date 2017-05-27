//
//  PicAndVideoCommentView.swift
//  AimiHealth
//
//  Created by apple on 17/2/10.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
import MJRefresh
import AFNetworking
import Kingfisher
class PicAndVideoCommentView: HideTabbarController,UITableViewDelegate,UITableViewDataSource {
    var aid = NSInteger()
    var sendType = NSString()
    var contentType = NSString()
    var commentArr = NSArray()
    var hotCommentArr  = NSArray()
    var commentView = WriteComment()
    var uid = UserDefaults.standard.integer(forKey: "uid")
    var model = ArticleModel()
    @IBOutlet weak var Tb: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setReportView()
        self.writeCommentBtn.layer.borderColor = UIColor.gray.cgColor
        self.navigationController?.navigationItem.title = NSLocalizedString("评论详情", comment: "")
        self.view.backgroundColor = UIColor.red
        UIApplication.shared.applicationSupportsShakeToEdit = true
        let nib = UINib.init(nibName: "CC", bundle: nil)
        self.Tb.register(nib, forCellReuseIdentifier: "CC")
        let dView = DeeSetView()
        commentView = dView.creatCommentView(controller: self)
        dView.sendCallBack = {
            self.data()
            DeeShareMenu.messageFrame(msg: NSLocalizedString("评论成功!", comment: ""), view: self.view)
        }
        self.data()
        let header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: nil)
        header?.setTitle(NSLocalizedString("用力拉用力拉!!!", comment: ""), for: .idle)
        header?.setTitle(NSLocalizedString("没有任何数据可以刷新!!!", comment: ""), for: .noMoreData)
        header?.setTitle(NSLocalizedString("服务器都快炸了!!!", comment: ""), for: .refreshing)
        header?.setTitle(NSLocalizedString("一松手就洗个脸!!!", comment: ""), for: .pulling)
        header?.isAutomaticallyChangeAlpha = true
        header?.refreshingBlock = {
            if AFNetworkReachabilityManager.shared().networkReachabilityStatus.rawValue != 0{
                self.data()
                self.Tb.mj_header.endRefreshing()
            }
            else{
                DeeShareMenu.messageFrame(msg: NSLocalizedString("请检查网络!", comment: ""), view: self.view)
                self.Tb.mj_header.endRefreshing()
            }
        }

        Tb.mj_header = header

    }

    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }


    @IBOutlet weak var writeCommentBtn: UIButton!
    func data() {
        if sendType.isEqual(to: "1"){
            let dic:NSDictionary = ["aid":aid,"type":sendType,"uid":uid]
            DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/comment", dic: dic, success: { (data) in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                    DeeShareMenu.messageFrame(msg: NSLocalizedString("服务器错误", comment: ""), view: self.view)
                    print("解析数据失败!")
                    return
                }
                if json.object(forKey: "error") as! Int == 0{
                    if let arr = json.value(forKey: "body") as! NSArray?{
                        self.commentArr = arr
                    }
                    if let arr = json.value(forKey: "hot") as! NSArray?{
                        self.hotCommentArr = arr
                    }
                    self.Tb.reloadData()
                }
            }, fail: { (error) in
                print(error)
            }, Pro: { (pro) in
            })
        }else{
            let dic:NSDictionary = ["aid":aid,"type":self.contentType,"uid":uid]
            DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/comment", dic: dic, success: { (data) in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                    DeeShareMenu.messageFrame(msg: NSLocalizedString("服务器错误", comment: ""), view: self.view)
                    print("解析数据失败!")
                    return
                }
                if let arr = json.value(forKey: "body") as! NSArray?{
                    self.commentArr = arr
                }
                if let arr = json.value(forKey: "hot") as! NSArray?{
                    self.hotCommentArr = arr
                }
                self.Tb.reloadData()
            }, fail: { (error) in
                print(error)
            }, Pro: { (pro) in
            })

        }
    }

    @IBAction func refresh(_ sender: Any) {
        self.data()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.hotCommentArr.count
        default:
            return self.commentArr.count
        }
    }
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
        label.text = str

        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIwidth, height: 40))
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
            self.reportView.type =  4
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
            cell.like_Count.setImage(UIImage.init(named: "like"), for: .normal)

        }
        else{
            cell.like_Count.setTitleColor(UIColor.red, for: .normal)
            cell.like_Count.setImage(UIImage.init(named: "liked"), for: .normal)

        }
        if likecount.isEqual(to: 0){
            cell.like_Count.setTitle("", for: .normal)
        }
        else{
            cell.like_Count.setTitle("" + String(describing: likecount), for: .normal)
        }
        var str = ""
        var replyArr = NSArray()
        let user = NSMutableAttributedString.init()
        let style = NSMutableParagraphStyle.init()
        style.headIndent = 5
        style.firstLineHeadIndent = 5
        style.lineSpacing = 3
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
                self.commentView.contentType = self.contentType
                self.commentView.sendType = "type"
                self.commentView.aid = self.aid
                self.commentView.cid = dic.object(forKey: "cid") as! NSInteger
                self.commentView.rname = dic.object(forKey: "username") as! String
                self.commentView.textView.becomeFirstResponder()
                print("评论发送的aid",self.commentView.aid)
        }
        if (dic.object(forKey: "zan") as! NSNumber).isEqual(to: 1){
            cell.like_Count.setTitleColor(UIColor.red, for: .normal)
        }
        else{
            cell.like_Count.setTitleColor(UIColor.lightGray, for: .normal)
        }
        cell.clickLikeCountActtion = {
                cell.like_Count.isUserInteractionEnabled = false
                self.uid = UserDefaults.standard.integer(forKey: "uid")
                let cid = dic.object(forKey: "cid") as! NSNumber
                let ruid = dic.object(forKey: "uid") as! NSNumber
                let likeDic = ["uid":self.uid,"id":cid,"ruid":ruid,"type":0] as NSDictionary
                if (dic.object(forKey: "zan") as! NSNumber).isEqual(to: 1){
                }
                else{
                    DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/favour", dic: likeDic, success: { (data) in
                        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                            DeeShareMenu.messageFrame(msg: "点赞失败!", view: self.view)
                            return
                        }
                        let err = json.object(forKey: "error") as! NSNumber
                        if err.isEqual(to: 0){
                            cell.like_Count.isUserInteractionEnabled = true
                            self.data()
                        }
                    }, fail: { (err) in
                        cell.like_Count.isUserInteractionEnabled = true
                    }, Pro: { (pro) in
                    })
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
        vc.reply = dic
        vc.contentType = self.contentType
        vc.aid = self.aid
        self.navigationController?.pushViewController(vc, animated:  true)
    }

    @IBAction func writeComment(_ sender: Any) {
        self.commentView.sendType = "comment"
        self.commentView.contentType = self.contentType
        self.commentView.aid = self.aid
        self.commentView.ruid = self.model.uid
        self.commentView.textView.becomeFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


}
