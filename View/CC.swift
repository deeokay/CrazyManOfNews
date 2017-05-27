//
//  CC.swift
//  AimiHealth
//
//  Created by apple on 2017/1/3.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class CC: UITableViewCell{
    
    var modelDic = NSDictionary()
    @IBOutlet weak var building: UILabel!
    @IBOutlet weak var commentContent: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var like_Count: UIButton!
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.img.layer.cornerRadius = UIwidth / 16
        self.commentContent.layer.cornerRadius = 5
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.customAction(tap:)))
        self.img.addGestureRecognizer(tap)
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(self.comment(tap:)))
        self.commentContent.addGestureRecognizer(gesture)
        self.commentContent.isUserInteractionEnabled = true
        
        // Initialization code
    }

    var  comAction:((NSDictionary) -> ())?
    func comment(tap:UITapGestureRecognizer) -> Void {
        comAction?(self.modelDic)
    }


    var clickLikeCountActtion = {Void()}
    var quickCommentAction = {Void()}

    @IBAction func clickLikeCount(_ sender: Any) {
            clickLikeCountActtion()
    }

    @IBAction func quickComment(_ sender: Any) {
            quickCommentAction()
    }
    
    var userImgClickAction = {Void()}
    func customAction(tap:UITapGestureRecognizer) -> Void {
        userImgClickAction()
    }

    var reportAction = {Void()}
    @IBAction func report(_ sender: Any) {
        reportAction()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
