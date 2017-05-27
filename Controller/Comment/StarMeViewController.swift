//
//  StarMeViewController.swift
//  AimiHealth
//
//  Created by IvanLee on 2017/3/8.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//  给我点赞

import UIKit
import SwiftyJSON
import MJRefresh
import Kingfisher
class StarMeViewController: HideTabbarController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var starMeTableView: UITableView!
    
    var dataArray = Array<JSON>()

    var messageLabel: UILabel {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 180, width: UIwidth, height: 80))
        label.textAlignment = .center
//        label.center = self.starMeTableView.center
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 25)
        label.text = "暂无评论信息！"
        return label
    }
    var totalPage: Int = 1
    var page: Int = 1
    var footer: MJRefreshAutoFooter {
        weak var weakSelf = self
        let ft = MJRefreshAutoFooter {
            if (weakSelf?.page)! < (weakSelf?.totalPage)! {
                weakSelf?.page += 1
                weakSelf?.loadData(page: (weakSelf?.page)!)
            } else {
                DeeShareMenu.messageFrame(msg: "已经到底啦！", view: self.view)
            }
        }
        return ft!
    }
    var header: MJRefreshNormalHeader {
        weak var weakSelf = self
        let hd = MJRefreshNormalHeader {
            weakSelf?.loadData(page: 1)
        }
        return hd!
    }
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 加载数据
        self.loadData(page: 1)
        self.starMeTableView.register(UINib.init(nibName: "StarMeTableViewCell", bundle: nil), forCellReuseIdentifier: "starMeCell")
        self.starMeTableView.tableFooterView = UIView()
        self.starMeTableView.mj_header = self.header
        self.starMeTableView.mj_footer = self.footer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.messageLabel.center = self.view.center
        self.view.layoutSubviews()
    }
    
    // MARK: - Delegate & DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "starMeCell", for: indexPath) as! StarMeTableViewCell
        cell.nameLabel.text = self.dataArray[indexPath.row]["username"].stringValue
        cell.timeLabel.text = self.dataArray[indexPath.row]["create_time"].stringValue
        // 设置用户头像
        let urlString = self.dataArray[indexPath.row]["avatar"].stringValue
        cell.photoImageView?.kf.setImage(with: URL.init(string: urlString), placeholder: UIImage.init(named: "大头像"))
        // 前面的名字显示为蓝色
        let attributeString = NSMutableAttributedString.init(string: "@我" + " " + self.dataArray[indexPath.row]["content"].stringValue)
        attributeString.addAttributes([NSForegroundColorAttributeName: UIColor.blue], range: NSMakeRange(0, 2))
        cell.commentLabel.attributedText = attributeString

        // 根据不同类型显示不同的被评论内容
        switch self.dataArray[indexPath.row]["link"]["type"].intValue {
        case 0:
            let urlString = self.dataArray[indexPath.row]["link"]["imgUrl"].stringValue
            cell.articleImageView.kf.setImage(with: URL.init(string: urlString), placeholder: UIImage.init(named: "articleLink"))            
            if self.dataArray[indexPath.row]["link"]["audioUrl"].stringValue.lengthOfBytes(using: .utf8) > 0 {
                cell.playImageView.isHidden = false
                cell.playImageView.image = UIImage.init(named: "评论语音")
                cell.titleLabel.text = " \(self.dataArray[indexPath.row]["link"]["title"])\n \(NSLocalizedString("音频作者：", comment: ""))\(self.dataArray[indexPath.row]["link"]["writer"])"
            } else {
                cell.playImageView.isHidden = true
                cell.titleLabel.text = " \(self.dataArray[indexPath.row]["link"]["title"].stringValue)"
            }
            cell.type = 0
        case 1:
            let urlString = self.dataArray[indexPath.row]["link"]["url"].arrayValue.first?.stringValue
            cell.articleImageView.kf.setImage(with: URL.init(string: urlString!), placeholder: UIImage.init(named: "articleLink"))
            cell.titleLabel.text = " \(NSLocalizedString("图集作者：", comment: ""))\(self.dataArray[indexPath.row]["link"]["username"])\n \(NSLocalizedString("发布时间：", comment: ""))\(self.dataArray[indexPath.row]["link"]["publishtime"])"
            cell.playImageView.isHidden = true
            cell.type = 1
        case 2:
            let urlString = self.dataArray[indexPath.row]["link"]["imgUrl"].stringValue
            cell.articleImageView.kf.setImage(with: URL.init(string: urlString), placeholder: UIImage.init(named: "articleLink"))
            cell.titleLabel.text = " \(NSLocalizedString("视频作者：", comment: ""))\(self.dataArray[indexPath.row]["link"]["username"])\n \(NSLocalizedString("发布时间：", comment: ""))\(self.dataArray[indexPath.row]["link"]["publishtime"])"
            cell.playImageView.isHidden = false
            cell.playImageView.image = UIImage.init(named: "播放")
            cell.type = 2
        default:
            /*
             * 去除米聊
            cell.titleLabel.text = " \(NSLocalizedString("米聊作者：", comment: ""))\(self.dataArray[indexPath.row]["link"]["username"])\n \(NSLocalizedString("发布时间：", comment: ""))\(self.dataArray[indexPath.row]["link"]["publishtime"])"
            cell.playImageView.isHidden = true
            cell.articleImageView.image = UIImage.init(named: "评论-米聊")
            cell.type = 3
            */
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let contentText = "@我" + " " + self.dataArray[indexPath.row]["content"].stringValue
        return StarMeTableViewCell.cellhight(content: contentText)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! StarMeTableViewCell
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        switch cell.type {
        case 0:
            let supportStoryBoard = UIStoryboard.init(name: "Support", bundle: nil)
            let vc = supportStoryBoard.instantiateViewController(withIdentifier: "MiquanDetailsController") as! MiquanDetailsController
            let model = ArticleModel()
            model.aid = self.dataArray[indexPath.row]["link"]["aid"].intValue
            model.title = self.dataArray[indexPath.row]["link"]["title"].stringValue
            model.link = self.dataArray[indexPath.row]["link"]["link"].stringValue
            model.audioUrl = self.dataArray[indexPath.row]["link"]["audioUrl"].stringValue
            if (model.audioUrl as NSString).length > 0 {
                model.article_type = 1
            } else {
                model.article_type = 0
            }
            model.imgUrl = self.dataArray[indexPath.row]["link"]["imgUrl"].stringValue
            model.bgUrl = self.dataArray[indexPath.row]["link"]["bgUrl"].stringValue
            model.bgAvatar = self.dataArray[indexPath.row]["link"]["bgAvatar"].stringValue
            vc.model = model
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "PicDetail") as! PicDetail
            let model = PictureModel()
            model.iid = self.dataArray[indexPath.row]["link"]["iid"].intValue
            let tempArray = NSMutableArray()
            for data in self.dataArray[indexPath.row]["link"]["url"].arrayValue {
                tempArray.add(data.stringValue)
            }
            model.url = tempArray
            vc.typeStr = "1"
            vc.model = model
            let nav = UINavigationController.init(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
        case 2:
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "VideoDetail") as! VideoDetail
            let model = VideoModel()
            model.vid = self.dataArray[indexPath.row]["link"]["vid"].intValue
            model.url = self.dataArray[indexPath.row]["link"]["url"].stringValue
            vc.typeStr = "2"
            vc.model = model
            let nav = UINavigationController.init(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
        default:
            /*
             * 去除米聊
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "MiTalkDetails") as! MiTalkDetails
            let model = MiTalkModel()
            model.content = self.dataArray[indexPath.row]["link"]["content"].stringValue
            model.fid = self.dataArray[indexPath.row]["link"]["fid"].intValue
            model.avatar = self.dataArray[indexPath.row]["link"]["avatar"].stringValue
            model.publishtime = self.dataArray[indexPath.row]["link"]["publishtime"].stringValue as! NSMutableString
            model.username = self.dataArray[indexPath.row]["link"]["username"].stringValue
            vc.model = model
            self.navigationController?.pushViewController(vc, animated: true)
            */
            return
        }

    }
    
    // MARK: - Private Methods
    
    private func loadData(page: Int) {
        let dict = ["uid": UserDefaults.standard.object(forKey: "uid"),
                    "page": page]
        self.showHud(in: self.view)
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/myfavour", dic: dict as NSDictionary, success: { (data) in
            guard JSON.init(data: data)["error"].intValue == 0 else {
                print("error = 0")
                DeeShareMenu.messageFrame(msg: NSLocalizedString("加载数据失败！", comment: ""), view: self.starMeTableView)
                return
            }
            self.page = JSON.init(data: data)["current_page"].intValue
            self.totalPage = JSON.init(data: data)["lastpage"].intValue
            if page == 1 {
                self.dataArray = JSON.init(data: data)["body"].arrayValue
            } else {
                self.dataArray += JSON.init(data: data)["body"].arrayValue
            }
            print(self.dataArray)
            if self.dataArray.count == 0 {
                self.view.addSubview(self.messageLabel)
                self.view.layoutSubviews()
            }
            self.hideHud()
            self.starMeTableView.reloadData()
            self.starMeTableView.mj_header.endRefreshing()
            self.starMeTableView.mj_footer.endRefreshing()
        }, fail: { (err) in
            self.starMeTableView.mj_header.endRefreshing()
            self.starMeTableView.mj_footer.endRefreshing()
            self.page -= 1
            self.hideHud()
            DeeShareMenu.messageFrame(msg: NSLocalizedString("连接服务器失败！", comment: ""), view: self.starMeTableView)
        }) { (pro) in
            
        }
    }
}
