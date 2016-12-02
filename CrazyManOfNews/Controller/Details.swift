//
//  Details.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/12.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
class Details: UIViewController {
    var webStr : String?
    var tt:String?
    var thisMenu = UIAlertController()
    var menu = DeeShareMenu()
    @IBOutlet var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.applicationSupportsShakeToEdit = true
        self.becomeFirstResponder()
       self.navigationItem.title = tt!
        let url = URL.init(string: webStr!)
        let urlRequest = URLRequest.init(url: url!)
        webView.loadRequest(urlRequest)
        thisMenu = menu.shareMenu()
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake{
            if shareShare{
                shareContent(self as UIViewController)
            }
            else{
                DeeShareMenu.showShankeMenu(Yes: { 
                    shareShare = true
                }, No: { 
                    self.keepWarning = false
                }, ViewController: self, keepWarning: keepWarning)
            }
        }

    }

    var keepWarning = true


    var shareTitle:String?
    var shareUrl:String?
    var shareDescr:String?
    var shareThumImage:UIImage?
    var shareType = SSDKContentType.webPage
    @IBAction func shareContent(_ sender: AnyObject) {
        menu.shareDic = DeeShareMenu.shareContent(shareThumImage: &shareThumImage, shareTitle: shareTitle, shareDescr: shareDescr, url: shareUrl, shareType: shareType)
        menu.stateHandler = DeeShareMenu.stateHandle(controller: self, success: { 
            self.shareType = SSDKContentType.webPage
        }, fail: { 
            self.shareType = SSDKContentType.text
        })
        self.present(thisMenu, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
