//
//  IndexZ.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/13.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import AFNetworking
import MJRefresh
class IndexZ: UIViewController,UIPageViewControllerDataSource,UIPageViewControllerDelegate,UITableViewDataSource,UITableViewDelegate {
    var pageViewControllers: UIPageViewController!
    var kindList = NSMutableArray()
    var appDelegate : AppDelegate?
    var controllers = [UIViewController]()
    @IBOutlet var kindsOfNews: UIView!
    @IBOutlet var TB: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fullScreen = false
        self.TB.frame = CGRect.init(x: 0, y: 64, width: UIwidth/414*85, height: UIheight-64)
        TBOrginalRect = self.kindsOfNews.frame
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        let DIC = appDelegate?.dic
        let urlString = "https://route.showapi.com/109-34"
        request.requestPOST(url: urlString, dic: DIC! as NSDictionary, success: { (data) in
            let body = try! JSONSerialization.jsonObject(with: data , options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            let showapi_res_body = body.value(forKey: "showapi_res_body") as! NSDictionary
            let channelList = showapi_res_body.value(forKey: "channelList") as! NSArray
            for channelname in channelList
            {
                let model = PageModel()
                let tmp = channelname as! NSDictionary
                model.setValuesForKeys(tmp as! [String:AnyObject])
                self.kindList.add(model)
            }
            self.pageSet()
            self.TB.reloadData()
            self.selectedRow()
        }, fail: { (error) in
            print(error)
        }, Pro: { (pro) in
            print(pro)
        })
        self.TB.mj_header = MJRefreshHeader.init(refreshingBlock: {
            self.TB.mj_header.endRefreshing()
        })

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func pageSet() -> Void {
        for i in 0..<kindList.count {
            let page  = storyboard?.instantiateViewController(withIdentifier: "toutiao") as! toutiao
            let model = kindList.object(at: i) as! PageModel
            page.restorationIdentifier = model.name!
            page.channel = model.name!
            controllers.append(page)
        }
        let  TT = controllers[currentPage]
        pageViewControllers = self.childViewControllers.first as! UIPageViewController
        pageViewControllers.dataSource = self
        pageViewControllers.delegate = self
        pageViewControllers.setViewControllers([TT], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController])
    {
        mark = (pendingViewControllers.first?.restorationIdentifier)!
    }

    var mark = ""
    //MARK: 精华啊!~~~
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {

        if finished && completed{
            if currentPage >= 0 && currentPage < kindList.count{
                var lastModel = PageModel()
                var nextModel = PageModel()
                if currentPage == 0{
                    lastModel.name = ""
                }
                else{
                    lastModel =  kindList[currentPage - 1] as! PageModel
                }
                if currentPage == kindList.count - 1{
                    nextModel.name = ""
                }
                else{
                    nextModel =  kindList[currentPage + 1] as! PageModel
                }
                if  pageViewController.viewControllers?.first?.restorationIdentifier == lastModel.name{
                    currentPage -= 1


                }
                else if  pageViewController.viewControllers?.first?.restorationIdentifier == nextModel.name{
                    currentPage += 1


                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {

    }

    func selectedRow() -> Void {
        self.TB.selectRow(at: IndexPath.init(item: currentPage, section: 0), animated: true, scrollPosition: .middle)
        self.navigationItem.title = pageViewControllers.viewControllers?.first?.restorationIdentifier!
    }

//MARK: 刷新表格
    var refreshTargetTB = {Void()}
    var search = {Void()}
    @IBAction func refreshAllTB(_ sender: Any) {
        let targetPage = pageViewControllers.viewControllers?.first as! toutiao
        targetPage.ClearTBData()

    }


    @IBAction func searchNews(_ sender: Any) {
         search()
    }




    var currentPage = 0 {
        willSet {
            selectedRow()
            self.navigationItem.title = pageViewControllers.viewControllers?.first?.restorationIdentifier!
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentPage > 0 {
            return controllers[currentPage - 1]
        }
        else{
            return nil
        }
    }


    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentPage < kindList.count - 1{
            return controllers[currentPage + 1]
        }
        else{
            return nil
        }
    }

    var fullScreen = false{
        didSet{
            if fullScreen{ //进入全屏
                UIView.animate(withDuration: 0.5, animations: {
                    self.TB.alpha = 0
                    self.kindsOfNews.frame = CGRect.init(x: 0 , y: 64, width: UIwidth, height: UIheight - 64)
                    self.TB.frame.origin = CGPoint.init(x: 0 - (self.TB.frame.size.width), y: 64)
                }, completion: ({(finish) in
                    self.TB.isHidden = true
                    self.TB.removeFromSuperview()
                    self.FSbtn.isEnabled = true
                    self.FSbtn.title = "退出全屏"
                })
                )
            }
            else if !fullScreen{
                self.TB.isHidden = false
                UIView.animate(withDuration: 0.5, animations: {
                    self.TB.alpha = 1
                    self.TB.frame.origin = CGPoint.init(x: 0, y: 64)
                    self.view.addSubview(self.TB)
                    self.kindsOfNews.frame = CGRect.init(x: self.TB.frame.width , y: 64, width:UIwidth - self.TB.frame.width, height: UIheight - 64)
                }, completion: ({(finish) in
                    self.FSbtn.isEnabled = true
                    self.FSbtn.title = "进入全屏"
                })
                )
            }
        }
    }
    //MARK: 切换全屏
    var TBOrginalRect = CGRect()
    @IBAction func fullScreen(_ sender: Any) {
        self.fullScreen = !self.fullScreen

    }
    @IBOutlet var FSbtn: UIBarButtonItem!




    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelcell") as! ChannelCell
        let model = kindList.object(at: indexPath.row) as! PageModel
        cell.channel.setTitle(model.name!, for: .normal)
        cell.event = {
            self.currentPage = indexPath.row
            self.pageViewControllers.setViewControllers([self.controllers[self.currentPage]], direction: .forward, animated: true, completion: nil)
            self.selectedRow()

        }
        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kindList.count
    }
}
