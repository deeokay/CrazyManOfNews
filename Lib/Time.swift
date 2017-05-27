//
//  Time.swift
//  AimiHealth
//
//  Created by IvanLee on 2017/3/8.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//  延迟运行

import Foundation

class Time: NSObject {
    
    typealias Task = (_ cancel : Bool) -> Void
    
    // 延迟加载
    class func delay(_ time: TimeInterval, task: @escaping ()->()) ->  Task? {
        
        func dispatch_later(block: @escaping ()->()) {
            let t = DispatchTime.now() + time
            DispatchQueue.main.asyncAfter(deadline: t, execute: block)
        }
        var closure: (()->Void)? = task
        var result: Task?
        
        let delayedClosure: Task = {
            cancel in
            if let internalClosure = closure {
                if (cancel == false) {
                    DispatchQueue.main.async(execute: internalClosure)
                }
            }
            closure = nil
            result = nil
        }
        
        result = delayedClosure
        dispatch_later {
            if let delayedClosure = result {
                delayedClosure(false)
            }
        }
        return result
    }
    
    class func delay(_ time: TimeInterval) -> Void {
        
    }
    
    // 放弃延迟
    class func cancel(_ task: Task?) {
        task?(true)
    }

}
