//
//  WeChatCell.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/24.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import SDWebImage
class WeChatCell: UITableViewCell {

    @IBOutlet var source: UILabel!
    @IBOutlet var img: UIImageView!
    @IBOutlet var Title: UILabel!


    var model = WeChatJXModel(){
        didSet{
            source.text = model.source

            do {
                let url = try URL.init(string: model.firstImg!)
                img.sd_setImage(with: url)
            } catch   {
                print("出现错误!",model.title!)
            }

            Title.text = model.title

        }

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
