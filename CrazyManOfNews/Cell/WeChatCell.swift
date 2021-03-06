//
//  WeChatCell.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/24.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftTheme
class WeChatCell: UITableViewCell {

    @IBOutlet weak var ctime: UILabel!
    @IBOutlet var source: UILabel!
    @IBOutlet var img: UIImageView!
    @IBOutlet var Title: UILabel!
    @IBOutlet var bgView: UIView!


    var model = WeChatJXModel(){
        didSet{
            img.alpha = 0
            ctime.text = model.ctime
            source.text = model.title
            source.theme_textColor = ThemeColorPicker.init(colors: "#000","#FFF")
            bgView.theme_backgroundColor = ThemeColorPicker.init(colors: "#FFFFF0","#555555")
            do {
                let url = try URL.init(string: model.picUrl!)
                img.sd_setImage(with: url, completed: {(image,error,cacheType,url) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.img.alpha = 1
                    })
                })

            } catch let err as NSError  {
                print("出现错误!",model.title!,err)
            }

            Title.text = model.des

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
