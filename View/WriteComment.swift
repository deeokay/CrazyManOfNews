//
//  WriteComment.swift
//  AimiHealth
//
//  Created by apple on 2016/12/22.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit
class WriteComment: UIView,UITextViewDelegate {
    var aid = NSInteger()
    var cid = NSInteger()
    var sendType = NSString()
    var contentType = NSString()
    var rname = ""
    var rrid = NSInteger()
    var ruid = NSInteger()
    @IBOutlet weak var textLimit: UILabel!
    var sendAction = {Void()}
    @IBAction func send(_ sender: Any) {
        self.textView.resignFirstResponder()
        //   文章
        var url = ""
        var dic = NSMutableDictionary()
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let str = textView.text.replacingOccurrences(of: "\n", with: "")
        if str.lengthOfBytes(using: String.Encoding.utf8) == 0 {
            print("空评论!")
        }
        else{
            if contentType.isEqual(to: "0"){
                if sendType .isEqual(to: "comment"){
                    dic = ["aid":self.aid,"uid":uid,"content":textView.text!,"type":0,"ruid":ruid]
                    url = "https://aimi.cupiday.com/\(AIMIversion)/comment"
                }
                else{
                    dic = ["cid":cid,"uid":uid ,"content":textView.text!,"aid":aid,"type":0,"rname":rname,"rrid":rrid,"ruid":ruid]
                    url = "https://aimi.cupiday.com/\(AIMIversion)/reply"
                }
            }
            else if self.contentType.isEqual(to: "1"){
                if sendType .isEqual(to: "comment"){
                    dic = ["aid":self.aid,"uid":uid ,"content":textView.text!,"type":1,"ruid":ruid]
                    url = "https://aimi.cupiday.com/\(AIMIversion)/comment"
                }else{
                    dic = ["cid":cid,"uid":uid ,"content":textView.text!,"aid":aid,"type":1,"rname":rname,"rrid":rrid,"ruid":ruid]
                    url = "https://aimi.cupiday.com/\(AIMIversion)/reply"
                }
            }else if self.contentType.isEqual(to: "2"){
                
                if sendType .isEqual(to: "comment"){
                    dic = ["aid":self.aid,"uid":uid ,"content":textView.text!,"type":2,"ruid":ruid]
                    url = "https://aimi.cupiday.com/\(AIMIversion)/comment"
                }
                else{
                    dic = ["cid":cid,"uid":uid ,"content":textView.text!,"aid":aid,"type":2,"rname":rname,"rrid":rrid,"ruid":ruid]
                    url = "https://aimi.cupiday.com/\(AIMIversion)/reply"
                }
            }else if self.contentType.isEqual(to: "3"){
                
                if sendType .isEqual(to: "comment"){
                    dic = ["aid":self.aid,"uid":uid ,"content":textView.text!,"type":3,"ruid":ruid]
                    url = "https://aimi.cupiday.com/\(AIMIversion)/comment"
                }
                else{
                    dic = ["cid":cid,"uid":uid ,"content":textView.text!,"aid":aid,"type":3,"rname":rname,"rrid":rrid,"ruid":ruid]
                    url = "https://aimi.cupiday.com/\(AIMIversion)/reply"
                }
            }
            DeeRequest.requestPost(url: url, dic: dic, success: { (data) in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                    print("回复/评论返回的JSON有错误!")
                    return
                }
                if  json.object(forKey: "error") as! Int == 0{
                    sleep(1)
                    self.sendAction()
                    self.textView.text = ""
                }
                else{
                    print("评论/回复 失败!")
                }
            }, fail: { (err) in
                print(err.localizedDescription)
            }, Pro: { (pro) in
                
            })
        }
    }
    
    @IBOutlet weak var textView: UITextView!
    override func awakeFromNib() {
        self.textView.delegate = self
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let arr = textView.text.components(separatedBy: "\n")
        if range.location == 149 || arr.count > 11 {
            return false
        }
        else{
            textLimit.text = "还可以输入\(150 - range.location)字"
            return true
        }
    }
    @IBAction func longPressToClear(_ sender: Any) {
        self.textView.text.removeAll()
        
    }
    
}
