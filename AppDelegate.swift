//
//  AppDelegate.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/11.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import AFNetworking
import SwiftTheme
let UIwidth = UIScreen.main.bounds.size.width
let UIheight = UIScreen.main.bounds.size.height
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
    var supportSharePlatform = NSArray.init(objects: SSDKPlatformType.typeQQ,SSDKPlatformType.subTypeQZone,SSDKPlatformType.typeMail,SSDKPlatformType.typeSinaWeibo,SSDKPlatformType.typeAliPaySocial)
    var nameArr = ["QQ","QQ空间","Email","新浪微博","支付宝"]
    var window: UIWindow?
    var appID : String?
    var secret : String?
    var dic:NSMutableDictionary?
    enum colorMode {
        case red,blue,darkGray
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print(NSHomeDirectory())
        dic =  ["showapi_appid":APPID,"showapi_sign":SECRET]
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: UNAuthorizationOptions.alert) { (bool, error) in
            //        print("Bool is \(bool), \(error)")
        }
        center.getNotificationSettings { (settings) in
            //           print(settings)
        }
        NotificationCenter.default.addObserver(self, selector:#selector(self.changeTheme(not:)) , name: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil)


        ShareSDK.registerApp("18606234031bc", activePlatforms:[
            SSDKPlatformType.typeSinaWeibo.rawValue,
            SSDKPlatformType.typeTencentWeibo.rawValue,
            SSDKPlatformType.typeWechat.rawValue,
            SSDKPlatformType.typeQQ.rawValue],
                             onImport: { (platform : SSDKPlatformType) in
                                switch platform
                                {
                                case SSDKPlatformType.typeSinaWeibo:
                                    ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
                                case SSDKPlatformType.typeWechat:
                                    ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                                case SSDKPlatformType.typeQQ:
                                    ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
                                default:
                                    break
                                }

        }) { (platform : SSDKPlatformType, appInfo : NSMutableDictionary?) in

            switch platform
            {
            case SSDKPlatformType.typeSinaWeibo:
                appInfo?.ssdkSetupSinaWeibo(byAppKey: "938586463",
                                            appSecret : "457cd5fdce9efe88ee7e8552c01b7492",
                                            redirectUri : "http://sns.whalecloud.com/sina2/callback",
                                            authType : SSDKAuthTypeBoth)

            case SSDKPlatformType.typeWechat:
                appInfo?.ssdkSetupWeChat(byAppId: "wx4868b35061f87885", appSecret: "64020361b8ec4c99936c0e3999a9f249")

            case SSDKPlatformType.typeTencentWeibo:
                appInfo?.ssdkSetupTencentWeibo(byAppKey: "801307650",
                                               appSecret : "ae36f4ee3946e1cbb98d6965b0b2ff5c",
                                               redirectUri : "http://www.sharesdk.cn")
            case SSDKPlatformType.typeQQ:
                appInfo?.ssdkSetupQQ(byAppId: "1105779622",
                                     appKey : "ZkM2Eum8aCsmaCGp",
                                     authType : SSDKAuthTypeWeb)
            default:
                break
            }
            AFNetworkReachabilityManager.shared().setReachabilityStatusChange({ (status) in
                print("NOW NETWORK STATUS IS\(status)")
            })
        }

        var message = "欢迎新用户!愿您浏览愉快!"
        if(!UserDefaults.standard.bool(forKey: everLaunched)){
            UserDefaults.standard.set(true, forKey: everLaunched)
            UserDefaults.standard.set(true, forKey: firstLaunch)
            UserDefaults.standard.set(true, forKey: shankeShare)//摇一摇分享
            UserDefaults.standard.set(false, forKey: nightMode)//夜间模式
            UserDefaults.standard.set(false, forKey: saveMode)//省流量模式
            UserDefaults.standard.set(0, forKey: currentPlatform)//分享平台
            UserDefaults.standard.synchronize()
        }
        else{
            UserDefaults.standard.set(false, forKey: firstLaunch)
            UserDefaults.standard.synchronize()
            if UserDefaults.standard.bool(forKey: nightMode){
                ThemeManager.setTheme(index: 1)
            }
            else{
                ThemeManager.setTheme(index: 0)
            }
            message = "继续你的浏览之旅吧!"
            print("读取用户偏好")
        }
        setTheme()
        DeeShareMenu.messageFrame(msg: message, controller: (window?.rootViewController)!)
        return true
    }

    func changeTheme(not:NSNotification) -> Void {
        DeeShareMenu.messageFrame(msg: "切换主题成功!", controller: (window?.rootViewController)!)
    }

    func setTheme() -> Void {
        _ = UINavigationBar.appearance().theme_barTintColor = ThemeColorPicker(colors: "#FF0000","#555550")
        _ = UINavigationBar.appearance().theme_tintColor = ThemeColorPicker(colors: "#000000","#FFFFF5")
        _ = UITableView.appearance().theme_backgroundColor = ThemeColorPicker(colors: "#FCFFF4","#999999")
        _ = UIWebView.appearance().theme_backgroundColor = ThemeColorPicker(colors: "#FFFFF5    ","#555550")
        _ = UITabBar.appearance().theme_barTintColor = ThemeColorPicker(colors: "#FF0000","#555550")
        _ = UITableViewCell.appearance().theme_backgroundColor = ThemeColorPicker(colors: "#FFF", "#999999")
        _ = UISegmentedControl.appearance().theme_tintColor = ThemeColorPicker(colors: "#FF0000", "#B8B8B8")
        _ = UISegmentedControl.appearance().theme_backgroundColor = ThemeColorPicker(colors: "#FFFFF5", "#686868")
        _ = UIToolbar.appearance().theme_barTintColor = ThemeColorPicker(colors: "#FF0000","#555550")
 

    }




    //    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    //        print("回调1:",TencentOAuth.handleOpen(url))
    //        //        return TencentOAuth.handleOpen(url)
    //        return true
    //    }
    //
    //    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
    //        print("回调2:",TencentOAuth.handleOpen(url))
    //        //        return TencentOAuth.handleOpen(url)
    //        return true
    //
    //    }


    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CrazyManOfNews")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

