//
//  TopUpMicoinsCell.swift
//  AimiHealth
//
//  Created by apple on 2017/2/27.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class TopUpMicoinsCell: UITableViewCell {
    @IBOutlet weak var amountBtn: UIButton!
    @IBOutlet weak var miCoinCount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.amountBtn.layer.cornerRadius = 5
        self.amountBtn.layer.borderWidth = 1
        self.amountBtn.layer.borderColor = UIColor.blue.cgColor
        // Initialization code
    }
    var amountAction = {Void()}


    @IBAction func amountClick(_ sender: Any) {
        amountAction()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
