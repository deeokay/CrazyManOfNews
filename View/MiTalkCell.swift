//
//  MiTalkCell.swift
//  Aimi-V1.1
//
//  Created by iMac for iOS on 2017/3/29.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UIKit

class MiTalkCell: UITableViewCell {
    
    @IBOutlet weak var sex: UIImageView!
    @IBOutlet weak var creat_time: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var username: UILabel!

    var model = MiTalkModel(){
        didSet{
            self.creat_time.text = model.publishtime as String
            self.avatar.kf.setImage(with: URL.init(string: model.avatar))
            self.content.text = model.content
            self.username.text = model.username
            if model.sex == 1{
                sex.image = UIImage.init(named: "male")
            }
            else{
                sex.image = UIImage.init(named: "lady")
            }
        }
    }
    
    override func awakeFromNib() {
        self.avatar.layer.cornerRadius = UIwidth * 0.075
    }
}
