//
//  NotificationViewController.swift
//  ContentEX
//
//  Created by iMac for iOS on 2017/4/19.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var img: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("触发了内容扩展组件!")
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        print("默认的扩展方法!")
        img.image = UIImage.init(data: try! Data.init(contentsOf: URL.init(string: notification.request.content.userInfo[AnyHashable("imgUrl")]! as! String)!))
        preferredContentSize = CGSize.init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5)
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {        
        switch response.actionIdentifier {
        case "act1":
            completion(UNNotificationContentExtensionResponseOption.dismissAndForwardAction)
        case "act2":
            completion(UNNotificationContentExtensionResponseOption.dismiss)
        case "act3":
            completion(UNNotificationContentExtensionResponseOption.dismiss)
        default:
            break
        }
        
    }
    
    var mediaPlayPauseButtonType: UNNotificationContentExtensionMediaPlayPauseButtonType{
        return .default
    }



}
