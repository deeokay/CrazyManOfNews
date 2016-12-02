//
//  SolvePic.swift
//  CrazyManOfNews
//
//  Created by Dee Money on 2016/11/9.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import Foundation
class SolvePic {

    class func setAnimation(imgView:UIImageView){
        let animation = CATransition.init()
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
        animation.type = kCATransitionPush  
        animation.subtype = kCATransitionPush
        imgView.layer.add(animation, forKey: "Reveal")
    }


}
