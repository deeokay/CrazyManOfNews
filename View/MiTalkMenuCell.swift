//
//  MiTalkMenuCell.swift
//  Aimi-V1.1
//
//  Created by iMac for iOS on 2017/3/29.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UIKit

class MiTalkMenuCell: UITableViewCell {

    var collectAction = {Void()}
    var shareAction = {Void()}
    var moreAction = {Void()}
    var didCollect = false
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var collectBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func collectClick(_ sender: UIButton) {
        collectAction()
    }

    @IBAction func shareClick(_ sender: UIButton) {
        shareAction()
    }
    
    @IBAction func moreClick(_ sender: UIButton) {
        moreAction()
    }
    
}
