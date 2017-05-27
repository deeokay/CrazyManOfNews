//
//  StarMeTableViewCell.swift
//  AimiHealth
//
//  Created by IvanLee on 2017/3/9.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class StarMeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playImageView: UIImageView!
    
    var type: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        self.playImageView = self.playImageView.iv_drawCircle(with: CGSize.init(width: 30, height: 30))
        
        self.titleLabel.layer.borderColor = UIColor.lightGray.cgColor
        self.titleLabel.layer.borderWidth = 1.0
        
        self.commentLabel.layer.borderColor = UIColor.init(white: 180, alpha: 1).cgColor
        self.commentLabel.layer.borderWidth = 1.0
        self.commentLabel.backgroundColor = UIColor.init(white: 180, alpha: 1)

        self.photoImageView.image = self.photoImageView.image?.iv_changeSize(to: CGSize.init(width: 40, height: 40), origin: CGPoint.zero)
        self.articleImageView.image = self.articleImageView.image?.iv_changeSize(to: CGSize.init(width: 40, height: 40), origin: CGPoint.zero)
    }
    
    static func cellhight (content: String) -> CGFloat {

        let rect: CGRect = content.boundingRect(with: CGSize.init(width: UIwidth - 65, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17)], context: nil)
        return rect.height + 160
    }

    
}
