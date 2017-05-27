//
//  AgreementController.swift
//  AimiHealth
//
//  Created by IvanLee on 2017/3/10.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class AgreementController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.alpha = 0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.textView.scrollsToTop = true
        
        self.textView.contentOffset = CGPoint.init(x: 0, y: 0)
        UIView.animate(withDuration: 0.3) { 
            self.textView.alpha = 1
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
