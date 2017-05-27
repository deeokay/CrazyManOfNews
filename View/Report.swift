//
//  Report.swift
//  AimiHealth
//
//  Created by apple on 2017/3/10.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit

class Report: UIView,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var TB: UITableView!
    @IBOutlet weak var submit: UIButton!
    var checkList = [false,false,false,false]
    var reportList = [NSLocalizedString("低俗色情", comment: ""),NSLocalizedString("血腥暴力", comment: ""),NSLocalizedString("违法信息", comment: ""),NSLocalizedString("垃圾营销", comment: "")]
    override func awakeFromNib() {
        self.TB.register(UINib.init(nibName: "ReportCell", bundle: nil), forCellReuseIdentifier: "ReportCell")
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 2
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell") as! ReportCell
        cell.title.text = reportList[indexPath.row]
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.submitAction()
        DeeRequest.requestGet(url: "https://aimi.cupiday.com/\(AIMIversion)/report", dic: ["id":self.id,"type":self.type], success: { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else{
                print("请求举报接口失败")
                return
            }
            print("举报返回的json,",json.object(forKey: "message") as! String)
        }, fail: { (err) in
            print("请求举报接口JSON失败")
        }) { (pro) in

        }


    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  (self.frame.size.height - 80) / 4
    }


    var id = 0
    var type = 0
    var submitAction = {Void()}
    @IBAction func submit(_ sender: Any) {
        self.alpha = 0

    }



}
