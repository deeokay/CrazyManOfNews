//
//  Style1.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/11/2.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import SwiftTheme
class Style1: UITableViewCell {

    @IBOutlet var subText: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var channelName: UILabel!
    @IBOutlet var bgView: UIView!

    var model  =  toutiaoModel(){
        didSet{
            bgView.theme_backgroundColor = ThemeColorPicker.init(colors: "#F8F6F6","#B8B8B8")
            title.text = model.title
            subText.text = model.desc
            channelName.text = model.channelName
            if model.pubDate == "null:00"{
                date.isHidden = true
            }
            else{
                date.text = model.pubDate
            }
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
