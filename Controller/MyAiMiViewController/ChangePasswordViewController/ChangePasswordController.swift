//
//  ChangePasswordController.swift
//  AimiHealth
//
//  Created by ivan on 17/3/5.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//  修改密码界面，如果忘记密码可以跳转到通过密保修改密码

import UIKit
import SwiftyJSON

class ChangePasswordController: HideTabbarController, UITextFieldDelegate {
    
    @IBOutlet weak var oldSecretTextField: UITextField!
    @IBOutlet weak var newSecretTextField: UITextField!
    // 密保
    @IBOutlet weak var ensureSecretTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("修改密码", comment: "")
        self.view.backgroundColor = UIColor.white
        self.oldSecretTextField.delegate = self
        self.newSecretTextField.delegate = self
        self.ensureSecretTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Private Methods
    
    // 确定按钮
    @IBAction func finishAction(_ sender: Any) {
        // 检测输入框是否有留空
        guard self.oldSecretTextField.hasText && self.newSecretTextField.hasText && self.ensureSecretTextField.hasText == true else {
            DeeShareMenu.messageFrame(msg: NSLocalizedString("请填写完整！", comment: ""), view: self.view)
            return
        }
        let dict = ["uid": UserDefaults.standard.object(forKey: "uid"),
                    "newpassword": self.newSecretTextField.text!,
                    "password": self.oldSecretTextField.text!,
                    "token": UserDefaults.standard.object(forKey: "token")]
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/setpassword", dic: dict as NSDictionary, success: { (data) in
            let alert = UIAlertController.init(title: NSLocalizedString("提示", comment: ""), message: JSON.init(data: data)["message"].stringValue, preferredStyle: .alert)
            let action = UIAlertAction.init(title: NSLocalizedString("确定", comment: ""), style: .default, handler: { (alertAction) in
                UserDefaults.standard.set(false, forKey: "isLogin")
                _ = self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }, fail: { (err) in
            DeeShareMenu.messageFrame(msg: NSLocalizedString("修改密码失败！", comment: ""), view: self.view)
        }, Pro: {(pro) in
            
        })
    }

    // 使用密保修改
    @IBAction func secretGuardAction(_ sender: Any) {
        
        let dict = ["username": UserDefaults.standard.object(forKey: "userName")]
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/question", dic: dict as NSDictionary, success: { (data) in
            
            let questionString = JSON.init(data: data)["question"].stringValue
            if questionString.lengthOfBytes(using: .utf8) == 0 {
                // 如果没有密保问题
                let alert = UIAlertController.init(title: NSLocalizedString("提示", comment: ""), message: NSLocalizedString("您还未设置密保问题，请先到设置中创建密保问题", comment: ""), preferredStyle: .alert)
                let action = UIAlertAction.init(title: NSLocalizedString("确定", comment: ""), style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
                // 如果有密保问题
                let ensureSecretVC = MiBaoChangePasswordController()
                _ = self.navigationController?.pushViewController(ensureSecretVC, animated: true)
            }
        }, fail: { (err) in
            print("查询密保问题失败！")
        }, Pro: { (pro) in
            
        })
        
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.oldSecretTextField {
            self.oldSecretTextField.resignFirstResponder()
            self.newSecretTextField.becomeFirstResponder()
        } else if textField == self.newSecretTextField {
            self.newSecretTextField.resignFirstResponder()
            self.ensureSecretTextField.becomeFirstResponder()
        } else {
            self.ensureSecretTextField.resignFirstResponder()
        }
        
        return true
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}
