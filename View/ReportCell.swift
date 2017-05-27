//
//  ReportCell.swift
//  AimiHealth
//
//  Created by apple on 2017/3/10.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class ReportCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var checked: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
