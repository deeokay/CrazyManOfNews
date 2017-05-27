//
//  PayViewController.swift
//  AimiHealth
//
//  Created by apple on 2017/2/24.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class PayViewController: UIViewController {

    @IBOutlet weak var collectBtn: UIButton!
    var delegate:PicDetail?
    @IBAction func donotWatchYet(_ sender: Any) {
        self.delegate?.donotWatch()
    }
    @IBAction func collect(_ sender: Any) {
        self.delegate?.collectPic()
    }

    @IBAction func topUp(_ sender: Any) {
        self.delegate?.rechargeVIP()
    }
    @IBAction func clickADtoWatch(_ sender: Any) {
        self.delegate?.getMoreCoin()
    }
}
