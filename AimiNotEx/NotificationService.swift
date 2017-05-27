//
//  NotificationService.swift
//  AimiNotEx
//
//  Created by iMac for iOS on 2017/4/19.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title)"
            
            let fileManager = FileManager.default
            let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
            let dest = path?.appending("/\(Date.init(timeIntervalSinceNow: 1)).jpg")
            let url = URL.init(string: request.content.userInfo[AnyHashable("imgUrl")] as! String)
            
            let task = URLSession.shared.downloadTask(with: URLRequest.init(url: url!), completionHandler: { (location, res, error) in
                if error == nil {
                    do {
                        try fileManager.moveItem(atPath: (location?.path)!, toPath: dest!)
                        if let att = try? UNNotificationAttachment.init(identifier: "photo", url:URL.init(fileURLWithPath: dest!), options: nil){
                            self.bestAttemptContent?.attachments = [att]
                            print("有效的附件!")
                        }
                        else{
                            print("无效的附件!")
                        }
                        print("保存附件成功!")
                        contentHandler(bestAttemptContent)
                    } catch _ {
                        print("保存附件时出现错误!")
                        contentHandler(bestAttemptContent)

                    }

                }
            })
            task.resume()
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
