//
//  collectNews.swift
//  CrazyManOfNews
//
//  Created by Dee Money on 2016/11/8.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import CoreData
class collectNews: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var newsArr = [News]()
    @IBOutlet var TB: UITableView!
    var context : NSManagedObjectContext?
    var delegate : AppDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TB.register(UINib.init(nibName: "collectNewsCell", bundle: nil), forCellReuseIdentifier: "collectNewsCell")

        delegate = UIApplication.shared.delegate as? AppDelegate
        context = delegate?.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "News")
        let entity = NSEntityDescription.entity(forEntityName: "News", in: context!)
        request.entity = entity
        newsArr = try! context?.fetch(request) as! [News]

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectNewsCell") as! collectNewsCell
        let model = newsArr[indexPath.row]
        if let title = model.title{
            cell.label.text = title
        }
        if let date = model.date{
            cell.date.text = date
        }
        if let source = model.source{
            cell.sourceName.text = source
        }
        if model.url != nil{
            cell.img.sd_setImage(with: URL.init(string: model.url!))
        }
        //        }
        return cell
    }

    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArr.count
    }

    @IBAction func deleteAll(_ sender: Any) {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "News")
        let entity = NSEntityDescription.entity(forEntityName: "News", in: context!)
        request.entity = entity
        let arr = try! context?.fetch(request)
        for i in arr!{
            context?.delete(i as! NSManagedObject)
        }
        newsArr.removeAll()
        self.TB.reloadData()
        do {
            try context?.save()
        } catch let err as NSError  {
            print("删除收藏失败,错误是\(err)")
        }

    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "News")
            let entity = NSEntityDescription.entity(forEntityName: "News", in: context!)
            request.entity = entity
            let model = newsArr[indexPath.row]
            newsArr.remove(at: indexPath.row)
            context?.delete(model)
            self.TB.reloadData()
            do {
                try context?.save()
            } catch let err as NSError  {
                print("删除收藏失败,错误是\(err)")
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "details") as! Details
        let model = newsArr[indexPath.row]
        vc.webStr = model.link
        vc.tt = model.title
        vc.shareDescr = model.descr
        vc.channelName = model.source
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.TB.reloadData()
    }
    
}
