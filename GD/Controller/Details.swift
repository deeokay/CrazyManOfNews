//
//  Details.swift
//  MyPersonNewsProject
//
//  Created by Dee Money on 2016/10/12.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import CoreData
import MMPopupView
class Details: UIViewController,UIWebViewDelegate {
    var webStr : String?
    var tt:String?
    var thisMenu = MMSheetView()
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
        thisMenu = menu.shareMMpopMenu()
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }



    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake{
            if UserDefaults.standard.bool(forKey: "shankeShare"){
                shareContent(self as UIViewController)
            }
            else{
                DeeShareMenu.showShankeMenu(Yes: { 
                    UserDefaults.standard.set(true, forKey: "shankeShare")
                }, No: { 
                    self.keepWarning = false
                }, ViewController: self, keepWarning: keepWarning)
            }
        }

    }

    @IBAction func refresh(_ sender: Any) {
        self.webView.reload()
    }
    var date : String?
    var picImg : String?
    var keepWarning = true
    var channelName:String?
    var shareDescr:String?
    var shareThumImage:UIImage?
    var shareType = SSDKContentType.webPage
    @IBAction func shareContent(_ sender: AnyObject) {
        if shareThumImage == nil{
            shareThumImage = UIImage.init(named:"flash")
        }
        menu.shareDic = DeeShareMenu.shareContent(shareThumImage: &shareThumImage!, shareTitle: channelName!, shareDescr: shareDescr!, url: webStr!, shareType: shareType)
        menu.stateHandler = DeeShareMenu.stateHandle(controller: self, success: { 
            self.shareType = SSDKContentType.webPage
        }, fail: { 
            self.shareType = SSDKContentType.text
        })
        self.thisMenu.show()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func mark(_ sender: Any) {

    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        let delegate = UIApplication.shared.delegate as? AppDelegate
//    }


}
