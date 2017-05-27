//
//  UIView+Extension.swift
//  AimiHealth
//
//  Created by Ivanlee on 2017/3/24.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    // 图片切圆角
    func iv_drawRectWithRoundedCorner(radius: CGFloat, size: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        UIGraphicsGetCurrentContext()!.addPath(UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners,
                                      cornerRadii: CGSize(width: radius, height: radius)).cgPath)
        UIGraphicsGetCurrentContext()?.clip()
        self.draw(in: rect)
        UIGraphicsGetCurrentContext()!.drawPath(using: .fillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();        
        return output!
    }
    
    // 改变图片大小
    func iv_changeSize(to size: CGSize, origin: CGPoint) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        var image = self
        image.draw(in: CGRect(origin: origin, size: size))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
}

extension UIImageView {
    // 贝赛尔曲线画圆
    func iv_drawCircle(with size: CGSize) -> UIImageView {
        let imageview = self
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        let path = UIBezierPath(ovalIn: imageview.bounds)
        path.addClip()
        imageview.draw(imageview.bounds)
        imageview.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageview
    }
}
