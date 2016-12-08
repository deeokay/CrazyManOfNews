//
//  WeChatJX.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/24.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import AFNetworking
import MJRefresh
class WeChatJX: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var appDelegate : AppDelegate?
    var modelArr = NSMutableArray()

    @IBOutlet var TB: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status) in
            if status.rawValue == 0{
                self.TB.mj_footer.endRefreshingWithNoMoreData()
            }
            else{
                self.TB.mj_footer.resetNoMoreData()
            }
        }

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
        loadNews()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeChatCell")  as! WeChatCell
        let model = modelArr.object(at: indexPath.row) as! WeChatJXModel
        //        let model = modelArr.object(at: (indexPath as NSIndexPath).row) as! toutiaoModel

        cell.model = model
        return cell
    }




    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArr.count
    }
    var pageCount = 1


    func loadNews() -> Void {
        let urlString = "https://route.showapi.com/181-1"
        let DIC = appDelegate?.dic
        DIC?.setValuesForKeys(["page":String(pageCount),"num":"50","rand":"0"])

        request.requestPOST(url: urlString, dic: DIC! as NSDictionary, success: { (data) in
            let Data = try! JSONSerialization.jsonObject(with: data , options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            let showapi_res_body = Data.value(forKey: "showapi_res_body") as! NSDictionary
            let  pagebean = showapi_res_body.object(forKey: "newslist")  as! NSArray
//            let allPages = pagebean.object(forKey: "allPages") as! Int
            for i in pagebean
            {
                let model = WeChatJXModel()
                let tmp = i as! NSDictionary
                model.setValuesForKeys(tmp as! [String: AnyObject])
                model.des = tmp.value(forKey: "description") as? String
                self.modelArr.add(model)
            }
//            if allPages == self.pageCount{
//                self.TB.mj_footer.endRefreshingWithNoMoreData()
//            }
//            else{
//                self.TB.mj_footer.endRefreshing()
//            }
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
        let model = modelArr[indexPath.row] as! WeChatJXModel
        let VC = storyboard?.instantiateViewController(withIdentifier: "details") as! Details
        if let link = model.url
        {
            VC.webStr = link
            VC.tt = model.title!
            DispatchQueue.global().async {
                VC.date = "来自微信精选"
                VC.channelName = model.des!
                VC.shareDescr = model.title!
                VC.picImg = model.picUrl
                VC.shareThumImage = UIImage.animatedImage(withAnimatedGIFURL: URL.init(string: model.picUrl!))
            }
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    
    
    
}


