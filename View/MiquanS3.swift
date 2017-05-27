//
//  MiquanS3.swift
//  AimiHealth
//
//  Created by iMac for iOS on 2017/3/22.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class MiquanS3: UITableViewCell {

    
    @IBOutlet weak var typeName: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var writter: UILabel!
    @IBOutlet weak var publishTime: UILabel!
    @IBOutlet weak var status: UIButton!
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var pauseAction = {Void()}
    @IBAction func pause(_ sender: Any) {
        pauseAction()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
