
//
//  AppDelegate.swift
//  AimiHealth
//
//  Created by apple on 2016/12/5.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit
import CoreData
import AFNetworking
import MMPopupView
import UserNotifications
import AVFoundation
let UIwidth = UIScreen.main.bounds.size.width
let UIheight = UIScreen.main.bounds.size.height
class JPush_APNS: NSObject {
    var title = ""
    var badge = Int()
    var subtitle = ""
    var extras = NSDictionary()
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GDTSplashAdDelegate,JPUSHRegisterDelegate,UNUserNotificationCenterDelegate,SKStoreProductViewControllerDelegate{
        var window: UIWindow?
    var bottomView = UIView()
    //    var currentUnityController: UnityAppController!
    var Splash = GDTSplashAd()
    func splashAdClosed(_ splashAd: GDTSplashAd!) {
        self.Splash.delegate = nil
    }
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    var isLoad = false
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //            Splash = GDTSplashAd.init(appkey: "1105344611", placementId: "9040714184494018")
        //            Splash.delegate = self
        //            Splash.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "launcher.jpg")!)
        //            Splash.fetchDelay = 3
        //            Splash.loadAndShow(in: window)
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
        } catch _ {
            
        }
        
        
        
        
        JPUSHService.resetBadge()
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        if !isLoad{
            window = UIWindow.init(frame: UIScreen.main.bounds)
            window?.backgroundColor = UIColor.white
            let story = UIStoryboard.init(name: "Main", bundle: nil)
            vc = story.instantiateViewController(withIdentifier: "tabbar") as! Tabbar
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
            isLoad = true
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let options = UNAuthorizationOptions.init(rawValue: 3|1|2)
            let act1 = UNNotificationAction.init(identifier: "act1", title: "进入详情", options: .foreground)
            //            let act2 = UNNotificationAction.init(identifier: "act2", title: "先收藏", options: .destructive)
            let act3 = UNNotificationAction.init(identifier: "act3", title: "不爱这个", options: .destructive)
            let cate = UNNotificationCategory.init(identifier: "photo", actions: [act1,act3], intentIdentifiers: ["photoAct"], options: .customDismissAction)
            UNUserNotificationCenter.current().setNotificationCategories([cate])
            UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: { (b, err) in
                if b {
                    print("授权通知成功!")
                }
                else{
                    print("授权通知失败!")
                }
            })
        } else {
            let act1 = UIMutableUserNotificationAction.init()
            act1.activationMode = .foreground
            act1.title = "朕要开车"
            act1.identifier = "act1"
            act1.isDestructive = true
            act1.isAuthenticationRequired = false
            
            let cate = UIMutableUserNotificationCategory.init()
            cate.identifier = "photo"
            cate.setActions([act1], for: UIUserNotificationActionContext.default)
            
            let setting = UIUserNotificationSettings.init(types: UIUserNotificationType.init(rawValue: 0|1|2), categories: [cate])
            application.registerUserNotificationSettings(setting)
        }
        
        application.registerForRemoteNotifications()
        
        
        if #available(iOS 10.0, *){
            let entiity = JPUSHRegisterEntity()
            JPUSHService.register(forRemoteNotificationConfig: entiity, delegate: self)
        } else if #available(iOS 8.0, *) {
            let types = UIUserNotificationType.badge.rawValue |
                UIUserNotificationType.sound.rawValue |
                UIUserNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: types, categories: nil)
        }else {
            let type = UIRemoteNotificationType.badge.rawValue |
                UIRemoteNotificationType.sound.rawValue |
                UIRemoteNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: type, categories: nil)
        }
        JPUSHService.setup(withOption: launchOptions, appKey: "18e12b98a497b3ed49d09461", channel: "App Store", apsForProduction: true, advertisingIdentifier: AimiFunction.getUniqueDeviceIdentifierAsString())
        JPUSHService.registrationIDCompletionHandler { (num, str) in
            print("注册成功!",num,str ?? "登录UUID")
        }
        
        _ = AimiData.CreatCoredata()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.jpfNetworkDidReceiveMessage, object: nil, queue: OperationQueue.main) { (not) in
            print("收到推送自定义的内容")
            let model = JPush_APNS()
            model.mj_setKeyValues(not.userInfo)
            JPUSHService.setBadge(UIApplication.shared.applicationIconBadgeNumber + model.badge)
            if #available(iOS 10.0, *){
                
//                let content = UNMutableNotificationContent.init()
//                content.body = "点击查看详情吧!"
//                content.badge = 1
//                content.launchImageName = "logo"
//                content.sound = UNNotificationSound.default()
//                content.title = (ex.object(forKey: "title") as? String) ?? "小爱"
//                content.subtitle = (ex.object(forKey: "subtitle") as? String) ?? "听说你在找我?"
//                content.categoryIdentifier = "myNotificationCategory"
//                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
//                let url = URL.init(fileURLWithPath: Bundle.main.path(forResource: "launcher", ofType: "jpg")!)
//                if let att = try? UNNotificationAttachment.init(identifier: "no", url:url, options: nil){
//                    content.attachments = [att]
//                }
//                
//                let reqeust = UNNotificationRequest.init(identifier: "none", content: content, trigger: trigger)
//                
//                UNUserNotificationCenter.current().add(reqeust, withCompletionHandler: { (err) in
//                    guard err == nil else{
//                        return
//                    }
//                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["none"])
//                })
//            }
//            else{
//                let content = UILocalNotification.init()
//                content.alertBody = "Body"
//                if #available(iOS 8.2, *) {
//                    content.alertTitle = "Title"
//                }
//                content.fireDate = Date.init(timeIntervalSinceNow: 5)
//                content.alertLaunchImage = "logo"
//                content.soundName = UILocalNotificationDefaultSoundName
//                content.applicationIconBadgeNumber = 1
//                application.scheduleLocalNotification(content)
//            }
                
                
            
            }
        }
        
        
        //        defer {
        //            currentUnityController = UnityAppController()
        //            self.currentUnityController.application(application, didFinishLaunchingWithOptions: launchOptions)
        //        }
        
        
        print(NSHomeDirectory())
        let manager = FileManager.default
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
        let creatPath = path?.appending("/Cupiday.AimiHealth/video")
        if !manager.fileExists(atPath: creatPath!){
            do {
                try manager.createDirectory(atPath: creatPath!, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
                print("创建文件夹失败!")
            }
        }
        else{
            print("Video已存在!")
        }
        
        
        
        TalkingData.sessionStarted("02C91981C9B64B45A323B74EBCE1DD06", withChannelId: "AppStore")
        Bugly.start(withAppId: "8ee85fc458")
        WXApi.registerApp("wxb4ba3c02aa476ea1", enableMTA: true)

        
        
        ShareSDK.registerApp("18606234031bc", activePlatforms:[SSDKPlatformType.typeSinaWeibo.rawValue,SSDKPlatformType.typeTencentWeibo.rawValue,SSDKPlatformType.typeWechat.rawValue,SSDKPlatformType.typeQQ.rawValue,SSDKPlatformType.typeMail.rawValue,SSDKPlatformType.typeFacebookMessenger.rawValue,SSDKPlatformType.typeFacebook.rawValue,SSDKPlatformType.typeInstagram.rawValue,SSDKPlatformType.typeTwitter.rawValue],onImport: { (platform : SSDKPlatformType) in
            switch platform
            {
            case SSDKPlatformType.typeSinaWeibo:
                ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
            case SSDKPlatformType.typeWechat:
                ShareSDKConnector.connectWeChat(WXApi.classForCoder())
            case SSDKPlatformType.typeQQ:
                ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
            case SSDKPlatformType.typeTencentWeibo:
                ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
            default:
                break
            }
            
        }) { (platform : SSDKPlatformType, appInfo : NSMutableDictionary?) in
            switch platform
            {
            case SSDKPlatformType.typeSinaWeibo:
                appInfo?.ssdkSetupSinaWeibo(byAppKey: "638726916",appSecret : "eb12a36e425efa8c8164f838e13062f5",redirectUri : "http://sns.whalecloud.com/sina2/callback",authType : SSDKAuthTypeBoth)
            case SSDKPlatformType.typeFacebookMessenger:
                print("注册FacebookMessenger")
//                appInfo?.ssdkSetupFacebook(byApiKey: "939657869470820", appSecret: nil, displayName: "shareSDK", authType: SSDKAuthTypeBoth)
//            case SSDKPlatformType.typeFacebook:
//                appInfo?.ssdkSetupFacebook(byApiKey: "939657869470820", appSecret: "2e930021e7e13b185e1fec1f2c767b7d", displayName: "shareSDK", authType: SSDKAuthTypeBoth)
//                appInfo?.ssdkSetupFacebook(byApiKey: "939657869470820", appSecret: nil, displayName: "shareSDK", authType: SSDKAuthTypeBoth)
            case SSDKPlatformType.typeWechat:
                appInfo?.ssdkSetupWeChat(byAppId: "wxbdd96ebb928ab5dc", appSecret: "f0e0edac6bcec8dbbf4a056364866535")
            case SSDKPlatformType.typeQQ:
                appInfo?.ssdkSetupQQ(byAppId: "1105939591",appKey : "6Fec5fiGO0Au9ioN",authType : SSDKAuthTypeWeb)
            case SSDKPlatformType.typeInstagram:
                appInfo?.ssdkSetupInstagram(byClientID: "f14b70b696114c1c8d2a3f0ac9eb8252", clientSecret: "5a7f9a58ae7d4894bfa024cd6b475a98", redirectUri: "http://sharesdk.cn")
            case SSDKPlatformType.typeTwitter:
                appInfo?.ssdkSetupTwitter(byConsumerKey: "KMWUB1xoVxk7ER76ZvlEImTeZ", consumerSecret: "D3Y26w5naxnYIZwLDoC7QTeutdkUlRp7o25J4hPW4C6AJfhlgl", redirectUri: "http://mob.com")
                
            default:
                break
            }
        }
        
        
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange({ (status) in
            print("NOW NETWORK STATUS IS\(status)")
        })
        
        
        
        
             _ = AimiData.CreatCoredata()
        if let version = UserDefaults.standard.value(forKey: "version") as? String{
            print("当前版本号是")
            if AISubMIversion != version{
                print("这是新版本,需要初始化!")
                self.initailizeUserdefault()
                UserDefaults.standard.set(AISubMIversion, forKey: "version")

            }
            else{
                print("当前是最新版本!")
            }
        }
        else{
            print("没有设置版本号,生成版本号!需要初始化!")
            UserDefaults.standard.set(AISubMIversion, forKey: "version")
            self.initailizeUserdefault()
        }
        UserDefaults.standard.synchronize()

        if(!UserDefaults.standard.bool(forKey: everLaunched)){
            self.initailizeUserdefault()
        }
        else{
            let date = Date.init()
            let formater = DateFormatter.init()
            formater.dateFormat = "yyyyMMdd"
            let today = formater.string(from: date)
            if (today != UserDefaults.standard.object(forKey: "ShareDate") as! String){
                UserDefaults.standard.set(false, forKey: "everyFirstShareReward")
            }
            if (today != UserDefaults.standard.object(forKey: "LoginDate") as! String){
                UserDefaults.standard.set(false, forKey: "everyFirstLoginReward")
            }
            if (date.description as NSString).substring(to: 10) != UserDefaults.standard.object(forKey: "morningDate") as! String{
                UserDefaults.standard.set(false, forKey: "morning")
            }

        }


        
        UserDefaults.standard.synchronize()
        return true
    }
    
    func initailizeUserdefault(){
        let guideDic:[String:Bool] = ["米圈引导":true,"收藏引导":true,"图片引导":true,"字体大小":true]
        UserDefaults.standard.set(guideDic, forKey: "guide")
        UserDefaults.standard.set(true, forKey: everLaunched)
        UserDefaults.standard.set(0, forKey: "uid")
        UserDefaults.standard.set(true, forKey: firstLaunch)
        UserDefaults.standard.set(false, forKey: shankeShare)//摇一摇分享
        UserDefaults.standard.set(false, forKey: nightMode)//夜间模式
        UserDefaults.standard.set(false, forKey: saveMode)//省流量模式
        UserDefaults.standard.set(0, forKey: currentPlatform)//分享平台
        UserDefaults.standard.set(NSArray(), forKey: cacheNews)
        UserDefaults.standard.set(NSArray(), forKey: cacheMitalk)
        UserDefaults.standard.set(NSArray(), forKey: MishowCache_pictures)
        UserDefaults.standard.set(NSArray(), forKey: MishowCache_videos)
        UserDefaults.standard.set(false, forKey: "isLogin")
        UserDefaults.standard.set("", forKey: "token")
        UserDefaults.standard.set("110%", forKey: "contentSize")
        UserDefaults.standard.set(10, forKey: "Count")
        UserDefaults.standard.set(false, forKey: "VIP")
        UserDefaults.standard.set(0, forKey: "miCoin")
        UserDefaults.standard.set(false, forKey: "everyFirstShareReward")
        UserDefaults.standard.set(false, forKey: "everyFirstLoginReward")
        UserDefaults.standard.set("19700101", forKey: "ShareDate")
        UserDefaults.standard.set("19700101", forKey: "LoginDate")
        UserDefaults.standard.set("", forKey: "userName")
        UserDefaults.standard.set(true, forKey: "downloadWhilePlaying")
        UserDefaults.standard.set(false, forKey: "mixWeb")
        UserDefaults.standard.set(0, forKey: "AD")
        UserDefaults.standard.set(false, forKey: "morning")
        UserDefaults.standard.set(false, forKey: "FirstTipsForMiquan")
        UserDefaults.standard.set(false, forKey: "mix")
        UserDefaults.standard.set(false, forKey: "DVIP")
        UserDefaults.standard.set(true, forKey: "Comment")
        UserDefaults.standard.set("1970-01-01", forKey: "morningDate")
        UserDefaults.standard.set(0, forKey: "MiquanTotal")
        UserDefaults.standard.set(0, forKey: "MixiuTotal")
        UserDefaults.standard.synchronize()
    }
    
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        print(">JPUSHRegisterDelegate jpushNotificationCenter didReceive");
        let userInfo = response.notification.request.content.userInfo
        JPUSHService.handleRemoteNotification(userInfo)
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!
        {
            let model = ArticleModel()
            model.setValuesForKeys(userInfo as! [String : Any])
            let story = UIStoryboard.init(name: "Support", bundle: nil)
            let V = story.instantiateViewController(withIdentifier: "MiquanDetailsController") as! MiquanDetailsController
            //            let voice = story.instantiateViewController(withIdentifier: "MiquanDetails") as! MiquanDetails
            if !isLoad{
                window = UIWindow.init(frame: UIScreen.main.bounds)
                vc = story.instantiateViewController(withIdentifier: "tabbar") as! Tabbar
                window?.rootViewController = vc
                window?.makeKeyAndVisible()
                isLoad = true
            }
            V.model = model
            (vc?.selectedViewController as! UINavigationController).pushViewController(V, animated: false)
            UIApplication.shared.applicationIconBadgeNumber = 0
            JPUSHService.resetBadge()
            
        }
        else{
            print("收到本地通知1!")
        }
        completionHandler()
    }
    
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        
        print(">JPUSHRegisterDelegate jpushNotificationCenter willPresent");
        let userInfo = notification.request.content.userInfo
        JPUSHService.handleRemoteNotification(userInfo)
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            print("收到本地通知有22222!")
        }
        else{
            print("收到本地通知有!")
        }
        completionHandler(Int(UNAuthorizationOptions.alert.rawValue|UNAuthorizationOptions.badge.rawValue|UNAuthorizationOptions.sound.rawValue))
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("IOS10的系统收到推送")
        completionHandler(UNNotificationPresentationOptions(rawValue: UInt(Int(UNAuthorizationOptions.alert.rawValue|UNAuthorizationOptions.badge.rawValue|UNAuthorizationOptions.sound.rawValue))))
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("IOS10的系统点击推送")
        completionHandler()
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("IOS10以下的系统收到推送",UIDevice.current.systemVersion)
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print("收到本地通知!",notification.alertBody!)
    }
    
    
    //Force touch menu
    var vc : UITabBarController?
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        var page = 0
        switch shortcutItem.localizedTitle {
        case "内容精选":
            page = 0
        case "看图开车":
            page = 1
        case "个人中心":
            page = 2
        default:
            break
        }
        vc?.selectedViewController = vc?.viewControllers?[page]
        
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.absoluteString.contains("widget"){
            let p = UIPasteboard.general
            let dic = try! JSONSerialization.jsonObject(with: p.data(forPasteboardType: "model")!, options: .allowFragments) as! NSDictionary
            let model = ArticleModel()
            model.mj_setKeyValues(dic)
            let story = UIStoryboard.init(name: "Support", bundle: nil)
            let V = story.instantiateViewController(withIdentifier: "MiquanDetailsController") as! MiquanDetailsController
            V.model = model
            if !isLoad{
                window = UIWindow.init(frame: UIScreen.main.bounds)
                vc = story.instantiateViewController(withIdentifier: "tabbar") as! Tabbar
                window?.rootViewController = vc
                window?.makeKeyAndVisible()
                isLoad = true
            }
            (vc?.selectedViewController as! UINavigationController).pushViewController(V, animated: false)
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.absoluteString.contains("widget"){
            let p = UIPasteboard.general
            let dic = try! JSONSerialization.jsonObject(with: p.data(forPasteboardType: "model")!, options: .allowFragments) as! NSDictionary
            let model = ArticleModel()
            model.mj_setKeyValues(dic)
            let story = UIStoryboard.init(name: "Support", bundle: nil)
            let V = story.instantiateViewController(withIdentifier: "MiquanDetailsController") as! MiquanDetailsController
            V.model = model
            if !isLoad{
                window = UIWindow.init(frame: UIScreen.main.bounds)
                vc = story.instantiateViewController(withIdentifier: "tabbar") as! Tabbar
                window?.rootViewController = vc
                window?.makeKeyAndVisible()
                isLoad = true
            }
            (vc?.selectedViewController as! UINavigationController).pushViewController(V, animated: false)
        }
        return true
    }
    
    
    func checkDeviceIsVIP() -> Void {
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/check_visitor_vip", dic: ["device":AimiFunction.getUniqueDeviceIdentifierAsString()], success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                print("请求访问设备VIP失败!")
                return
            }
            let json_err = json.object(forKey: "error") as! Int
            if json_err == 0{
                print(json.object(forKey: "message") as! String,json.object(forKey: "day") as! String)
                UserDefaults.standard.set(true, forKey: "DVIP")
            }
            else{
                print(json.object(forKey: "message") as! String)
                UserDefaults.standard.set(false, forKey: "DVIP")
            }
            UserDefaults.standard.synchronize()
        }, fail: { (err) in
            print(err.localizedDescription)
        }) { (pro) in
            
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
        print("尝试注册远程通知")
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("注册远程通知失败!",error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        print("注册远程通知成功!")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        //        currentUnityController.applicationWillResignActive(application)
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        //        currentUnityController.applicationDidEnterBackground(application)
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        //        currentUnityController.applicationWillEnterForeground(application)
        
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //        currentUnityController.applicationDidBecomeActive(application)
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        //        currentUnityController.applicationWillTerminate(application)
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "AimiHealth")
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




