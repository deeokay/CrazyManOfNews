//
//  AIMI_Introduce.swift
//  AimiHealth
//
//  Created by apple on 2017/3/3.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class AIMI_Introduce: UIViewController {

    @IBOutlet weak var version: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let infoDictionary = Bundle.main.infoDictionary {
            let mainVersion = infoDictionary["CFBundleShortVersionString"]!
            let buildVersion = infoDictionary["CFBundleVersion"]!
            version.text = "版本:\(mainVersion).\(buildVersion)"
        }
        let barButton = UIBarButtonItem.init(title: "", style: .done, target: self, action: nil)
        self.navigationItem.backBarButtonItem = barButton

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 进入协议详情页
    @IBAction func goToAgreement(_ sender: UIButton) {
        
        let agreementVC = (storyboard?.instantiateViewController(withIdentifier: "agreement"))!
        let barButton = UIBarButtonItem.init(title: "", style: .done, target: self, action: nil)
        agreementVC.navigationItem.backBarButtonItem = barButton
//        agreementVC.tag = 2
//        let nav = UINavigationController.init(rootViewController: agreementVC)
//        self.present(nav, animated: true, completion: nil)
        self.navigationController?.pushViewController(agreementVC, animated: true)
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
