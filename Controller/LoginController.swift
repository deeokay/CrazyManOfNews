//
//  LoginController.swift
//  AimiHealth
//
//  Created by apple on 2017/2/21.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
import AFNetworking
import MMPopupView
class LoginController: UIViewController,UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NickName.delegate = self
        PasswordText.delegate = self

    }
    /* 键盘弹出可能造成崩溃，原因不明
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyboard(not:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        self.NickName.becomeFirstResponder()
    }
    func showKeyboard(not:Notification) -> Void {
        let rect = not.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        UIView.animate(withDuration: 0.3) {
            self.view.mj_origin = CGPoint.init(x: 0, y:  -rect.cgRectValue.height)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    */

    @IBOutlet weak var NickName: UITextField!
    @IBOutlet weak var PasswordText: UITextField!

    @IBAction func Login(_ sender: Any) {
        UIApplication.shared.keyWindow?.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: { 
            self.view.mj_origin = CGPoint.init(x: 0, y: 0)
        }) { (c) in
            if c{
                if self.NickName.text == "" || self.PasswordText.text == ""{
                    let alert = MMAlertView.init(confirmTitle: NSLocalizedString("登录错误", comment: ""), detail: NSLocalizedString("帐号密码均不能为空", comment: ""))
                    alert?.show()
                }
                else{
                    self.Login()
                }
            }
        }
    }

    @IBAction func SignIn(_ sender: Any) {
        let supportStoryBoard = UIStoryboard.init(name: "Support", bundle: nil)
        let vc = supportStoryBoard.instantiateViewController(withIdentifier: "RegisterViewController")
        let nav = UINavigationController.init(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }


    @IBAction func ForgotPassword(_ sender: Any) {
        let vc = MiBaoChangePasswordController()
        if self.NickName.hasText == true {
            vc.userName = self.NickName.text!
        }
        let nav = UINavigationController.init(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
        
    }

    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func login(with userName: String, password: String) -> Void {
        let dic = ["username": userName, "password": password] as NSDictionary
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/login", dic: dic, success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                DeeShareMenu.messageFrame(msg: NSLocalizedString("服务器错误!", comment: ""), view: self.view)
                return
            }
            print("用户信息:",json)
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
//                Reward.LoginReward()
                self.dismiss(animated: true, completion: nil)
                
            }
            else{
                let alert = MMAlertView.init(confirmTitle: NSLocalizedString("登录错误", comment: ""), detail: json.object(forKey: "message") as! String)
                alert?.show()
            }
            
        }, fail: { (err) in
            print(err.localizedDescription)
            DeeShareMenu.messageFrame(msg: err.localizedDescription, view: self.view)
        }) { (pro) in
        }
    }
    
    func Login() -> Void {
        
        self.login(with: NickName.text!, password: PasswordText.text!)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.keyWindow?.endEditing(true)
        UIView.animate(withDuration: 0.3) {
            self.view.mj_origin = CGPoint.init(x: 0, y: 0)
        }
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == NickName{
            NickName.resignFirstResponder()
            PasswordText.becomeFirstResponder()
        }
        else if textField == PasswordText{
//            Login()
            PasswordText.resignFirstResponder()
        }
        return true
    }


}
