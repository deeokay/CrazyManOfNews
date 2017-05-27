//
//  PicDetailCell.swift
//  AimiHealth
//
//  Created by apple on 2016/12/10.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit

class PicDetailCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var scView: UIScrollView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    var scale = CGFloat()

}
