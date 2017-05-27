//
//  MyUpload.swift
//  AimiHealth
//
//  Created by apple on 2016/12/29.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit
import MJRefresh
import AFNetworking
import MMPopupView
import TabPageViewController
import AVFoundation
import Kingfisher
class MyUpload: HideTabbarController,UITableViewDelegate,UITableViewDataSource{

    var bodyArr = NSArray()
    @IBOutlet weak var TB: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TB.tableFooterView = UIView.init()
        let header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: nil)
        header?.setTitle(NSLocalizedString("用力拉用力拉!!!", comment: ""), for: .idle)
        header?.setTitle(NSLocalizedString("没有任何数据可以刷新!!!", comment: ""), for: .noMoreData)
        header?.setTitle(NSLocalizedString("服务器都快炸了!!!", comment: ""), for: .refreshing)
        header?.setTitle(NSLocalizedString("一松手就洗个脸!!!", comment: ""), for: .pulling)
        header?.isAutomaticallyChangeAlpha = true
        header?.refreshingBlock = {
            if AFNetworkReachabilityManager.shared().networkReachabilityStatus.rawValue != 0{
                self.getImageList()
                self.TB.mj_header.endRefreshing()
            }
            else{
                DeeShareMenu.messageFrame(msg: NSLocalizedString("请检查网络!", comment: ""), view: self.view)
                self.TB.mj_header.endRefreshing()
            }
        }

        self.TB.mj_header = header
    }

    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "isLogin"){
        self.getImageList()
        }
        else{
//            DeeShareMenu.messageFrame(msg: Locale.cast(str: "你还没登录呢!"), view: self.view)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
    }


    func getImageList() -> Void {
        AimiFunction.checkToken(success: { 
            let uid = UserDefaults.standard.integer(forKey: "uid")
            let token = UserDefaults.standard.object(forKey: "token") as! String
            let dic = ["uid":uid,"token":token] as NSDictionary
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/user_publish_history", dic: dic, success: { (data) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                    print("解析读取发布历史Json失败!")
                    return
                }
                if json.object(forKey: "error") as! Int == 0{
                    self.bodyArr = json.object(forKey: "body") as! NSArray
                    self.TB.reloadData()
                }
            }, fail: { (err) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                print("请求发布历史失败!",err)
            }) { (pro) in
            }
        }, fail: {
            _ = self.navigationController?.popViewController(animated: true)
        }, controller: self)
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return self.bodyArr.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dic = bodyArr.object(at: section) as!  NSDictionary
        let arr = dic.object(forKey: "url") as! NSArray
        let url = arr.object(at: 0) as! NSString
        let sub = (url.substring(with: NSRange.init(location: url.length - 3, length: 3)))
        if sub != "png" && sub != "jpg"
        {
            return 1
        }
        else{
            return arr.count
        }
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "uploadCell") as! MyUplaodCell
        let dic = bodyArr.object(at: indexPath.section) as!  NSDictionary
        let arr = dic.object(forKey: "url") as! NSArray
        let url = arr.object(at: indexPath.row) as! NSString
        let sub = (url.substring(with: NSRange.init(location: url.length - 3, length: 3)))
        if sub != "png" && sub != "jpg"
        {
            let url2 = arr.object(at: 1)  as! String
            cell.type.text = NSLocalizedString("视频", comment: "")
            cell.img.kf.setImage(with: URL.init(string: url2))
        }
        else{
            cell.type.text = NSLocalizedString("图集", comment: "")
            cell.img.kf.setImage(with: URL.init(string: url as String))
        }
        if dic.object(forKey: "checking") as! Int == 0 {
            cell.checkStatus.text = NSLocalizedString("审核中", comment: "")
            cell.checkStatus.textColor = UIColor.blue
        }
        else{
            cell.checkStatus.text = NSLocalizedString("审核通过", comment: "")
            cell.checkStatus.textColor = UIColor.green
        }

        cell.desc.text = (dic.object(forKey: "title") as! String)
        cell.date.text = (dic.object(forKey: "create_time") as! String)
        cell.img.layer.cornerRadius = 3
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }


    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dic = bodyArr.object(at: section) as!  NSDictionary
        let label = UILabel.init()
        label.backgroundColor = UIColor.lightGray
        let format = DateFormatter.init()
        format.dateFormat = "yyyyMMdd"
        label.text = "\(NSLocalizedString("上传时间", comment: "")) : \(dic.object(forKey: "create_time") as! String)"
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }



    @IBAction func upLoad(_ sender: Any) {
        AimiFunction.checkLogin(controller: self) { 
            let uploadPic = MMPopupItem.init()
            uploadPic.title = NSLocalizedString("上传图集", comment: "")
            uploadPic.handler = { (num) in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyUploadDetail") as! MyUploadDetail
                self.navigationController?.pushViewController(vc, animated: true)
            }
            let uploadVideo = MMPopupItem.init()
            uploadVideo.title = NSLocalizedString("上传视频", comment: "")
            uploadVideo.handler = {  (num) in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "uploadVideo") as! uploadVideo
                self.navigationController?.pushViewController(vc, animated: true)
            }
            let cancel = MMPopupItem.init()
            cancel.title = NSLocalizedString("取消", comment: "")
            //        let sheetView = MMSheetView.init(title: "上传你的内容", items: [uploadPic,uploadVideo,cancel])
            let sheetView = MMAlertView.init(title: NSLocalizedString("上传你的内容", comment: ""), detail: NSLocalizedString("上传并审核通过的内容会显示在列表上,所有用户能浏览你的内容", comment: ""), items: [uploadPic,uploadVideo,cancel])
            
            sheetView?.show()
        }
        
    }
}
