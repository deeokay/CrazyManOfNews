//
//  MiQuanCell.swift
//  AimiHealth
//
//  Created by ivan on 17/2/28.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class MiQuanCell: UITableViewCell {

    @IBOutlet weak var collectionImageView: UIImageView!
    @IBOutlet weak var collectTitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
