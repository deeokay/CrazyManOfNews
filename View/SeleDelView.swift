//
//  SeleDelView.swift
//  Aimi-V1.1
//
//  Created by Ivanlee on 2017/4/10.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UIKit

class SeleDelView: UIView {

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var checkBoxImageView: UIImageView!
    
    var selectHandle = { Void() }
    var deleteHandle = { Void() }
   
    @IBAction func selectAction(_ sender: UIButton) {
        self.selectButton.isSelected = !self.selectButton.isSelected
        if self.selectButton.isSelected == false {
            self.checkBoxImageView.image = UIImage.init(named: "用户协议2")
        } else {
            self.checkBoxImageView.image = UIImage.init(named: "用户协议1")
        }
        selectHandle()
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        self.selectButton.isEnabled = false
        self.selectButton.isSelected = false
        self.deleteButton.isEnabled = false
        deleteHandle()
    }
    
}
