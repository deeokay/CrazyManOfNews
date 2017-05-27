//
//  ConfigMiBaoViewController.swift
//  AimiHealth
//
//  Created by IvanLee on 2017/3/7.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
import SwiftyJSON

class ConfigMiBaoViewController: HideTabbarController, UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate {

    @IBOutlet weak var questionPickerView: UIPickerView!
    
    @IBOutlet weak var answerTextField: UITextField!
    
    @IBOutlet weak var selectQuestionButton: UIButton!
    
    @IBOutlet weak var questionView: UIView!
    
    let questionArray = [NSLocalizedString("您就读的小学是？", comment: ""),
                         NSLocalizedString("您的出生城市？", comment: ""),
                         NSLocalizedString("您的生日？", comment: ""),
                         NSLocalizedString("您的QQ号？", comment: ""),
                         NSLocalizedString("您的宿舍号？", comment: ""),
                         NSLocalizedString("您的车牌号？", comment: "")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapSpace = UITapGestureRecognizer.init(target: self, action: #selector(self.clickSpace))
        self.view.addGestureRecognizer(tapSpace)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkIfHasMiBao()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // 检测是否有过密保
    func checkIfHasMiBao() {
        
        let dict = ["username": UserDefaults.standard.object(forKey: "userName")]
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/question", dic: dict as NSDictionary, success: { (data) in
            
            let questionString = JSON.init(data: data)["question"].stringValue
            if questionString.lengthOfBytes(using: .utf8) == 0 {
                // 如果没有密保问题
            } else {
                // 如果有密保问题
                let alertVC = UIAlertController.init(title: NSLocalizedString("请确认密保", comment: ""), message: questionString, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: NSLocalizedString("确定", comment: ""), style: .default, handler: { (alertAction) in
                    let textField = (alertVC.textFields?.first)! as UITextField
                    if textField.text != JSON.init(data: data)["answer"].stringValue {
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("密保验证失败！", comment: ""), view: self.view)
                        _ = Time.delay(1.0, task: {
                            _ = self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        DeeShareMenu.messageFrame(msg: NSLocalizedString("密保验证正确！", comment: ""), view: self.view)
                    }
                })
                let cancelAction = UIAlertAction.init(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: { (alertAction) in
                    _ = self.navigationController?.popViewController(animated: true)
                })
                alertVC.addAction(cancelAction)
                alertVC.addAction(okAction)
                alertVC.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = NSLocalizedString("请输入答案", comment: "")
                })
                self.present(alertVC, animated: true, completion: nil)
            }
        }, fail: { (err) in
            print("查询密保问题失败！")
        }, Pro: { (pro) in
            
        })

    }
    
    // 点击空白，取消问题弹窗，取消编辑状态
    func clickSpace() {
        self.questionView.isHidden = true
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
    // 展示问题选择的PickerView
    @IBAction func showQuestionAction(_ sender: UIButton) {
        self.questionView.isHidden = false
        self.answerTextField.resignFirstResponder()
        self.selectQuestionButton.setTitle(self.questionArray[0], for: .normal)
    }

    // 完成
    @IBAction func finishAction(_ sender: UIButton) {
        guard self.answerTextField.hasText == true else {
            DeeShareMenu.messageFrame(msg: NSLocalizedString("请输入答案", comment: ""), view: self.view)
            return
        }
        self.showHud(in: self.view)
        let dict = ["uid": UserDefaults.standard.object(forKey: "uid"),
                    "question": self.selectQuestionButton.title(for: .normal),
                    "answer": self.answerTextField.text,
                    "token": UserDefaults.standard.object(forKey: "token")]
        DeeRequest.requestPost(url: "https://aimi.cupiday.com/\(AIMIversion)/setquestion", dic: dict as NSDictionary, success: { (data) in
            self.hideHud()
            if JSON.init(data: data)["error"].intValue == 0 {
                let alert = UIAlertController.init(title: NSLocalizedString("提示", comment: ""), message: JSON.init(data: data)["message"].stringValue, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: NSLocalizedString("确定", comment: ""), style: .default, handler: { (alert) in
                    _ = self.navigationController?.popViewController(animated: true)
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                DeeShareMenu.messageFrame(msg: JSON.init(data: data)["message"].stringValue, view: self.view)
            }
            
        }, fail: { (err) in
            print("密保修改失败！")
        },Pro: { (pro) in
            
        })
    }

    // 确定
    @IBAction func agreeAction(_ sender: UIButton) {
        self.questionView.isHidden = true
    }
    
    // 取消
    @IBAction func cancelAction(_ sender: UIButton) {
        self.questionView.isHidden = true
        self.questionPickerView.selectRow(0, inComponent: 0, animated: false)
    }
    
    
    // MARK: - UIPickerView
    
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.questionView.isHidden = true
        return true
    }

}
