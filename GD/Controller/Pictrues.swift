//
//  Pictrues.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/13.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import MJRefresh
import AFNetworking
import SwiftTheme
class Pictrues: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    var url : String?
    var picArr = NSMutableArray()
    var superVC : PictruesChannel?
    @IBOutlet var cv: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadPICs {
            self.cv.reloadData()
            self.cv.mj_footer.endRefreshing()
            self.pageCnt += 1
        }
        cv.mj_header = MJRefreshHeader.init(refreshingBlock: {
            self.cv.reloadData()
            self.cv.mj_header.endRefreshing()
        })
        cv.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {
            self.loadPICs(completionBlock: {
                self.cv.reloadData()
                self.cv.mj_footer.endRefreshing()
                self.pageCnt += 1
            })
        })
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status) in
            if status.rawValue == 0{
                self.cv.mj_footer.endRefreshingWithNoMoreData()
            }
            else{
                self.cv.mj_footer.resetNoMoreData()
            }
        }

    }




    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadPICs(completionBlock:@escaping ()->Void ) -> Void {
        if let URL = url{
            let dic:NSDictionary = ["page":self.pageCnt,"showapi_appid":APPID,"showapi_sign":SECRET]
            DeeRequest.requestPost(url: URL, dic: dic, success: { (data) in
                let body = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                let res_body = body.value(forKey: "showapi_res_body") as! NSDictionary
                let allPages = res_body.value(forKey: "allPages") as! Int
                let contentlist = res_body.value(forKey: "contentlist") as! NSArray
                for i in contentlist{
                    let tmp = i as! NSDictionary
                    let model = picModel()
                    model.setValuesForKeys(tmp as! [String:AnyObject])
                    self.picArr.add(model)
                }
                if allPages == self.pageCnt{
                    self.cv.mj_footer.endRefreshingWithNoMoreData()
                }
                else{
                    completionBlock()
                }
                let count = self.cv.numberOfItems(inSection: 0)
                self.superVC?.recieveCount(cout: count)
            }, fail: { (error) in
                print(error)
                self.cv.mj_footer.endRefreshing()
            }, Pro: { (pro) in
                //                print(pro)
            })
        }
    }
    var pageCnt = 1


    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        print("CV开始滑动!")
        self.loadCell = false
    }

     func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false{
//            print("CV停止滑动并准备减速!")
            self.loadCell = true
        }
        else{
//            print("CV停止滑动并没有减速!")
            self.loadCell = true
        }
    }

    


    var loadCell = true
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "picCell", for: indexPath) as! PicCell
//        cell.img.image = UIImage()
        cell.bgView.theme_backgroundColor = ThemeColorPicker.init(colors: "#FFFFFF","#555555")
//        if (loadCell == true){
        let model = self.picArr.object(at: indexPath.row) as! picModel
        cell.model = model
        cell.num.text = String(picArr.index(of: model))
//        }

//        print(loadCell)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArr.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: (UIwidth - 2)/2, height: (UIwidth - 2)/2)
    }

    //MARK: 切换滚动浏览
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ScrollPic") as! ScrollPic
        vc.showIndex = indexPath.row
        vc.superVC = self
        self.navigationController?.pushViewController(vc, animated: true)


    }
    override func viewWillAppear(_ animated: Bool) {
        self.cv.reloadData()
    }

}
