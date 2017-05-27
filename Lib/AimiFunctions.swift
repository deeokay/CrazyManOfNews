//
//  AimiRewardFunction.swift
//  AimiHealth
//
//  Created by apple on 2017/2/16.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import Foundation
import MMPopupView
import CoreData
import AVFoundation
import SAMKeychain
class Locale:NSObject{
    class func cast(str:String)->String{
        return NSLocalizedString(str, comment: "")
    }
}
class AimiPlayer: NSObject {
    static let share = AimiPlayer()
    var player = AVPlayer()
    class func formatPlayTime(_ secounds:TimeInterval)->String{
        if secounds.isNaN{
            return "00:00"
        }
        let Min = Int(secounds / 60)
        let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
}

class Reward:NSObject {
    class func LoginReward() {
        let date = Date.init()
        let formater = DateFormatter.init()
        formater.dateFormat = "yyyyMMdd"
        let today = formater.string(from: date)
        if !UserDefaults.standard.bool(forKey: "everyFirstLoginReward") && today != UserDefaults.standard.object(forKey: "LoginDate") as! String{
            print("即将进行首次登录验证!")
            AimiFunction.addMiCoin(success: {
                print("进行首次登录验证中...")
                let alert = MMAlertView.init(confirmTitle: NSLocalizedString("每天登录奖励", comment: ""), detail: NSLocalizedString("当前米币增加1个!", comment: ""))
                alert?.show()
                UserDefaults.standard.set(true, forKey: "everyFirstLoginReward")
                UserDefaults.standard.set(today, forKey: "LoginDate")
                UserDefaults.standard.synchronize()
            }, fail: {
            })
        }
    }
}


class AimiFunction: NSObject {
    class func shieldContentRefresh(sourceArr:NSMutableArray,model:AnyObject) -> NSMutableArray {
        sourceArr.remove(model)
        return sourceArr
    }
    class func shieldUserRefresh(sourceArr:NSMutableArray,model:DeeMedia) -> NSMutableArray {
            for i in sourceArr{
                let tmp = i as! DeeMedia
                if tmp.uid == model.uid{
                    sourceArr.remove(tmp)
                }
            }
        return sourceArr
    }
    class func shield(id:Int,type:Int,success:@escaping ()->Void)->Void{
        AimiFunction.checkLogin(controller: (UIApplication.shared.keyWindow?.rootViewController)!) { 
            let dic:NSDictionary = ["uid":UserDefaults.standard.integer(forKey: "uid"),"id":id,"type":type]
            DeeRequest.requestPost(url: "https://aimi.cupiday.com/shield", dic: dic, success: { (data) in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                    print("屏蔽返回的JSON错误!")
                    return
                }
                if json.object(forKey: "error") as! Int == 0{
                    print("屏蔽成功")
                    success()
                }
                else{
                    print("屏蔽失败")
                }
            }, fail: { (err) in
                print(err.localizedDescription)
            }) { (pro) in
            }
        }
    }
    
    
    
