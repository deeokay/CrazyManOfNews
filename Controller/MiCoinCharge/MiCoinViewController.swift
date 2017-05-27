//
//  MiCoinViewController.swift
//  AimiHealth
//
//  Created by Ivanlee on 2017/3/13.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//  米币界面

import UIKit
import SwiftyJSON

class MiCoinViewController: HideTabbarController, UIScrollViewDelegate {

    @IBOutlet weak var yueLabel: UILabel!
    @IBOutlet weak var miCoinNumberlabel: UILabel!
    @IBOutlet weak var sanjiaoImageView: UIImageView!
    @IBOutlet weak var downScrollView: UIScrollView!
    // 三角的初始中心X位置
    let originalCenterX = CGFloat(96.0)
    var delegate: RechargeMiCoins?
    // 米币数量
    var miCoinNumber = 0
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("米币", comment: "")
        self.data()
        self.configScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // 使用米币
    @IBAction func useMiBi(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            
            self.downScrollView.contentOffset = CGPoint.init(x: 0, y: 0)
            self.sanjiaoImageView.center.x = self.originalCenterX
        }
    }

    // 获得米币
    @IBAction func getMiBI(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) { 
            
            self.downScrollView.contentOffset = CGPoint.init(x: UIwidth, y: 0)
            self.sanjiaoImageView.center.x = UIwidth - self.originalCenterX
        }
    }
    
    
    // MARK: - Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.sanjiaoImageView.center.x = self.downScrollView.contentOffset.x / UIwidth * (UIwidth - self.originalCenterX * 2) + self.originalCenterX
    }
    
    // MARK: - Private Method
    
    fileprivate func configScrollView() {
        self.downScrollView.frame = CGRect.init(x: 0, y: 244, width: UIwidth, height: UIheight - 423)
        self.downScrollView.contentSize = CGSize.init(width: UIwidth * 2, height: 0)
        self.downScrollView.scrollsToTop = false
        self.downScrollView.alwaysBounceHorizontal = true
        
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let useMiCoinVC = mainStoryBoard.instantiateViewController(withIdentifier: "RechargeMiCoins") as! RechargeMiCoins
        useMiCoinVC.view.frame = CGRect.init(x: UIwidth, y: 0, width: UIwidth, height: self.downScrollView.frame.size.height)
        useMiCoinVC.delegate = self
        self.addChildViewController(useMiCoinVC)
        
        let taskVC = TasksViewController()
        taskVC.view.frame = CGRect.init(x: 0, y: 0, width: UIwidth, height: self.downScrollView.frame.size.height)
        taskVC.renwuBolck = {[unowned self]() in
            AimiFunction.addMiCoin(success: { 
                self.miCoinNumber += 1
            }, fail: { 
                
            }, num: 1)
        }
        self.downScrollView.addSubview(taskVC.view)
        self.downScrollView.addSubview(useMiCoinVC.view)
        self.addChildViewController(taskVC)
    }
    
    public func data() {
        self.showHud(in: self.view)
        let dict = ["uid": UserDefaults.standard.object(forKey: "uid"),
                    "token": UserDefaults.standard.object(forKey: "token")]
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/select_integral", dic: dict as NSDictionary, success: { (data) in
            self.miCoinNumber = JSON.init(data: data)["integral"].intValue
            if UserDefaults.standard.bool(forKey: "isLogin") == false {
                self.yueLabel.text = " "
                self.miCoinNumberlabel.text = " "
            } else {
                self.miCoinNumberlabel.text = "\(self.miCoinNumber)"
            }            
            self.hideHud()
            
        }, fail: { (err) in
            self.hideHud()
            DeeShareMenu.messageFrame(msg: NSLocalizedString("请求超时!", comment: ""), view: self.view)
        }) { (pro) in
            
        }
    }
}
