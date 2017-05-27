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

    @IBOutlet weak var num: UILabel!
    @IBOutlet var bgView: UIView!
    @IBOutlet var title: UILabel!
    @IBOutlet var img: UIImageView!
    var model = picModel(){
        didSet{
//            self.img.alpha = 0
            self.title.text = self.model.title!
            var data = NSData()
            if model.isGif && UserDefaults.standard.bool(forKey: "saveMode"){
                self.img.image = UIImage.init(named: "BS")
//                UIView.animate(withDuration: 0.5, animations: { 
//                    self.img.alpha = 1
//                })
            }
            else{
                SDWebImageManager.shared().cachedImageExists(for: URL.init(string: model.img!), completion: { bool in
                    if bool == true {
                        let cacheKey = SDWebImageManager.shared().cacheKey(for: URL.init(string: self.model.img!))
                        if ((cacheKey?.lengthOfBytes(using: String.Encoding.unicode)) != nil) {
                            let cachePath = SDImageCache.shared().defaultCachePath(forKey: cacheKey)
                            if ((cachePath?.lengthOfBytes(using: String.Encoding.unicode)) != nil){
                                do {
                                    try data = NSData.init(contentsOfFile: cachePath!)
                                    self.img.image = UIImage.init(data: data as Data)
//                                    UIView.animate(withDuration: 0.5, animations: {
//                                        self.img.alpha = 1
//                                    })
                                } catch  {
                                    print("缓存被删除,重新加载 !")
                                    self.img.sd_setImage(with: URL.init(string: self.model.img!), completed: { (image, error, type, url) in
//                                        UIView.animate(withDuration: 0.5, animations: {
//                                            self.img.alpha = 1
//                                        })
                                    })
                                }
                            }
                        }
                    }
                    else{
                        self.img.sd_setImage(with: URL.init(string: self.model.img!), completed: { (image, error, type, url) in
//                            UIView.animate(withDuration: 0.5, animations: {
//                                self.img.alpha = 1
//                            })
                        })
                    }
                })
            }
        }
    }
}
