//
//  searchNews.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/11/2.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import AFNetworking
import MJRefresh
class searchNews: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UITextFieldDelegate {


    var modelArr = NSMutableArray()
    @IBOutlet var TB: UITableView!
    @IBOutlet var sBar: UISearchBar!

    var appDelegate : AppDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TB.register(UINib.init(nibName: "Style1", bundle: nil), forCellReuseIdentifier: "Style1")
        self.TB.register(UINib.init(nibName: "Style2", bundle: nil), forCellReuseIdentifier: "Style2")
        self.TB.register(UINib.init(nibName: "Style3", bundle: nil), forCellReuseIdentifier: "Style3")
        self.TB.register(UINib.init(nibName: "Style4", bundle: nil), forCellReuseIdentifier: "Style4")
        self.sBar.enablesReturnKeyAutomatically = true
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status) in
            if status.rawValue == 0{
                self.TB.mj_footer.endRefreshingWithNoMoreData()
            }
            else{
                self.TB.mj_footer.resetNoMoreData()
            }
        }

        TB.mj_header = MJRefreshHeader.init(refreshingBlock: {
            self.TB.mj_header.endRefreshing()
            print("下拉刷新")

        })
        TB.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            self.loadNews()
            print("上拉加载")
        })



    }
    func testFun() -> Void {
        self.TB.reloadData()
        print("TEST REFRESH!")
    }
//MARK: 搜索
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        UIApplication.shared.keyWindow?.endEditing(true)

    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchContent = sBar.text!
        modelArr.removeAllObjects()
        print(searchContent)
        loadNews()
        UIApplication.shared.keyWindow?.endEditing(true)


    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        UIApplication.shared.keyWindow?.endEditing(true)


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
                cell.model = model
                return cell
            case 2:
                let   cell = tableView.dequeueReusableCell(withIdentifier: "Style3")  as! Style3
                cell.model = model
                return cell
            default:
                let   cell = tableView.dequeueReusableCell(withIdentifier: "Style4")  as! Style4
                cell.model = model
                return cell
            }
        }
        else{
            let  cell = tableView.dequeueReusableCell(withIdentifier: "Style1")  as! Style1
            cell.model = model
            return cell
        }
    }


    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArr.count
    }
    var pageCount = 1
    var searchContent = ""
    func loadNews() -> Void {
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.cachePolicy = .useProtocolCachePolicy
        manager.requestSerializer.timeoutInterval = 5
        manager.responseSerializer = AFHTTPResponseSerializer()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString2 = NSString.init(format: "https://route.showapi.com/109-35?showapi_appid=25473&showapi_sign=b9d5bbc6dd6946a1a45d7ade6eb755df")
        manager.get(urlString2 as String, parameters: ["page":String(pageCount),"title":searchContent], progress: nil, success: {(task,data)  in
            //        request.requestPOST(url: urlString as String, dic: DIC! as NSDictionary, success: { (data) in

                        let Data = try! JSONSerialization.jsonObject(with: data as! Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary

                        let showapi_res_body = Data.value(forKey: "showapi_res_body") as! NSDictionary
                        let  pagebean = showapi_res_body.object(forKey: "pagebean")  as! NSDictionary
                        let contentlist = pagebean.object(forKey: "contentlist") as! NSArray
                        for i in contentlist
                        {
                            let model = toutiaoModel()
                            let tmp = i as! NSDictionary
                            model.setValuesForKeys(tmp as! [String: AnyObject])
                            self.modelArr.add(model)
                        }
            
                        self.pageCount += 1
                        self.TB.reloadData()
                        self.TB.mj_footer.endRefreshing()
        }, failure: {(task,error) in
            print(error)
        })
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = modelArr[indexPath.row] as! toutiaoModel
        let VC = storyboard?.instantiateViewController(withIdentifier: "details") as! Details
        if let link = model.link
        {
            VC.webStr = link
            VC.tt = model.title
            DispatchQueue.global().async {
                VC.shareUrl = model.link
                VC.shareTitle = model.channelName!
                VC.shareDescr = model.title!
                if model.imageurls?.count != 0{
                    let imgDic = model.imageurls?.firstObject as! NSDictionary
                    let str = imgDic.object(forKey: "url") as! String
                    let url = URL.init(string: str)
                    let img = UIImage.animatedImage(withAnimatedGIFURL: url)
                    VC.shareThumImage = img
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
    
}

