//
//  preferencesCell.swift
//  CrazyManOfNews
//
//  Created by Dee Money on 2016/11/8.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit

class preferencesCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet var `switch`: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var event = {Void()}
    @IBAction func statusChange(_ sender: Any) {
        event()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
