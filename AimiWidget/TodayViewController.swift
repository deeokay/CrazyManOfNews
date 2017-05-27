//
//  TodayViewController.swift
//  Widget
//
//  Created by iMac for iOS on 2017/4/21.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UIKit
import NotificationCenter
import AFNetworking
import Kingfisher
import MJExtension
class TodayViewController: UIViewController,NCWidgetProviding,UITableViewDelegate,UITableViewDataSource {
    
    let user = UserDefaults.init(suiteName: "group.AimiHealth")
    @IBOutlet weak var TB: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSHomeDirectory())
        self.TB.tableFooterView = UIView()
        self.TB.register(UINib.init(nibName: "MiquanS2", bundle: nil), forCellReuseIdentifier: "MiquanS2")
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        } else {
            
        }
        // Do any additional setup after loading the view from its nib.
        if let page = user?.integer(forKey: "page"){
            self.pageCount = page
        }
        if let cacheArr = user?.value(forKey: "cache") as! NSArray?{
            print("有缓存")
            self.modelArr = cacheArr as! [NSDictionary]
            self.TB.reloadData()
        }
        else{
            print("没有缓存")
            self.loadNews()
        }
    }
    
    
    @IBOutlet weak var Rcon: NSLayoutConstraint!
    @IBOutlet weak var Lcon: NSLayoutConstraint!
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact:
//            self.nextPage.isHidden = true
//            self.goToApp.isHidden = true
            Lcon.constant = -38
            Rcon.constant = -40
            self.preferredContentSize = CGSize.init(width: UIScreen.main.bounds.width, height: 110)
            rowHeight = 110
        default:
            Lcon.constant = 0
            Rcon.constant = 0
            self.preferredContentSize = CGSize.init(width: UIScreen.main.bounds.width, height: 400)
            rowHeight = (400 - 38) / 2
        }
        self.TB.reloadData()
    }
    
    
    var modelArr = [NSDictionary]()
    func loadNews(){
        self.nextPage.setTitle("皇上慢点!", for: .disabled)
        self.nextPage.isEnabled = false
        let urlString = "https://aimi.cupiday.com/v1.1/article"
        let dic:NSDictionary = ["page":pageCount,"version":"v1.1","channel":15]
        DeeRequest.requestGet(url: urlString, dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data , options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                print("解析数据失败!")
                return
            }
            guard json.object(forKey: "error") as! Int == 0 else{
                print("ERROR为1,应为越界请求?")
                self.nextPage.setTitle("点击重试", for: .normal)
                self.nextPage.isEnabled = true
                return
            }
            if let lastPage = json.object(forKey: "lastpage") as! Int?{
                self.pageTotal = lastPage
            }
            if let arr = json.value(forKey: "data") as! NSArray?
            {
                for i in arr
                {
                    let tmp = i as! NSDictionary
                    self.modelArr.append(tmp)
                }
                self.user?.set(self.modelArr, forKey: "cache")
                self.user?.synchronize()
                self.TB.reloadData()
                self.nextPage.setTitle("换下一套", for: .normal)
                self.nextPage.isEnabled = true
                self.extraBlock()
                
            }
            
        }, fail: { (error) in
            self.nextPage.setTitle("点击重试", for: .normal)
            self.nextPage.isEnabled = true
            print(error.localizedDescription)
        }, Pro: { (pro) in
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.modelArr.count >= 2{
            return 2
        }
        else{
            return self.modelArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tmp = modelArr[indexPath.row]
        let model = ArticleModel()
        model.setValuesForKeys(tmp as! [String : Any])
        let cell = tableView.dequeueReusableCell(withIdentifier: "MiquanS2") as! MiquanS2
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        let url = URL.init(string: model.imgUrl)
        cell.img.kf.setImage(with: url)
        cell.publishTime.text = (model.publishtime as NSString).substring(with: NSRange.init(location: 5, length: 11))
        cell.title.text = model.title
        return cell
    }
    
    var rowHeight = CGFloat()
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.extensionContext?.open(URL.init(string: "widget://")!, completionHandler: { (b) in
            let model = self.modelArr[indexPath.row]
            let p = UIPasteboard.init(name: UIPasteboardName.general, create: true)
            p?.string = "model"
            p?.setData(model.mj_JSONData(), forPasteboardType: "model")
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("挂件收到内存警告!")
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
    }
    
    
    
    @IBOutlet weak var goToApp: UIButton!
    @IBOutlet weak var nextPage: UIButton!
    var extraBlock = {Void()}
    var pageCount = 1
    var pageTotal = Int()
    @IBAction func nextPage(_ sender: UIButton) {
        extraBlock = {
            self.modelArr.removeFirst()
            self.modelArr.removeFirst()
            self.user?.set(self.modelArr, forKey: "cache")
            self.user?.synchronize()
            self.TB.reloadData()
            sender.isEnabled = false
            if #available(iOSApplicationExtension 10.0, *) {
                Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { (timer) in
                    sender.isEnabled = true
                })
            } else {
                // Fallback on earlier versions
            }
        }
        if self.modelArr.count <= 2 {
            print("越界了")
            if self.pageTotal == pageCount{
                self.pageCount = 1
                self.user?.set(self.pageCount, forKey: "page")
                self.user?.synchronize()
            }
            else{
                self.pageCount += 1
                self.user?.set(self.pageCount, forKey: "page")
                self.user?.synchronize()
            }
            self.loadNews()
        }
        else{
            extraBlock()
        }
        
    }
    
    
    @IBAction func enterApp(_ sender: UIButton) {
        self.extensionContext?.open(URL.init(string: "go://")!, completionHandler: { (b) in
        })
    }
}

class DeeRequest{
    class func requestGet(url:String,dic:NSDictionary,success: @escaping (_ data:Data)->Void,fail: @escaping (_ error:Error)->Void,Pro: @escaping (_ progress:Int64)->Void)-> Void{
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.cachePolicy = .useProtocolCachePolicy
        manager.requestSerializer.timeoutInterval = 5
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.get(url, parameters: dic, progress: {(p) in
        }, success: { (task, data) in
            success (data as! Data)
        }) { (task, error) in
            fail (error )
        }
    }
}
