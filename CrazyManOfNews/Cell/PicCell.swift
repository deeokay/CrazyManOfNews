//
//  PicCell.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/13.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import UIImage_animatedGif
import SDWebImage
class PicCell: UICollectionViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var img: UIImageView!
    var model = picModel(){
        didSet{
            self.title.text = self.model.title!
            var data = NSData()
            SDWebImageManager.shared().cachedImageExists(for: URL.init(string: model.img!), completion: { bool in
                if bool == true {
                    print("存在缓存")
                    let cacheKey = SDWebImageManager.shared().cacheKey(for: URL.init(string: self.model.img!))
                    if ((cacheKey?.lengthOfBytes(using: String.Encoding.unicode)) != nil) {
                        let cachePath = SDImageCache.shared().defaultCachePath(forKey: cacheKey)
                        if ((cachePath?.lengthOfBytes(using: String.Encoding.unicode)) != nil){
                            do {
                                try data = NSData.init(contentsOfFile: cachePath!)
                                self.img.image = UIImage.init(data: data as Data)
                            } catch  {
                                print("未知错误 !")
                            }
                        }
                    }
                }
                else{
                    print("不存在缓存")
                    self.img.sd_setImage(with: URL.init(string: self.model.img!), completed: { (image, error, type, url) in
                    })
                }
            })
        }
    }
}
