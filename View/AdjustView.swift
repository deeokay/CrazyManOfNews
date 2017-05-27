//
//  AdjustView.swift
//  Aimi-V1.1
//
//  Created by Ivanlee on 2017/4/19.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UIKit

class AdjustView: UIView {
    
    @IBOutlet weak var progress: UISlider!
    var adjustTextSize = { Void() }
    @IBAction func changeTextSize(_ sender: UISlider) {
        adjustTextSize()
    }
    
    
    @IBAction func cancel(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) { 
            self.alpha = 0
        }
    }

}
