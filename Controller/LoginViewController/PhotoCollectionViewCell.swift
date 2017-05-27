//
//  PhotoCollectionViewCell.swift
//  AimiHealth
//
//  Created by ivan on 17/2/27.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var gouXuanView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        let length = UIScreen.main.bounds.size.width / 4 - 14
        self.contentView.layer.cornerRadius = length / 2
        self.contentView.layer.masksToBounds = true
        self.contentView.addSubview(photoView)
        self.contentView.addSubview(gouXuanView)
    }

}
