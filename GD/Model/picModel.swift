//
//  picModel.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/13.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit

class picModel: NSObject {

    var id: String?
    var title: String?
    var img: String?{
        didSet{
            let str = NSString.init(string: img!)
            let arr = str.components(separatedBy: ".")
            if arr.last! == "gif"
            {
                self.isGif = true
            }
        }
    }
    var cache : UIImage?
    var type: Int?
    var ct: String?
    var isGif = false
    var like = 2
    

    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
