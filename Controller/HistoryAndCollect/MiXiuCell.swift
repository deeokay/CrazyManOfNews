//
//  MiXiuCell.swift
//  AimiHealth
//
//  Created by ivan on 17/3/1.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class MiXiuCell: UICollectionViewCell {
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!

    var willBeDeleted: Bool = false
    var startSelected: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = UIColor.lightGray
        self.layer.cornerRadius = 10
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        
        playImageView.layer.cornerRadius = 20
        playImageView.layer.masksToBounds = true
        playImageView.layer.borderColor = UIColor.clear.cgColor
        
        mainImageView.layer.cornerRadius = 10
        mainImageView.layer.masksToBounds = true
        
        titleLabel.backgroundColor = UIColor(white: 0,alpha: 0.5)
        titleLabel.textColor = UIColor.white
        
        selectedImageView.layer.cornerRadius = 15
        selectedImageView.layer.masksToBounds = true
        selectedImageView.layer.borderColor = UIColor.clear.cgColor
        
        if startSelected == false {
            selectedImageView.isHidden = true
        } else {
            selectedImageView.isHidden = false
        }
        
        if willBeDeleted == false {
            selectedImageView.image = UIImage(named: "未选中")
        } else {
            selectedImageView.image = UIImage(named: "icon-20")
        }
    }

}
