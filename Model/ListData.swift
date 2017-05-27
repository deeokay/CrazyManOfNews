//
//  ListData.swift
//  Aimi-V1.1
//
//  Created by Ivanlee on 2017/4/10.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import Foundation
import SwiftyJSON
struct RefreshPage {
    
    var currentPage = 1
    var totalPage = 1
}

struct NetWorkData {
    
    var urlString: String
    var paramDict: NSDictionary
    var page: RefreshPage
    
    init(urlString: String, paramDict: NSDictionary, page: RefreshPage) {
        self.urlString = urlString
        self.paramDict = paramDict
        self.page = page
    }
    
    func loadData(_ page: Int) {
        DeeRequest.requestGet(url: self.urlString, dic: self.paramDict, success: { (data) in
            
        }, fail: { (err) in
            
        }) { (pro) in
            
        }
    }
}
