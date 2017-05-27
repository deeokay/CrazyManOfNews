//
//  LeftCell.swift
//  Aimi-V1.1
//
//  Created by iMac for iOS on 2017/3/30.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UIKit

class LeftCell: UITableViewCell {
    
    @IBOutlet weak var sex: UIImageView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var creatTime: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var building: UILabel!
    
    var likeAction = {Void()}
    var reportAction = {Void()}
    var replyAction = {Void()}
    @IBAction func ReportClick(_ sender: UIButton) {
        reportAction()
    }
    override func awakeFromNib() {
        self.avatar.layer.cornerRadius = UIwidth * 0.075
    }
    @IBAction func ReplyClick(_ sender: UIButton) {
        replyAction()
    }
    
    @IBAction func LikeClick(_ sender: UIButton) {
        likeAction()
    }
}
