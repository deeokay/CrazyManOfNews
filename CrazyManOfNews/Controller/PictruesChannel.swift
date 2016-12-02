//
//  PictruesChannel.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/14.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import AFNetworking
import MJRefresh
class PictruesChannel: UIViewController,UIPageViewControllerDelegate {

    var staticPic:Pictrues?
    var dynamic:Pictrues?
    @IBOutlet var item: UINavigationItem!

    @IBAction func pageChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            pageViewControllers.setViewControllers([staticPic!], direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: nil)
        case 1:
            if flowWarning{
                let alert = UIAlertController.init(title: "大量X图流量会爆炸!", message: "前方高能", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(title: "朕刹车", style: UIAlertActionStyle.default, handler: { (action) in
                    self.pageViewControllers.setViewControllers([self.staticPic!], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
                    sender.selectedSegmentIndex = 0
                }))
                alert.addAction(UIAlertAction.init(title: "别烦朕", style: UIAlertActionStyle.default, handler: { (action) in
                    self.pageViewControllers.setViewControllers([self.dynamic!], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
                    self.flowWarning = false
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.pageViewControllers.setViewControllers([self.dynamic!], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
            }

        default:
            break
        }
    }
    var flowWarning = true

    @IBOutlet var picChannelNum: UISegmentedControl!
    var pageViewControllers: UIPageViewController!
    var controllers = [UIViewController]()
    var vcArr = ["静态图库","动态图库"]
    override func viewDidLoad() {
        super.viewDidLoad()
        staticPic = storyboard?.instantiateViewController(withIdentifier: "Pictures") as? Pictrues
        staticPic?.url = "http://route.showapi.com/341-2"
        staticPic?.restorationIdentifier = vcArr[0]
        dynamic = storyboard?.instantiateViewController(withIdentifier: "Pictures") as? Pictrues
        dynamic?.url = "http://route.showapi.com/341-3"
        dynamic?.restorationIdentifier = vcArr[1]
        controllers.append(staticPic!)
        controllers.append(dynamic!)
        pageViewControllers = self.childViewControllers.first as! UIPageViewController
        //        pageViewControllers.dataSource = self
        //        pageViewControllers.delegate = self
        pageViewControllers.setViewControllers([staticPic!], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        self.item.title = staticPic?.restorationIdentifier
    }
    //    @available(iOS 5.0, *)
    //    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    //        if viewController == staticPic{
    //            return dynamic
    //        }
    //        else{
    //            return staticPic!
    //        }
    //
    //    }
    //    @available(iOS 5.0, *)
    //    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    //        if viewController == dynamic{
    //            return staticPic
    //        }
    //        else{
    //            return dynamic!
    //        }
    //    }

    @IBAction func cleanCache(_ sender: Any) {
        self.staticPic?.cv.reloadData()
        self.dynamic?.cv.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    //        if finished && completed {
    //            let tmpPageName = pageViewController.viewControllers?.first?.restorationIdentifier!
    //            let index = vcArr.index(of: tmpPageName!)
    //            self.picChannelNum.selectedSegmentIndex = index!
    //        }
    //    }
    
    
    
}
