//
//  Function2.swift
//  AimiHealth
//
//  Created by apple on 2016/12/5.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit

class Function2: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.white
        self.label.backgroundColor = UIColor.white
        self.label.isOpaque = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        

        // Configure the view for the selected state
    }

}
