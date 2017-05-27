//
//  UserAgreement.swift
//  AimiHealth
//
//  Created by apple on 2017/2/20.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
import WebKit

class UserAgreement: UIViewController {
    
    

    // 0:个人中心  1:注册后  2:关于
    var tag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("爱米健康用户协议", comment: "")

        if tag == 0 {
        } else if tag == 1 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("同意", comment: ""), style: UIBarButtonItemStyle.done, target: self, action: #selector(UserAgreement.goBack))
        } else if tag == 2 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("关闭", comment: ""), style: UIBarButtonItemStyle.done, target: self, action: #selector(UserAgreement.goBack))
        }
        let textView = Bundle.main.loadNibNamed("textView", owner: self, options: nil)?.first as! UITextView
        textView.frame = CGRect.init(x: 0, y: 0, width: UIwidth, height: UIheight)
        self.view.addSubview(textView)
        
//        let path = Bundle.main.path(forResource: "爱米健康用户协议", ofType: "doc")
//        let url = URL.init(fileURLWithPath: path!)
//        let config = WKWebViewConfiguration()
//        let preference = WKPreferences()
//        preference.minimumFontSize = 24
//        config.preferences = preference
//        let web = WKWebView.init(frame: self.view.bounds, configuration: config)
//        // 禁用用户选择
//        web.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none';", completionHandler: nil)
//        // 禁用长按弹出框
//        web.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none';", completionHandler: nil)
//        
//        web.load(URLRequest(url: url))
//        web.sizeToFit()
//        self.view.addSubview(web)
    }

    func goBack() {
        self.dismiss(animated: true, completion: nil)
    }

}
