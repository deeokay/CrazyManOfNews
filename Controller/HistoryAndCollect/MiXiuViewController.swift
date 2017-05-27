//
//  MiXiuViewController.swift
//  AimiHealth
//
//  Created by ivan on 17/3/1.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import MJRefresh

class MiXiuViewController: HideTabbarController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    // 收藏数据的存储属性
    var dataArr = Array<JSON>()
    // 删除单元的存储属性
    var indexArr: [Int] = []
    // 要删除的图片和视频数组
    var iidArr: [Int] = [] {
        didSet {
            if iidArr.count > 0 {
                self.middleButton.isEnabled = true
            }
        }
    }
    var vidArr: [Int] = [] {
        didSet {
            if vidArr.count > 0 {
                self.middleButton.isEnabled = true
            }
        }
    }
    var messageLabel: UILabel {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: UIwidth, height: 80))
        label.textAlignment = .center
        label.center = self.mixiuCollectionView.center
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 25)
        label.text = NSLocalizedString("暂无收藏内容！", comment: "")
        return label
    }
    var totalPage: Int = 1
    var page: Int = 1
    var footer: MJRefreshAutoFooter {
        let ft = MJRefreshAutoFooter {
            if self.page < self.totalPage {
                self.page += 1
                self.loadData(page: self.page)
            } else {
                DeeShareMenu.messageFrame(msg: "已经到底啦！", view: self.mixiuCollectionView)
            }
        }
        return ft!
    }
    var header: MJRefreshNormalHeader {
        let hd = MJRefreshNormalHeader {
            self.loadData(page: 1)
        }
        return hd!
    }
    var selectedMode: Bool = false

    @IBOutlet weak var mixiuCollectionView: UICollectionView!
    @IBOutlet weak var checkBoxImageView: UIImageView!
    
    @IBOutlet weak var middleButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mixiuCollectionView.register(UINib(nibName: "MiXiuCell", bundle: nil), forCellWithReuseIdentifier: "MiXiuCell")
        self.mixiuCollectionView.delegate = self
        self.mixiuCollectionView.dataSource = self
        
        // 允许多选
        self.mixiuCollectionView.allowsMultipleSelection = true
        self.mixiuCollectionView.mj_header = self.header
        self.mixiuCollectionView.mj_footer = self.footer
        self.loadData(page: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MiXiuViewController.deleteAction), name: NSNotification.Name.init("delete"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedMode = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.selectedMode = false
    }
    

    // MARK: - 获取网络数据
    private func loadData(page: Int) {
        // 等待数据加载完毕，开始转圈圈
        self.showHud(in: self.view)
        
        let page = 1
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let dic =  ["uid":uid, "page": page] as NSDictionary
        
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/sfavorite", dic: dic, success: { (data) in
            
            guard JSON.init(data: data)["error"].intValue == 0 else {
                print("error = 0")
                DeeShareMenu.messageFrame(msg: NSLocalizedString("加载数据失败！", comment: ""), view: self.mixiuCollectionView)
                return
            }
            // 加载成功后要停止圈圈转动
            self.hideHud()
//            print(JSON.init(data: data))
            self.page = JSON.init(data: data)["current_page"].intValue
            self.totalPage = JSON.init(data: data)["lastpage"].intValue
            if page == 1 {
                self.dataArr = JSON.init(data: data)["body"].arrayValue
            } else {
                self.dataArr += JSON.init(data: data)["body"].arrayValue
            }
            if self.dataArr.count == 0 {
                self.view.addSubview(self.messageLabel)
            }
            // 重载列表
            self.mixiuCollectionView.reloadData()
            self.mixiuCollectionView.mj_header.endRefreshing()
            self.mixiuCollectionView.mj_footer.endRefreshing()
        }, fail: { (err) in
            // 加载失败也要停止圈圈转动
            self.hideHud()
            self.mixiuCollectionView.mj_header.endRefreshing()
            self.mixiuCollectionView.mj_footer.endRefreshing()
            self.page -= 1
            DeeShareMenu.messageFrame(msg: NSLocalizedString("连接服务器失败！", comment: ""), view: self.mixiuCollectionView)
        }) { (pro) in
            
        }
        
    }
    
    // MARK: - Private Methods
    // 进入编辑模式
    func deleteAction() {
        AimiFunction.checkLogin(controller: self) { 
            self.selectedMode = !self.selectedMode
            self.rightButton.isEnabled = !self.rightButton.isEnabled
            self.middleButton.isEnabled = !self.middleButton.isEnabled
            let count = self.dataArr.count
            for i in 0..<count {
                let indexPath = NSIndexPath(item: i, section: 0)
                let cell = self.mixiuCollectionView.cellForItem(at: indexPath as IndexPath) as! MiXiuCell
                cell.startSelected = !cell.startSelected
                cell.willBeDeleted = false
                cell.awakeFromNib()
            }
        }
        
    }
    
    // 下方全选按钮点击事件
    @IBAction func middleAction(_ sender: UIButton) {
        
        self.middleButton.isSelected = !self.middleButton.isSelected
        // 先清空
        self.iidArr.removeAll()
        self.vidArr.removeAll()
        // 再选择填不填满
        if self.middleButton.isSelected == true {
            self.checkBoxImageView.image = UIImage.init(named: "用户协议1")
            for i in 0..<self.dataArr.count {
                let indexPath = NSIndexPath.init(item: i, section: 0)
                let cell = self.mixiuCollectionView.cellForItem(at: indexPath as IndexPath) as! MiXiuCell
                cell.startSelected = true
                cell.willBeDeleted = true
                cell.awakeFromNib()
                self.indexArr.append(i)
                if cell.playImageView.isHidden == true {
                    self.iidArr.append(self.dataArr[i]["iid"].intValue)
                } else {
                    self.vidArr.append(self.dataArr[i]["vid"].intValue)
                }
            }
        } else {
            self.checkBoxImageView.image = UIImage.init(named: "用户协议2")
            for i in 0..<self.dataArr.count {
                let indexPath = NSIndexPath.init(item: i, section: 0)
                let cell = self.mixiuCollectionView.cellForItem(at: indexPath as IndexPath) as! MiXiuCell
                cell.startSelected = true
                cell.willBeDeleted = false
                cell.awakeFromNib()
            }
        }
        
    }
    
    // 右下方删除按钮点击事件
    @IBAction func rightAction(_ sender: UIButton) {
        
        var iidString = String()
        for iid in self.iidArr {
            iidString.append("\(iid)")
            if self.iidArr.count > 1 {
                iidString.append(",")
            }
        }
        var vidString = String()
        for vid in self.vidArr {
            vidString.append("\(vid)")
            if self.vidArr.count > 1 {
                vidString.append(",")
            }
        }
        let dic = ["uid": UserDefaults.standard.object(forKey: "uid"),
                   "aid": "",
                   "iid": iidString as NSString,
                   "vid": vidString as NSString,
                   "fid": ""]
        // 显示等待
        self.showHud(in: self.view)
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/delfavour", dic: dic as NSDictionary, success: { (data) in
            // 清除数组记录
            self.iidArr.removeAll()
            self.vidArr.removeAll()
            for i in self.indexArr.sorted().reversed() {
                self.dataArr.remove(at: i)
            }
            self.mixiuCollectionView.reloadData()
            self.hideHud()
            print("删除成功！")
            
        }, fail: { (err) in
            
            self.hideHud()
            
        }) { (pro) in
            
        }
        // 结束选择
        self.selectedMode = false
        let count = self.dataArr.count
        for i in 0..<count {
            let indexPath = NSIndexPath(item: i, section: 0)
            let cell = self.mixiuCollectionView.cellForItem(at: indexPath as IndexPath) as! MiXiuCell
            cell.startSelected = false
            cell.awakeFromNib()
        }
        self.middleButton.isSelected = false
        self.middleButton.isEnabled = false
        self.rightButton.isEnabled = false
    }
    
    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.mixiuCollectionView.dequeueReusableCell(withReuseIdentifier: "MiXiuCell", for: indexPath) as! MiXiuCell
        // 标题
        cell.titleLabel.text = self.dataArr[indexPath.item]["username"].stringValue
        cell.userImageView.kf.setImage(with: URL(string: self.dataArr[indexPath.item]["avatar"].stringValue))
        let mainImageUrl = self.dataArr[indexPath.item]["imgUrl"].stringValue
        if (mainImageUrl.lengthOfBytes(using: .utf8)) > 0 {
            // 如果有imageUrl字段，就使用该字段的URL作为图片地址
            cell.mainImageView.kf.setImage(with: URL(string: mainImageUrl))
        } else {
            // 如果没有，就使用图片组的第一张图片
            let urlArray = self.dataArr[indexPath.item]["url"].arrayValue
            if urlArray.count > 0 {
                let urlString = urlArray.first
                cell.mainImageView.kf.setImage(with: URL.init(string: (urlString?.stringValue)!))
            }
        }
        
        // 如果属于视频，就在中间加入播放按钮
        let play = self.dataArr[indexPath.item]["vfid"].intValue
        if  play > 0 {
            cell.playImageView.image = UIImage(named: "播放")
        } else {
            cell.playImageView.isHidden = true
        }
        
        if self.selectedMode == true {
            cell.startSelected = true
            cell.willBeDeleted = false
            cell.selectedImageView.image = UIImage(named: "未选中")
            cell.awakeFromNib()
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = self.mixiuCollectionView.cellForItem(at: indexPath) as! MiXiuCell
        if self.selectedMode == true && cell.startSelected == true && cell.willBeDeleted == false {
            // 如果点击了选择模式
            
            cell.startSelected = true
            cell.willBeDeleted = true
            cell.awakeFromNib()
            let videoMode = self.dataArr[indexPath.item]["vid"].intValue
            // 根据实际类型，把要删除的记录保存到对应的列表里面去
            if videoMode > 0 {
                self.vidArr.append(self.dataArr[indexPath.item]["vid"].intValue)
            } else {
                self.iidArr.append(self.dataArr[indexPath.item]["iid"].intValue)
            }
            // 记录下要删除的位置
            self.indexArr.append(indexPath.item)
        } else if self.selectedMode == false {
            let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
//            let cell = self.mixiuCollectionView.cellForItem(at: indexPath) as! MiXiuCell
            if cell.playImageView.isHidden == false {
                let playDetailVC = mainStoryBoard.instantiateViewController(withIdentifier: "VideoDetail") as! VideoDetail
                let model = VideoModel()
                model.vid = self.dataArr[indexPath.item]["vid"].intValue
                model.url = self.dataArr[indexPath.item]["url"].stringValue
                model.imgUrl = self.dataArr[indexPath.item]["imgUrl"].stringValue
                playDetailVC.model = model
                playDetailVC.typeStr = "2"
                let nav = UINavigationController(rootViewController: playDetailVC)
                self.present(nav, animated: true, completion: nil)
            } else {
                let picDetailVC = mainStoryBoard.instantiateViewController(withIdentifier: "PicDetail") as! PicDetail
                let model = PictureModel()
                model.iid = self.dataArr[indexPath.item]["iid"].intValue
                let tempArr = self.dataArr[indexPath.item]["url"].arrayValue
                let urlArr = NSMutableArray()
                for url in tempArr {
                    urlArr.add(url.stringValue)
                }
                model.url = urlArr
                picDetailVC.model = model
                picDetailVC.typeStr = "1"
                let nav = UINavigationController(rootViewController: picDetailVC)
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            return
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = self.mixiuCollectionView.cellForItem(at: indexPath) as! MiXiuCell
        if self.selectedMode == true {
            cell.startSelected = true
            cell.willBeDeleted = false
            cell.awakeFromNib()
            
            // 根据实际类型，把要恢复的记录删除
            if cell.playImageView.isHidden == false {
                let vid = self.dataArr[indexPath.item]["vid"].intValue
                var i = 0
                for num in self.vidArr {
                    if num == vid {
                        self.vidArr.remove(at: i)
                        break
                    }
                    i += 1
                }
            } else {
                // 以下同理
                let iid = self.dataArr[indexPath.item]["iid"].intValue
                var j = 0
                for num in self.iidArr {
                    if num == iid {
                        self.iidArr.remove(at: j)
                        break
                    }
                    j += 1
                }
            }
            // 删除对应索引
            var k = 0
            for index in self.indexArr {
                if indexPath.item == index {
                    self.indexArr.remove(at: k)
                    break
                }
                k += 1
            }
        }
        
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let length = self.view.bounds.size.width / 3 - 10
        return CGSize.init(width: length, height: length)
        
        
    }
    

}
