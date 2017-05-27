//
//  MiquanTableViewCell.swift
//  AimiHealth
//
//  Created by apple on 2016/12/9.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit
class MiquanTableViewCell: UITableViewCell {

    var isPlaying = false
    @IBOutlet weak var status: UIButton!
    var pauseAction = {Void()}
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.label.layer.masksToBounds = true
        if UIwidth <= 350.0 {
            status.imageEdgeInsets = UIEdgeInsets.init(top: 7, left: 7, bottom: 7, right: 7)
        } else if UIwidth == 375.0 {
            status.imageEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        } else if UIwidth >= 400 {
            status.imageEdgeInsets = UIEdgeInsets.init(top: 12, left: 12, bottom: 12, right: 12)
        }
    }


    @IBAction func Pause(_ sender: Any) {
        pauseAction()
    }
    
    
}
