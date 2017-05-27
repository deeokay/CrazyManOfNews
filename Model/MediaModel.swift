//
//  MediaModel.swift
//  AimiHealth
//
//  Created by apple on 2017/1/9.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
@objc(DeeMedia)
class DeeMedia:NSObject{
    var isLoaded = false
    var vid = Int()
    var iid = Int()
    var title = String()
    var descrip = String()
    var price = Int()
    var imgUrl = String()
    var aid = Int()
    var avatar = String()
    var username = String()
    var publishtime = NSMutableString()
    var sex = Int()
    var uid = Int()
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
    }
}

class ArticleModel: DeeMedia {
    var article_type = Int()
    var audioUrl = String()
    var link = String()
    var bgAvatar = String()
    var bgUrl = String()
    var writer = String()
    var isLoad = false
    var isPlaying = false
}
class PictureModel: DeeMedia {
    var url = NSMutableArray()
}

class VideoModel: DeeMedia {
    var url = String()
}

class MiTalkModel: DeeMedia {
    var fid = Int()
    var content = String()
}

class CommentModel : NSObject{
    var avatar = String()
    var cid = Int()
    var sex = Int()
    var content = String()
    var create_time = String()
    var hot = Int()
    var reply = NSArray()
    var uid = Int()
    var username = String()
    var zan = Int()
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}



