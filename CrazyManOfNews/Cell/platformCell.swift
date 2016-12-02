//
//  platformCell.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/26.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit

class platformCell: UITableViewCell {
    var event = {Void()}
    @IBAction func switchAction(_ sender: AnyObject) {
        event()
        print("判断开关中")


    }
    @IBOutlet var platformLabel: UILabel!
    @IBOutlet var platformSwitch: UISwitch!
    var platformType = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
