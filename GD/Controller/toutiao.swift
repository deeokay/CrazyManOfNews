//
//  toutiao.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/11.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import AFNetworking
import MJRefresh
import SwiftTheme
class toutiao: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var channel = "新闻频道"
    var modelArr = NSMutableArray()
    @IBOutlet var TB: UITableView!
    var appDelegate : AppDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TB.register(UINib.init(nibName: "Style1", bundle: nil), forCellReuseIdentifier: "Style1")
        self.TB.register(UINib.init(nibName: "Style2", bundle: nil), forCellReuseIdentifier: "Style2")
        self.TB.register(UINib.init(nibName: "Style3", bundle: nil), forCellReuseIdentifier: "Style3")
        self.TB.register(UINib.init(nibName: "Style4", bundle: nil), forCellReuseIdentifier: "Style4")
        appDelegate = UIApplication.shared.delegate as! AppDelegate?
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status) in
            if status.rawValue == 0{
                self.TB.mj_footer.endRefreshingWithNoMoreData()
            }
            else{
                self.TB.mj_footer.resetNoMoreData()
            }
        }
        loadNews()

        let header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: nil)
        header?.setTitle("用力拉用力拉!!!", for: .idle)
        header?.setTitle("没有任何数据可以刷新!!!", for: .noMoreData)
        header?.setTitle("服务器都快炸了!!!!", for: .refreshing)
        header?.refreshingBlock = {
            self.TB.reloadData()
            self.TB.mj_header.endRefreshing()
        }
        TB.mj_header = header
        let footer = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: nil)
        footer?.setTitle("推我上去看天下!", for: .willRefresh)
        footer?.setTitle("别眨眼!!!", for: .refreshing)
        footer?.setTitle("放手也是爱!过后我还在!", for: .pulling)
        footer?.refreshingBlock = {
            self.loadNews()
            footer?.endRefreshing()
        }
        TB.mj_footer = footer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = modelArr.object(at: indexPath.row) as! toutiaoModel
        if model.havePic == false{
            return UITableViewAutomaticDimension
        }
        else{
            return 250
        }
    }



    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = modelArr.object(at: indexPath.row) as! toutiaoModel
        var count = 0
        if model.havePic == true
        {
            if let array = model.imageurls
            {
                count = array.count
            }
            switch count {
            case 1:
                let   cell = tableView.dequeueReusableCell(withIdentifier: "Style2")  as! Style2
//                cell.Title.font = UIFont.systemFont(ofSize: (appDelegate?.newsTitle)!)
//                cell.subText.font = UIFont.systemFont(ofSize: (appDelegate?.newsSubTitle)!)
                cell.model = model
                return cell
            case 2:
                let   cell = tableView.dequeueReusableCell(withIdentifier: "Style3")  as! Style3
//                cell.Title.font = UIFont.systemFont(ofSize: (appDelegate?.newsTitle)!)
//                cell.subText.font = UIFont.systemFont(ofSize: (appDelegate?.newsSubTitle)!)
                cell.model = model
                return cell
            default:
                let   cell = tableView.dequeueReusableCell(withIdentifier: "Style4")  as! Style4
//                cell.Title.font = UIFont.systemFont(ofSize: (appDelegate?.newsTitle)!)
//                cell.subText.font = UIFont.systemFont(ofSize: (appDelegate?.newsSubTitle)!)
                cell.model = model
                return cell
            }
        }
        else{
            let  cell = tableView.dequeueReusableCell(withIdentifier: "Style1")  as! Style1
//            cell.title.font = UIFont.systemFont(ofSize: (appDelegate?.newsTitle)!)
//            cell.subText.font = UIFont.systemFont(ofSize: (appDelegate?.newsSubTitle)!)
            cell.model = model
            return cell
        }
    }


    @IBOutlet var progressView: UIProgressView!
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArr.count
    }
    var pageCount = 1

    func loadNews() -> Void {
        let urlString = "https://route.showapi.com/109-35"
        let DIC = ["showapi_appid":APPID,"showapi_sign":SECRET,"page":String(pageCount),"channelName":channel]
        DeeRequest.requestPost(url: urlString, dic: DIC as NSDictionary, success: { (data) in
            let Data = try! JSONSerialization.jsonObject(with: data , options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            let showapi_res_body = Data.value(forKey: "showapi_res_body") as! NSDictionary
            let  pagebean = showapi_res_body.object(forKey: "pagebean")  as! NSDictionary
            let contentlist = pagebean.object(forKey: "contentlist") as! NSArray
            let allPages = pagebean.object(forKey: "allPages") as! Int
            for i in contentlist
            {
                let model = toutiaoModel()
                let tmp = i as! NSDictionary
                model.setValuesForKeys(tmp as! [String: AnyObject])
                self.modelArr.add(model)
            }
            if allPages == self.pageCount{
                self.TB.mj_footer.endRefreshingWithNoMoreData()
            }
            else{
                self.TB.mj_footer.endRefreshing()
            }
            self.pageCount += 1
            self.TB.reloadData()
            self.TB.mj_footer.endRefreshing()
        }, fail: { (error) in
            print(error)
        }, Pro: { (pro) in
            print(pro)
        })
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = modelArr[indexPath.row] as! toutiaoModel
        let VC = storyboard?.instantiateViewController(withIdentifier: "details") as! Details
        if model.link != nil
        {
            VC.tt = model.title
            DispatchQueue.global().async {
                VC.webStr = model.link
                VC.channelName = model.channelName!
                VC.shareDescr = model.title!
                VC.date = model.pubDate
                if model.imageurls?.count != 0{
                    let imgDic = model.imageurls?.firstObject as! NSDictionary
                    let str = imgDic.object(forKey: "url") as! String
                    let url = URL.init(string: str)
                    let img = UIImage.animatedImage(withAnimatedGIFURL: url)
                    VC.shareThumImage = img
                    VC.picImg = str
                }
            }
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    var ClearTBData = {Void()}
    override func viewDidAppear(_ animated: Bool) {
        self.ClearTBData = {
            self.modelArr.removeAllObjects()
            self.pageCount = 1
            self.loadNews()
            self.TB.reloadData()

        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.TB.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        self.TB.isHidden = false
        self.view.theme_backgroundColor = ThemeColorPicker(colors: "#FFF", "#000")
    }



}


