//
//  ContentShieldCell.swift
//  Aimi-V1.1
//
//  Created by Ivanlee on 2017/4/7.
//  Copyright © 2017年 Cupiday. All rights reserved.
//  屏蔽内容的cell

import UIKit

class ContentShieldCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
