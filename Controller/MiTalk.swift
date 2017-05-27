//
//  MiTalk.swift
//  Aimi-V1.1
//
//  Created by iMac for iOS on 2017/3/29.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UIKit
import MJRefresh
import MJExtension
import AFNetworking
class MiTalk: HSController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {

    @IBOutlet weak var editText: UITextField!
    @IBOutlet weak var TB: UITableView!
    var arr = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TB.register(UINib.init(nibName: "MiTalkCell", bundle: nil), forCellReuseIdentifier: "MiTalkCell")
        self.TB.tableFooterView = UIView()
        let bar = self.tabBarController as! Tabbar
        bar.action2 = {
            if self.TB.mj_header.isRefreshing() {
                return
            } else {
                if  bar.selectedIndex == 1{
                    if self.arr.count != 0{
                        self.TB.scrollToRow(at: IndexPath.init(item: 0, section: 0), at: .top, animated: false)
                    }
                    self.TB.mj_header.beginRefreshing()
                }
            }
        }
        let header = MJRefreshNormalHeader.init {
            if AFNetworkReachabilityManager.shared().networkReachabilityStatus.rawValue != 0{
                self.pageCount = 1
                self.getData()
                self.TB.mj_header.endRefreshing()
                self.TB.mj_footer.resetNoMoreData()
            }
            else{
                DeeShareMenu.messageFrame(msg: NSLocalizedString("请检查网络!", comment: ""), view: self.view)
                self.TB.mj_header.endRefreshing()
            }
        }
        header?.setTitle(NSLocalizedString("用力拉用力拉!!!", comment: ""), for: .idle)
        header?.setTitle(NSLocalizedString("没有任何数据可以刷新!!!", comment: ""), for: .noMoreData)
        header?.setTitle(NSLocalizedString("服务器都快炸了!!!", comment: ""), for: .refreshing)
        header?.setTitle(NSLocalizedString("一松手就洗个脸!!!", comment: ""), for: .pulling)
        header?.isAutomaticallyChangeAlpha = true
        TB.mj_header = header
        
        let footer = MJRefreshAutoNormalFooter.init {
            self.getData()
            self.TB.mj_footer.endRefreshing()
        }
        footer?.setTitle(NSLocalizedString("推我上去看天下!", comment: ""), for: .willRefresh)
        footer?.setTitle(NSLocalizedString("别眨眼!!!", comment: ""), for: .refreshing)
        footer?.setTitle(NSLocalizedString("放手也是爱!过后我还在!", comment: ""), for: .pulling)
        footer?.isAutomaticallyChangeAlpha = true
        self.TB.mj_footer = footer
        if let cache = UserDefaults.standard.array(forKey: cacheMitalk){
            if cache.count != 0{
                print("发现米聊缓存!")
                for i in cache{
                    let tmp = i as! NSDictionary
                    let model = MiTalkModel()
                    model.setValuesForKeys(tmp as! [String : Any])
                    self.arr.add(model)
                    self.TB.insertRows(at: [IndexPath.init(row: self.TB.numberOfRows(inSection: 0), section: 0)], with: .left)
                }
            }
            else{
                self.getData()
            }
        }
        self.getData()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initModelsInArray(sourceArr:NSArray,model:AnyObject,inputArr:NSMutableArray,complete:()->Void,finishCallback:()->Void) -> Void {
        for i in sourceArr{
        let tmp = i as! NSDictionary
        let model = model
        model.setValuesForKeys(tmp as! [String : Any])
        inputArr.add(model)
            complete()
        }
    }
    
    
    var pageCount = 1
    func getData() -> Void {
        let dic:NSDictionary = ["page":pageCount,"version":"\(AISubMIversion)","uid":UserDefaults.standard.integer(forKey: "uid")]
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/forum", dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary else{
                DeeShareMenu.messageFrame(msg: NSLocalizedString("服务器错误", comment: ""), view: self.view)
                print("解析米聊JSON失败!")
                return
            }
            
            guard json.object(forKey: "error") as? Int == 0 else{
                print("越界请求!")
                return
            }
            


            if let jsonArr = json.object(forKey: "data") as? NSArray{
                if self.pageCount == 1{
                    self.arr.removeAllObjects()
                    self.cacheArr.removeAllObjects()
                    self.TB.reloadData()
                }
                for i in jsonArr{
                    let tmp = i as! NSDictionary
                    let model = MiTalkModel()
                    model.mj_setKeyValues(tmp)
                    self.arr.add(model)
                    self.cacheArr.add(tmp)
                }
                UserDefaults.standard.set(self.cacheArr, forKey: cacheMitalk)
                UserDefaults.standard.synchronize()
                self.TB.reloadData()
                self.tabBarController?.tabBar.items?[1].badgeValue = nil
                DeeShareMenu.messageFrame(msg: Locale.cast(str: "加载成功"), view: self.view)
                if let jsonCount = json.object(forKey: "lastpage") as? Int{
                    if jsonCount == self.pageCount{
                        self.TB.mj_footer.endRefreshingWithNoMoreData()
                    }
                    else{
                        self.pageCount += 1
                    }
                }
            }
         }, fail: { (error) in
            print(error)
        }, Pro: { (pro) in
            print(pro)
        })
        
    }
    var cacheArr = NSMutableArray()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MiTalkCell") as! MiTalkCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MiTalkCell", for: indexPath) as! MiTalkCell
        let model = self.arr.object(at: indexPath.row) as! MiTalkModel
//        cell.avatar.layer.cornerRadius = UIwidth * 0.075
        cell.model = model
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let vc = storyboard?.instantiateViewController(withIdentifier: "EditMiTalk") as! EditMiTalk
        vc.delegate = self
        vc.text = self.editText.text!
        self.navigationController?.pushViewController(vc, animated: true)
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MiTalkDetails") as! MiTalkDetails
        vc.model = self.arr.object(at: indexPath.row) as! MiTalkModel
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    var shieldContent = false
    var shieldUser = false
    var shieldModel = DeeMedia()
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
        if shieldContent{
            self.arr = AimiFunction.shieldContentRefresh(sourceArr: self.arr, model: self.shieldModel)
            self.TB.reloadData()
            self.shieldContent = false
        }
        if shieldUser{
            self.arr = AimiFunction.shieldUserRefresh(sourceArr: self.arr, model: self.shieldModel)
            self.TB.reloadData()
            self.shieldUser = false
        }
    }

    
    @IBAction func release(_ sender: UIButton) {
        guard (self.editText.text?.lengthOfBytes(using: String.Encoding.utf8))! > 15 else{
            DeeShareMenu.messageFrame(msg: "内容必须长于15字", view: self.view)
            return
        }
        AimiFunction.checkLogin(controller: self) {
            let uid = UserDefaults.standard.integer(forKey: "uid")
            let dic:NSDictionary = ["uid":uid,"content":self.editText.text!]
            DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/user_publish_forum", dic: dic, success: { (data) in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                    print("发布话题返回的JSON有错误!")
                    return
                }
                if json.object(forKey: "error") as! Int == 0{
                    DeeShareMenu.messageFrame(msg: "发布成功!", view: self.view)
                    self.editText.text?.removeAll()
                    delay(1, completion: {
                        self.pageCount = 1
                        self.getData()
                        self.TB.mj_header.endRefreshing()
                        self.TB.mj_footer.resetNoMoreData()
                    })
                }
            }, fail: { (err) in
                DeeShareMenu.messageFrame(msg: "发布失败!", view: self.view)
                print(err.localizedDescription)
            }, Pro: { (pro) in
            })
        }
    }
}
