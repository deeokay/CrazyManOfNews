//
//  PageModel.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/12.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit

class PageModel: NSObject {

    var channelId : String?
    var name : String?{
        didSet{
            var str = NSString.init(string: name!)
            if str.length >= 6{
               str = str.substring(to: 4) as NSString
            }
            name = str as String
        }
    }
}
