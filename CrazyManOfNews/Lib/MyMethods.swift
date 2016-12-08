//
//  MyMethods.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/13.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import Foundation
import AFNetworking
class request{
    class func requestPOST(url:String,dic:NSDictionary,success: @escaping (_ data:Data)->Void,fail: @escaping (_ error:Error)->Void,Pro: @escaping (_ progress:Int64)->Void)-> Void{
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.cachePolicy = .useProtocolCachePolicy
        manager.requestSerializer.timeoutInterval = 5
        manager.responseSerializer = AFHTTPResponseSerializer()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        manager.post(url, parameters: dic, progress: {(p) in
        }, success: { (task, data) in
            do {
               try success (data as! Data)
            } catch let err as NSError {
                print("Error!!!",err)
            }

            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }) { (task, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            fail (error )
        }
    }
}
