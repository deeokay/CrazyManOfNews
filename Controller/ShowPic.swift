//
//  ShowPic.swift
//  AimiHealth
//
//  Created by apple on 2016/12/9.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit

class ShowPic: UICollectionViewCell {

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var userNickname: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var playBtn: UIImageView!
    
    override func awakeFromNib() {
        self.playBtn.layer.borderColor = UIColor.darkGray.cgColor
        self.userNickname.layer.masksToBounds = true
        self.isOpaque = true
    }

}
