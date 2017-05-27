//
//  RegisterViewController.swift
//  AimiHealth
//
//  Created by ivan on 17/3/3.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
import MMPopupView
import AFNetworking

class RegisterViewController: UIViewController,UITextFieldDelegate {

    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var secretTextField: UITextField!
    @IBOutlet weak var reSecretTextField: UITextField!
    @IBOutlet weak var hasReadButton: UIButton!
    @IBOutlet weak var agreementButton: UIButton!
    @IBOutlet weak var nextStepButton: UIButton!
    // Sex
    @IBOutlet weak var manCheckBox: UIButton!
    @IBOutlet weak var womenCheckBox: UIButton!
    // 是否注册过了
    var isRegisted = false
    var sexID = 1
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "注册"
        // 左上角返回按钮
//        let barButton = UIBarButtonItem.init(title: "", style: .done, target: self, action: nil)
//        self.navigationItem.backBarButtonItem = barButton
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "后退"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(RegisterViewController.goBack))
        self.userNameTextField.delegate = self
        self.secretTextField.delegate = self
        self.reSecretTextField.delegate = self
        // 默认没有阅读协议
        self.hasReadButton.isSelected = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 注册后，从选择头像返回来后，直接退到登录界面
        if self.isRegisted == true {
            self.goBack()
        }
    }
    
    // MARK: - Private Methods
    @IBAction func back(_ sender: UIBarButtonItem) {
        self.goBack()
    }
    
    @objc private func goBack() {
        // 返回登录页面
        self.dismiss(animated: true, completion: nil)
    }
    
    // 下一步按钮
    @IBAction func goToNextStep(_ sender: UIButton) {
        // 结束编辑
        UIApplication.shared.keyWindow?.endEditing(true)
        if self.manCheckBox.isSelected == false && self.womenCheckBox.isSelected == false {
            DeeShareMenu.messageFrame(msg: NSLocalizedString("请选择性别", comment: ""), view: self.view)
            return
        } else {
            if self.manCheckBox.isSelected == true {
                sexID = 1 // boy
            } else {
                sexID = 2 // girl
            }
        }
        if self.hasReadButton.isSelected == false {
            DeeShareMenu.messageFrame(msg: NSLocalizedString("请确认协议", comment: ""), view: self.view)
            return
        }
        // 如果密码输入一致
        if self.secretTextField.text == self.reSecretTextField.text {
            let dic = ["username": self.userNameTextField.text!,
                       "password": self.secretTextField.text!,
                       "sex": sexID] as [String : Any]
            self.showHud(in: self.view)
            DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/user", dic: dic as NSDictionary, success: { (data) in
                self.hideHud()
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                    DeeShareMenu.messageFrame(msg: NSLocalizedString("服务器错误!", comment: ""), view: self.view)
                    return
                }
                if (json.object(forKey: "message") as! String) == "注册成功" {
                    DeeShareMenu.messageFrame(msg: NSLocalizedString("注册成功!", comment: ""), view: self.view)
                    let dict = json.object(forKey: "body") as! NSDictionary
                    let uid = dict["uid"] as! Int
                    UserDefaults.standard.set(uid, forKey: "uid")
                    self.isRegisted = true
                    let touxiangVC = ChangePhotosViewController()
                    touxiangVC.userName = self.userNameTextField.text!
                    touxiangVC.password = self.secretTextField.text!
                    touxiangVC.justRegisted = true
                    let nav = UINavigationController.init(rootViewController: touxiangVC)
                    self.present(nav, animated: true, completion: nil)
                } else  {
                    let message = json.object(forKey: "message") as! String
                    DeeShareMenu.messageFrame(msg: message, view: self.view)
                }
            }, fail: { (err) in
                
            }, Pro: {(pro) in
            
            })
        } else {
            // 如果不一致
            DeeShareMenu.messageFrame(msg: NSLocalizedString("密码输入不一致!", comment: ""), view: self.view)
        }
    }
    
    // Sex
    
    @IBAction func selectMan(_ sender: UIButton) {
        if self.womenCheckBox.isSelected == true {
            self.womenCheckBox.isSelected = false
        }
        self.manCheckBox.isSelected = !self.manCheckBox.isSelected
    }
    
    @IBAction func selectWoman(_ sender: UIButton) {
        if self.manCheckBox.isSelected == true {
            self.manCheckBox.isSelected = false
        }
        self.womenCheckBox.isSelected = !self.womenCheckBox.isSelected
    }
    
    
    
    
    // CheckBox
    @IBAction func hasReadAction(_ sender: UIButton) {
        
        self.hasReadButton.isSelected = !self.hasReadButton.isSelected
    }
    
    // 协议阅读
    @IBAction func agreementAction(_ sender: UIButton) {
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let agreementVC = (mainStoryBoard.instantiateViewController(withIdentifier: "agreement"))
        self.hasReadButton.isSelected = true
        self.navigationController?.pushViewController(agreementVC, animated: true)
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.userNameTextField {
            self.userNameTextField.resignFirstResponder()
            self.secretTextField.becomeFirstResponder()
        } else if textField == self.secretTextField {
            self.secretTextField.resignFirstResponder()
            self.reSecretTextField.becomeFirstResponder()
        } else if textField == self.reSecretTextField {
            UIApplication.shared.keyWindow?.endEditing(true)
        }
        return true
    }
    
    // 点击屏幕任何位置，结束编辑
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.keyWindow?.endEditing(true)
        UIView.animate(withDuration: 0.3) {
            self.view.mj_origin = CGPoint.init(x: 0, y: 0)
        }
    }

}
