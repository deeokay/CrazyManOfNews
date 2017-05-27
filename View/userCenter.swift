//
//  userCenter.swift
//  AimiHealth
//
//  Created by apple on 2016/12/27.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit

class userCenter: UITableViewCell {


    @IBOutlet weak var VIPButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var gender: UIImageView!
    @IBOutlet weak var bgImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.layer.masksToBounds = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(touXIangImage))
        userImage.addGestureRecognizer(tap)
        userImage.isUserInteractionEnabled = true
        bgImage.image = UIImage.init(named: "banner")
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var touXiang = {Void()}
    func touXIangImage() {
        touXiang()
    }
    
    var vipAction = {Void()}
    var topUpAction = {Void()}
    @IBAction func top_Up(_ sender: Any) {
        topUpAction()
    }
    @IBAction func vipAction(_ sender: Any) {
        vipAction()
    }
}
