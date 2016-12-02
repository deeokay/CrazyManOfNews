//
//  ChannelCell.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/13.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import SwiftTheme
class ChannelCell: UITableViewCell {

    @IBOutlet var channel: UIButton!
    var event = { Void()}
    @IBAction func channelBtn(_ sender: AnyObject) {
        event()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
