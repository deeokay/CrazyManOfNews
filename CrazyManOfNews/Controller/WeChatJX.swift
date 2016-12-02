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
        loadNews()
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
        header?.setTitle("松手就脱裤子!!!", for: .pulling)
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
        let urlString = "http://v.juhe.cn/weixin/query?key=c264d77453a6b6aa2d2668dcd594cbad&pno=%d"
        let url = NSString.init(format: urlString as NSString, pageCount)
        let dic = NSDictionary()
        request.requestPOST(url: url as String, dic: dic, success: { (data) in
            let Data = try! JSONSerialization.jsonObject(with: data , options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            let result = Data.value(forKey: "result") as! NSDictionary
            let list = result.object(forKey: "list") as! NSArray
            for i in list
            {
                let model = WeChatJXModel()
                let tmp = i as! NSDictionary
                model.setValuesForKeys(tmp as! [String: AnyObject])
                self.modelArr.add(model)
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
        let model = modelArr[indexPath.row] as! WeChatJXModel
        let VC = storyboard?.instantiateViewController(withIdentifier: "details") as! Details
            if let link = model.url
            {
                VC.webStr = link
                VC.tt = model.title
                DispatchQueue.global().async {
                    VC.shareUrl = model.url!
                    VC.shareTitle = model.source!
                    VC.shareDescr = model.title!
                    VC.shareThumImage = UIImage.animatedImage(withAnimatedGIFURL: URL.init(string: model.firstImg!))
                }
                self.navigationController?.pushViewController(VC, animated: true)
        }
    }




}


