//
//  HideTabbarController.swift
//  AimiHealth
//
//  Created by iMac for iOS on 2017/3/11.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class HideTabbarController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    
}
