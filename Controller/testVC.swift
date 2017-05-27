//
//  testVC.swift
//  AimiHealth
//
//  Created by iMac for iOS on 2017/3/25.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class testVC: UIViewController,GDTSplashAdDelegate {
    var Splash = GDTSplashAd()
    override func viewDidLoad() {
        super.viewDidLoad()
        Splash = GDTSplashAd.init(appkey: "1105344611", placementId: "9040714184494018")
        Splash.delegate = self
        Splash.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "flash")!)
        Splash.fetchDelay = 1
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func f1(_ sender: Any) {
        Splash.loadAndShow(in: self.view.window)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
