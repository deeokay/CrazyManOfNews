//
//  MiBaoChangePasswordController.swift
//  AimiHealth
//
//  Created by IvanLee on 2017/3/8.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//  通过密保来修改密码，包括找回密码界面

import UIKit
import SwiftyJSON

class MiBaoChangePasswordController: HideTabbarController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var selectQuestionButton: UIButton!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var newSecretTextField: UITextField!
    @IBOutlet weak var ensureTextField: UITextField!
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var questionPickerView: UIPickerView!
    
    let questionArray = [NSLocalizedString("您就读的小学是？", comment: ""),
                         NSLocalizedString("您的出生城市？", comment: ""),
                         NSLocalizedString("您的生日？", comment: ""),
                         NSLocalizedString("您的QQ号？", comment: ""),
                         NSLocalizedString("您的宿舍号？", comment: ""),
                         NSLocalizedString("您的车牌号？", comment: "")]
    
    let isLogin: Bool = UserDefaults.standard.bool(forKey: "isLogin")
    var userName: String = ""
    var answer: String = ""
 
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 点击空白，取消编辑
        let tapGuesture = UITapGestureRecognizer.init(target: self, action: #selector(self.clickSpace))
        self.view.addGestureRecognizer(tapGuesture)
        if isLogin == false {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("取消", comment: ""), style: .plain, target: self, action: #selector(self.goBack))
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 如果登录，直接显示问题，如果没有登录，就选择密保问题
        if isLogin == true {
            self.selectQuestionButton.isHidden = true
            self.questionLabel.isHidden = false
            self.userName = UserDefaults.standard.string(forKey: "userName")!
            // 根据用户名查询密保问题
            self.searchQuestion(userName: self.userName)
        } else {
            self.selectQuestionButton.isHidden = false
            self.questionLabel.isHidden = true
            if self.userName == "" {
                self.typeUserName()
            }
        }
        self.userNameLabel.text = self.userName
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Private Methods
    // 右上角取消按钮
    @objc private func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 如果用户名为空（登录时没写），就手动写入
    private func typeUserName() {
        let alertVC = UIAlertController.init(title: NSLocalizedString("提示", comment: ""), message: NSLocalizedString("请输入用户名", comment: ""), preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: NSLocalizedString("确定", comment: ""), style: .default, handler: { (alertAction) in
            let textField = (alertVC.textFields?.first)! as UITextField
            self.userName = textField.text!
            self.userNameLabel.text = self.userName
        })
        alertVC.addAction(okAction)
        alertVC.addTextField(configurationHandler: { (textField) in
            textField.placeholder = NSLocalizedString("请输入您要修改密码的用户名", comment: "")
        })
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // 如果登录，根据用户名查询问题
    private func searchQuestion(userName: String) {
        self.showHud(in: self.view)
        let dict = ["username": userName]
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/question", dic: dict as NSDictionary, success: { (data) in
            
            let questionString = JSON.init(data: data)["question"].stringValue
            if questionString.lengthOfBytes(using: .utf8) == 0 {
                // 如果没有密保问题
                let alert = UIAlertController.init(title: NSLocalizedString("提示", comment: ""), message: NSLocalizedString("请设置您的密保问题！", comment: ""), preferredStyle: .alert)
                let action = UIAlertAction.init(title: NSLocalizedString("确定", comment: ""), style: .default, handler: { (alertAction) in
                    _ = self.navigationController?.popViewController(animated: true)
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
                // 如果有密保问题,则显示密保问题
                self.questionLabel.text = questionString
                self.answer = JSON.init(data: data)["answer"].stringValue
            }
            self.hideHud()
        }, fail: { (err) in
            print("查询密保问题失败！")
        }, Pro: { (pro) in
            
        })
    }
    
    // 点击空白，取消编辑
    @objc private func clickSpace() {
        self.questionView.isHidden = true
        UIApplication.shared.keyWindow?.endEditing(true)
    }

    // 如果没有登录，点击选择密保问题
    @IBAction func selectQuestion(_ sender: UIButton) {
        self.questionView.isHidden = false
        UIApplication.shared.keyWindow?.endEditing(true)
        self.selectQuestionButton.setTitle(self.questionArray[0], for: .normal)
    }
    
    @IBAction func finished(_ sender: UIButton) {
        guard self.answerTextField.hasText && self.newSecretTextField.hasText && self.ensureTextField.hasText == true else {
            DeeShareMenu.messageFrame(msg: NSLocalizedString("请填写完整！", comment: ""), view: self.view)
            return
        }
        guard self.newSecretTextField.text! == self.ensureTextField.text! else {
            DeeShareMenu.messageFrame(msg: NSLocalizedString("两次密码输入不一致！", comment: ""), view: self.view)
            return
        }
        guard self.answer == self.answerTextField.text else {
            DeeShareMenu.messageFrame(msg: NSLocalizedString("密保答案错误！", comment: ""), view: self.view)
            return
        }
        
        let dict = ["username": self.userName,
                    "password": self.newSecretTextField.text!,
                    "answer": self.answerTextField.text!]
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/retrieve_password", dic: dict as NSDictionary, success: { (data) in
            if JSON.init(data: data)["error"].intValue == 0 {
                DeeShareMenu.messageFrame(msg: JSON.init(data: data)["message"].stringValue, view: self.view)
                _ = Time.delay(1.0, task: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
            } else {
                DeeShareMenu.messageFrame(msg: JSON.init(data: data)["message"].stringValue, view: self.view)
            }
        }, fail: { (err) in
            print("重置密码错误！")
        }, Pro: { (pro) in
            
        })
    }
    
    @IBAction func okAction(_ sender: UIButton) {
        self.questionView.isHidden = true
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.questionView.isHidden = true
        self.questionPickerView.selectRow(0, inComponent: 0, animated: false)
    }
    
    // MARK: DataSource & Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.questionArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.questionArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectQuestionButton.setTitle(self.questionArray[row], for: .normal)
    }
}
