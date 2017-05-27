//
//  userFeedback.swift
//  AimiHealth
//
//  Created by apple on 2017/2/20.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
import AFNetworking
import ZLPhotoBrowser
class userFeedback: UIViewController,UITextFieldDelegate,UITextViewDelegate {

    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var commit: UIButton!
    @IBOutlet weak var connectWay: UITextField!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var contentText: UITextView!
    var firstEdit = false
    var text = NSLocalizedString("我们将根据您的反馈不断完善与改进!并第一时间给您回复", comment: "")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapClick = UITapGestureRecognizer.init(target: self, action: #selector(self.choosePictrue(tap:)))
        self.img.addGestureRecognizer(tapClick)
        self.contentText.text = text

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func completeEditContentText(_ sender: Any) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }

    @IBAction func CommitData(_ sender: Any) {
        UIApplication.shared.keyWindow?.endEditing(true)
        UIView.animate(withDuration: 0.2, animations: { 
            self.view.mj_origin = CGPoint.init(x: 0, y: 0)
        }) { (complete) in
            if complete{
                if self.contentText.text == self.text || self.contentText.text.lengthOfBytes(using: String.Encoding.utf8) < 15{
                    DeeShareMenu.messageFrame(msg: NSLocalizedString("内容要多于15字", comment: ""), view: self.view)
                }
                else{
                    self.commit.isEnabled = false
                    self.commit.backgroundColor = UIColor.lightGray
                    self.commit.setTitle(NSLocalizedString("提交中,请勿关闭...", comment: ""), for: .normal)
                    self.loading.startAnimating()
                    let uid = UserDefaults.standard.integer(forKey: "uid")
                    let dic =  ["uid":uid,"content":self.contentText.text!,"email":self.connectWay.text!] as NSDictionary
                    let manager = AFHTTPSessionManager()
                    manager.requestSerializer.timeoutInterval = 10
                    manager.responseSerializer = AFHTTPResponseSerializer()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    manager.post("https://aimi.cupiday.com/add_feedback", parameters: dic, constructingBodyWith: { (data) in
                        data.appendPart(withFileData: UIImagePNGRepresentation(self.img.image!)!, name: "file", fileName: ".png", mimeType: "file")
                    }, progress: { (pro ) in
                    }, success: { (dataTask, data) in
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        guard let json = try? JSONSerialization.jsonObject(with: data as! Data, options: .allowFragments) as! NSDictionary else{
                            print("解析上传视频Json失败!")
                            return
                        }
                        if json.object(forKey: "error") as! Int == 0{
                            self.loading.stopAnimating()
                            self.commit.setTitle(NSLocalizedString("提交反馈", comment: ""), for: .normal)
                            self.commit.backgroundColor = UIColor.gray
                            let alert = UIAlertController.init(title: "提示", message: NSLocalizedString("成功提交,将返回上一页", comment: ""), preferredStyle: .alert)
                            alert.addAction(UIAlertAction.init(title:NSLocalizedString("朕知道了", comment: ""), style: .destructive, handler: { (action) in
                                _ = self.navigationController?.popViewController(animated: true)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }

                    }, failure: { (task, err) in
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("提交失败!", comment: ""), view: self.view)
                        self.loading.stopAnimating()
                        self.commit.isEnabled = true
                        self.commit.setTitle(NSLocalizedString("提交反馈", comment: ""), for: .normal)
                        self.commit.backgroundColor = UIColor.gray
                    })
                }

            }
        }
    }

    func choosePictrue(tap:UITapGestureRecognizer) -> Void {
        let actionSheet = ZLPhotoActionSheet.init()
        actionSheet.maxSelectCount = 1
        actionSheet.maxPreviewCount = 20
        actionSheet.showPreviewPhoto(withSender: self, animate: true, last: nil) { (images:[UIImage], nil) in
            self.img.image = images[0]
        }
    }



    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIApplication.shared.keyWindow?.endEditing(true)
        UIView.animate(withDuration: 0.3) {
            self.view.mj_origin = CGPoint.init(x: 0, y: 0)
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.view.mj_origin = CGPoint.init(x: 0, y: -200)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.keyWindow?.endEditing(true)
        UIView.animate(withDuration: 0.3) {
            self.view.mj_origin = CGPoint.init(x: 0, y: 0)
        }
    }


    func textViewDidBeginEditing(_ textView: UITextView) {
        self.commit.isEnabled = true
        self.commit.backgroundColor = UIColor.blue
        if !firstEdit{
            textView.text = ""
            textView.textColor = UIColor.black
            firstEdit = true
        }
    }
    
    
    
    
    
    
    
    
    
}