    class func getUniqueDeviceIdentifierAsString()->String{
        if let dic = Bundle.main.infoDictionary{
            let appName = dic[kCFBundleNameKey! as String] as! String
            var UUID = SAMKeychain.password(forService: appName , account: "incoding")
            if UUID == nil{
                UUID = UIDevice.current.identifierForVendor?.uuidString
                let query = SAMKeychainQuery.init()
                query.service = appName
                query.account = "incoding"
                query.password = UUID
                query.synchronizationMode = .no
                do {
                    try query.save()
                } catch _ {
                    print("保存UUID失败!")
                }
            }
            return UUID!
        }
        else{
            return ""
        }
        
    }
    class func deviceBuyVIP(success: @escaping ()->Void, fail: @escaping ()->Void,vipLevel:Int)->Void{
        let uuid = AimiFunction.getUniqueDeviceIdentifierAsString()
        let dic = ["device":uuid,"vip":vipLevel] as NSDictionary
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/visitor_vip", dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                print("请求增加用户米币的数据失败!")
                return
            }
            if json.object(forKey: "error") as! Int == 0{
                success()
            }
        }, fail: { (err) in
            print("请求设备购买VIP接口失败的错误描述",err.localizedDescription)
            fail()
        }, Pro: { (pro) in
        })
    }
    
    
    class func addMiCoin(success: @escaping ()->Void, fail: @escaping ()->Void,num:Int = 1)->Void{
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let token = UserDefaults.standard.object(forKey: "token") as! String
        let dic = ["uid":uid,"token":token , "num":num] as NSDictionary
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/add_integral", dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                print("请求增加用户米币的数据失败!")
                return
            }
            if json.object(forKey: "error") as! Int == 0{
                success()
            }
        }, fail: { (err) in
            print("请求增加用户米币接口失败的错误描述",err.localizedDescription)
            fail()
        }, Pro: { (pro) in
        })
    }
    
    class func RMB_VIP(success: @escaping ()->Void, fail: @escaping ()->Void,vipLevel:Int)->Void{
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let token = UserDefaults.standard.object(forKey: "token") as! String
        let dic = ["uid":uid,"token":token , "vip":vipLevel] as NSDictionary
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/rvip", dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                print("请求人民币购买VIP的数据失败!")
                return
            }
            if json.object(forKey: "error") as! Int == 0{
                print("请求人民币买VIP成功!")
                success()
            }
        }, fail: { (err) in
            print("请求增加用户米币接口失败的错误描述",err.localizedDescription)
            fail()
        }, Pro: { (pro) in
        })
    }
    
    class func MiCoin_VIP(success: @escaping ()->Void, fail: @escaping ()->Void,vipLevel:Int)->Void{
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let token = UserDefaults.standard.object(forKey: "token") as! String
        let dic = ["uid":uid,"token":token , "vip":vipLevel] as NSDictionary
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/vip", dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                print("请求米币购买VIP的数据失败!")
                return
            }
            if json.object(forKey: "error") as! Int == 0{
                print("请求米币买VIP成功!")
                success()
            }
        }, fail: { (err) in
            print("请求米币购买VIP的错误描述",err.localizedDescription)
            fail()
        }, Pro: { (pro) in
        })
    }
    
    
    
    class func recharge(success: @escaping ()->Void, fail: @escaping ()->Void,num:Int)->Void{
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let token = UserDefaults.standard.object(forKey: "token") as! String
        let dic = ["uid":uid,"token":token , "num":num] as NSDictionary
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/recharge", dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                print("请求增加用户米币的数据失败!")
                return
            }
            if json.object(forKey: "error") as! Int == 0{
                print("请求充值接口成功!")
                success()
            }
        }, fail: { (err) in
            print("请求增加用户米币接口失败的错误描述",err.localizedDescription)
            fail()
        }, Pro: { (pro) in
        })
    }
    
    class func checkLogin(controller:UIViewController,success:@escaping ()->Void) ->Void{
        if !UserDefaults.standard.bool(forKey: "isLogin"){
            let login = UIAlertController.init(title: NSLocalizedString("尚未登录!", comment: ""), message: NSLocalizedString("登录才可以进行后续操作哦!", comment: ""), preferredStyle: .alert)
            login.addAction(UIAlertAction.init(title: NSLocalizedString("登录/注册", comment: ""), style: .default, handler: { (action) in
                let story = UIStoryboard.init(name: "Main", bundle: nil)
                let vc = story.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                controller.present(vc, animated: true, completion: nil)
            }))
            login.addAction(UIAlertAction.init(title: NSLocalizedString("别烦我", comment: ""), style: .cancel, handler: nil))
            controller.present(login, animated: true, completion: nil)
        }
        else{
            success()
        }
    }
    
    class func shareReward(controller:UIViewController)->Void{
        let alert = UIAlertController.init(title: NSLocalizedString("分享成功!", comment: ""), message: "Success to share!", preferredStyle: .alert)
        if !(UserDefaults.standard.bool(forKey: "everyFirstShareReward")){
            let dic = ["uid":UserDefaults.standard.integer(forKey: "uid"),"token":UserDefaults.standard.object(forKey: "token")!,"num":1]
            DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/add_integral", dic: dic as NSDictionary, success: { (data) in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                    print("解析分享奖励接口失败!")
                    return
                }
                if json.object(forKey: "error") as! Int == 0{
                    UserDefaults.standard.set(true, forKey: "everyFirstShareReward")
                    let date = Date.init()
                    let formater = DateFormatter.init()
                    formater.dateFormat = "yyyyMMdd"
                    let today = formater.string(from: date)
                    UserDefaults.standard.object(forKey: today)
                    UserDefaults.standard.synchronize()
                }
                let alert = UIAlertController.init(title: NSLocalizedString("当前米币+1", comment: ""), message: NSLocalizedString("每天分享奖励成功!", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: NSLocalizedString("朕知道了", comment: ""), style: .destructive, handler: nil))
                controller.present(alert, animated: true, completion: nil)
            }, fail: { (err) in
                print("请求分享奖励失败!",err.localizedDescription)
            }, Pro: { (pro) in
            })
        }
        alert.show(controller, sender: controller)
    }
    
    class func checkToken(success:@escaping ()->Void,fail: @escaping ()->Void, controller:UIViewController) -> Void{
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let token = UserDefaults.standard.object(forKey: "token") as! String
        let dic = ["uid":uid,"token":token] as NSDictionary
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/token", dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                print("读取json失败!")
                return
            }
            if json.object(forKey: "error") as! Int == 0{
                print("检查Token完成并通过验证!")
                success()
            }
            else{
                UserDefaults.standard.set(false, forKey: "isLogin")
                let login = UIAlertController.init(title: NSLocalizedString("登录失效!", comment: ""), message: NSLocalizedString("当前登录已过期或已在另一台设备上登录!", comment: ""), preferredStyle: .alert)
                login.addAction(UIAlertAction.init(title: NSLocalizedString("重新登录", comment: ""), style: .default, handler: { (action) in
                    let story = UIStoryboard.init(name: "Main", bundle: nil)
                    let vc = story.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                    controller.present(vc, animated: true, completion: nil)
                }))
                login.addAction(UIAlertAction.init(title: NSLocalizedString("别烦我", comment: ""), style: .cancel, handler: nil))
                controller.present(login, animated: true, completion: nil)
            }
        }, fail: { (err) in
            print("读取验证Token的错误信息描述:\(err.localizedDescription)")
        }, Pro: { (pro) in
        })
    }
    
    
    class func Login(username:String,password:String,success: @escaping ()->Void)->Void{
        let dic = ["username":username,"password":password] as NSDictionary
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/login", dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                print("解析登录JSON失败!")
                return
            }
            if (json.object(forKey: "error") as! Int) == 0{
                let body = json.object(forKey: "body") as! NSDictionary
                UserDefaults.standard.set(true, forKey: "isLogin")
                UserDefaults.standard.set(body.object(forKey: "uid"), forKey:"uid")
                UserDefaults.standard.set(body.object(forKey: "avatar"), forKey: "userImage")
                UserDefaults.standard.set(body.object(forKey: "token"), forKey:"token")
                UserDefaults.standard.set(body.object(forKey: "username"), forKey:"userName")
                if body.object(forKey: "vip") as! Int != 0{
                    UserDefaults.standard.set(true, forKey: "VIP")
                }
                UserDefaults.standard.synchronize()
                Reward.LoginReward()
                success()
            }
            else{
                let alert = MMAlertView.init(confirmTitle: NSLocalizedString("登录错误", comment: ""), detail: json.object(forKey: "message") as! String)
                alert?.show()
            }
        }, fail: { (err) in
            print(err.localizedDescription)
        }) { (pro) in
        }
    }
    
}
//MARK:数据库
class AimiData: NSObject {
    class func CreatCoredata() ->NSManagedObjectContext {
        let modelUrl = Bundle.main.url(forResource: "AimiHealth", withExtension: "momd")
        let model = NSManagedObjectModel.init(contentsOf: modelUrl!)
        let store = NSPersistentStoreCoordinator.init(managedObjectModel: model!)
        let docStr = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        let sqlPath = docStr?.appending("/uesr_history.sqlite")
        let sqlUrl = URL.init(fileURLWithPath: sqlPath!)
        do {
            try store.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqlUrl, options: nil)
        } catch  {
        }
        let context = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = store
        return context
    }
    
    class func addDictionaryToCoreData(aid:Int,type:Int,dic:NSDictionary)->Bool{
        let formatter = DateFormatter()
        formatter.dateFormat = "M月dd日-HH:mm"
        let now = formatter.string(from: Date())
        let context = AimiData.CreatCoredata()
        let pre = NSPredicate.init(format: "aid = %d", aid)
        let sRequset = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Aimi")
        sRequset.predicate = pre
        guard let resultArr = try? context.fetch(sRequset) as NSArray else{
            print("查询失败!")
            return false
        }
        if resultArr.count != 0{
            print("查到记录了!")
            let model = resultArr.lastObject as! Aimi
            model.dic = dic
            model.time = now
            do {
                try context.save()
                print("修改浏览记录成功!")
            } catch {
                print("修改浏览记录失败!")
            }
        }
        else{
            let aRequest = NSEntityDescription.insertNewObject(forEntityName: "Aimi", into: context) as! Aimi
            aRequest.time = now
            aRequest.aid = Int64(aid)
            aRequest.dic = dic
            aRequest.type = Int64(type)
            do {
                try context.save()
                print("新增浏览记录成功!")
            } catch {
                print("新增浏览记录失败!")
            }
        }
        return true
    }
    
    class func deleteAllData(success: @escaping ()->Void)->Void{
        let context = AimiData.CreatCoredata()
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Aimi")
        let entity = NSEntityDescription.entity(forEntityName: "Aimi", in: context)
        request.entity = entity
        guard let resultArr = try? context.fetch(request) as NSArray else{
            print("查询失败!")
            return
        }
        for i in resultArr{
            context.delete(i as! Aimi)
        }
        
        do {
            try context.save()
            success()
        } catch _ {
            print("删除出错!")
        }
    }
    
}
