//
//  collectNewsCell.swift
//  CrazyManOfNews
//
//  Created by Dee Money on 2016/11/8.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit

class collectNewsCell: UITableViewCell {

    @IBOutlet var date: UILabel!
    @IBOutlet var sourceName: UILabel!
    @IBOutlet var label: UILabel!
    @IBOutlet var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
