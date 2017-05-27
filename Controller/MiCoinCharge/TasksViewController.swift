//
//  TasksViewController.swift
//  AimiHealth
//
//  Created by Ivanlee on 2017/3/14.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class TasksViewController: HideTabbarController, GDTMobBannerViewDelegate {

    let titleLB = UILabel()
    let messageLB = UILabel()
    let scaleLB = UILabel()
    let numberLB = UILabel()
    
    var renwuBolck = { () in
        
    }
    
    @IBOutlet weak var adView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTopView()
        self.configADs()
    }
    
    func setTopView() {
        
        let title = UILabel.init(frame: CGRect.init(x: 20, y: 15, width: UIwidth - 10, height: 20))
        title.text = NSLocalizedString("完成任务", comment: "")
        self.view.addSubview(title)
        
        let message = UILabel.init(frame: CGRect.init(x: 20, y: 50, width: UIwidth - 10, height: 200))
        message.numberOfLines = 12
        message.text = NSLocalizedString("1.每日登陆即可获得1米币奖励\n\n2.每天第一次分享爱米内的任意内容立即获得1米币\n\n3.点击除图片内容外的广告均可获得相应米币奖励", comment: "")
        message.textColor = UIColor.gray
        message.font = UIFont.systemFont(ofSize: 15)
        self.view.addSubview(message)
    }
    
    func configADs() {
        
        let banner = GDTMobBannerView.init(frame: CGRect.init(x: 0, y: 60, width: UIwidth, height: 50), appkey: "1105939483", placementId: "9050028032736604")
        banner?.delegate = self
        banner?.backgroundColor = UIColor.red
        banner?.interval = 10
        banner?.currentViewController = self
        banner?.isAnimationOn = false
        banner?.showCloseBtn = false
        self.adView.addSubview(banner!)
        banner?.loadAdAndShow()
    }
    
    
    func bannerViewClicked() {
        print("点击了banner条")
        AimiFunction.addMiCoin(success: {
            
            self.renwuBolck()
            
            DeeShareMenu.messageFrame(msg: NSLocalizedString("感谢支持！当前米币+1", comment: ""), view: self.view)
        }, fail: {
            DeeShareMenu.messageFrame(msg: NSLocalizedString("增加米币失败，请稍后再试！", comment: ""), view: self.view)
        }, num: 1)
    }

}
