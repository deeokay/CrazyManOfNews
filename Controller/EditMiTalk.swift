//
//  EditMiTalk.swift
//  Aimi-V1.1
//
//  Created by iMac for iOS on 2017/3/29.
//  Copyright © 2017年 Cupiday. All rights reserved.
//

import UIKit

class EditMiTalk: UIViewController,UITextViewDelegate {

    var text = ""
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var line: NSLayoutConstraint!
    var delegate:MiTalk?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.text = self.text
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.current) { (not) in
            let rect = not.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
            UIView.animate(withDuration: 1, animations: { 
                self.line.constant = rect.cgRectValue.height
            })
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.current) { (not) in
            UIView.animate(withDuration: 1, animations: {
                self.line.constant = 0
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    
    
    @IBAction func editComplete(_ sender: UIButton) {
        self.delegate?.editText.text = self.textView.text
        self.navigationController?.popViewController(animated: true)
    }
    



}
