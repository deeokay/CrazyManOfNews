//
//  MiLiaoCell.swift
//  Aimi-V1.1
//
//  Created by Ivanlee on 2017/4/6.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UIKit

class MiLiaoCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
