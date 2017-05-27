//
//  BottomView.swift
//  Aimi-V1.1
//
//  Created by Ivanlee on 2017/4/18.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UIKit

class BottomView: UIView {
    
    
    @IBOutlet weak var writeCommentBtn: UIButton!
    @IBOutlet weak var collectBtn: UIButton!

    var showCommentView = { Void() }
    @IBAction func showCommentView(_ sender: UIButton) {
        showCommentView()
    }

    var jumpToCommentArea = { Void() }
    @IBAction func jumpToCommentArea(_ sender: UIButton) {
        jumpToCommentArea()
    }
    
    var collectBtnClick = { Void() }
    @IBAction func collectBtnClick(_ sender: UIButton) {
        collectBtnClick()
    }
  
    var shareBtnClick = { Void() }
    @IBAction func shareBtnClick(_ sender: UIButton) {
        shareBtnClick()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        writeCommentBtn.layer.borderColor = UIColor.lightGray.cgColor
    }
    
}
