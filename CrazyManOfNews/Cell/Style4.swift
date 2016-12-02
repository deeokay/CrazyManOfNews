//
//  Style4.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/11/2.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit

class Style4: UITableViewCell {

    @IBOutlet var Title: UILabel!
    @IBOutlet var img1: UIImageView!
    @IBOutlet var img2: UIImageView!
    @IBOutlet var img3: UIImageView!
    @IBOutlet var subText: UILabel!
    @IBOutlet var ChannelName: UILabel!
    @IBOutlet var Date: UILabel!
    var model  =  toutiaoModel(){
        didSet{
            Title.text = model.title
            subText.text = model.desc
            ChannelName.text = model.channelName
            if model.pubDate == "null:00"{
                Date.isHidden = true
            }
            else{
                Date.text = model.pubDate
            }
            let dic1 = model.imageurls?.object(at: 0) as! NSDictionary
            let dic2 = model.imageurls?.object(at: 1) as! NSDictionary
            let dic3 = model.imageurls?.object(at: 2) as! NSDictionary
            let url1 = dic1.object(forKey: "url") as! NSString
            let url2 = dic2.object(forKey: "url") as! NSString
            let url3 = dic3.object(forKey: "url") as! NSString
            img1.sd_setImage(with: URL.init(string: url1 as String))
            img2.sd_setImage(with: URL.init(string: url2 as String))
            img3.sd_setImage(with: URL.init(string: url3 as String))


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
