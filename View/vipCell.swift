//
//  vipCell.swift
//  AimiHealth
//
//  Created by apple on 2017/2/23.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class vipCell: UITableViewCell {

    @IBOutlet weak var enjoyDays: UILabel!
    @IBOutlet weak var vipLevel: UILabel!
    @IBOutlet weak var topUpVipBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.topUpVipBtn.layer.cornerRadius = 5
        self.topUpVipBtn.layer.borderWidth = 1
        self.topUpVipBtn.layer.borderColor = UIColor.white.cgColor
        // Initialization code
    }

    var topUpVipAction = {Void()}
    @IBAction func topUpVipClick(_ sender: Any) {
        topUpVipAction()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
