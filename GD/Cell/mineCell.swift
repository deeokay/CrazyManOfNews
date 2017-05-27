//
//  mineCell.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/27.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
class mineCell: UITableViewCell {
    @IBOutlet var function1: UIButton!
    @IBOutlet var function2: UIButton!
    @IBOutlet var function3: UIButton!
    var function1Event = {Void()}
    var function2Event = {Void()}
    var function3Event = {Void()}

    @IBOutlet var bgView: UIView!


    @IBAction func function1Click(_ sender: Any) {
        function1Event()
    }

    @IBAction func function2Click(_ sender: Any) {
        function2Event()
    }

    @IBAction func function3Click(_ sender: Any) {
        function3Event()
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
