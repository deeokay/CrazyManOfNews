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
class Pictrues: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    var url : String?
    var picArr = NSMutableArray()
    @IBOutlet var cv: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadPICs {
            self.cv.reloadData()
            self.cv.mj_footer.endRefreshing()
            self.pageCnt += 1
        }
        cv.mj_header = MJRefreshHeader.init(refreshingBlock: {
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

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "count"{
            print("kwkwkwkw")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadPICs(completionBlock:@escaping ()->Void ) -> Void {
        if let URL = url{
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let dic = appdelegate.dic
            dic?.setValuesForKeys(["page":self.pageCnt])
            request.requestPOST(url: URL, dic: dic!, success: { (data) in
                let body = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                let res_body = body.value(forKey: "showapi_res_body") as! NSDictionary
                let contentlist = res_body.value(forKey: "contentlist") as! NSArray
                for i in contentlist{
                    let tmp = i as! NSDictionary
                    let model = picModel()
                    model.setValuesForKeys(tmp as! [String:AnyObject])
                    self.picArr.add(model)
                }
                completionBlock()
            }, fail: { (error) in
                print(error)
            }, Pro: { (pro) in
                print(pro)
            })
        }
    }
        var pageCnt = 1
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.width

        public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "picCell", for: indexPath) as! PicCell
            cell.img.image = UIImage()
            let model = picArr.object(at: indexPath.row) as! picModel
            cell.model = model
            return cell
        }

        @available(iOS 6.0, *)
        public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return picArr.count
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            return CGSize(width: (width - 5)/2, height: (width - 5)/2)
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
        //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        //        return CGSize.init(width: 0, height: 80)
        //    }
        //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        //        return CGSize.init(width: 0, height: 20)
        //
        //    }
        
        
        
}
