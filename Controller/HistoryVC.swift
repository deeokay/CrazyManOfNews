//
//  HistoryVC.swift
//  AimiHealth
//
//  Created by apple on 2017/2/25.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher
class HistoryVC: HideTabbarController,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate {

    
    lazy var resultVC = { () -> NSFetchedResultsController<NSFetchRequestResult> in 
        let context = AimiData.CreatCoredata()
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Aimi")
        let entity = NSEntityDescription.entity(forEntityName: "Aimi", in: context)
        request.entity = entity
        let sort = NSSortDescriptor.init(key: "time", ascending: false)
        request.sortDescriptors = [sort]
        let resultVC = NSFetchedResultsController.init(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return resultVC
    }()
    var modelArr = NSMutableArray()
    @IBOutlet weak var TB: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: " ", style: .plain, target: self, action: nil)
        getData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    func getData() -> Void {
        resultVC.delegate = self
        do {
            try resultVC.performFetch()
            print("读取历史成功!")
        } catch _ {
            print("获取数据库数据失败!")
        }

    }
    


    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (resultVC.fetchedObjects?.count)!
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as! HistoryCell
        let model = self.resultVC.object(at: indexPath) as! Aimi
        let dic = model.dic as! NSDictionary
        if let title = dic.object(forKey: "title") as? String{
        cell.title.text = title
            if title == ""{
                if let subTitle = dic.object(forKey: "username") as? String{
                    cell.title.text = subTitle
                }
            }
        }
        
        cell.time.text = model.time
        var imgUrl = String()
        
        switch model.type {
        case 1:
            cell.type.image = UIImage.init(named: "书")
            imgUrl = dic.object(forKey: "imgUrl") as! String
        case 2:
            cell.type.image = UIImage.init(named: "图片")
            imgUrl = (dic.object(forKey: "url") as! NSArray).firstObject as! String
        case 3:
            cell.type.image = UIImage.init(named: "视频")
            imgUrl = dic.object(forKey: "imgUrl") as! String
        default:
            break
        }
        cell.thumb.kf.setImage(with: URL.init(string: imgUrl))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            self.TB.deleteRows(at: [indexPath!], with: .left)
        default:
            break
        }
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.TB.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.TB.endUpdates()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.resultVC.object(at: indexPath) as! Aimi
        let dic = model.dic as! NSDictionary
        switch model.type {
        case 1:
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MiquanDetails") as! MiquanDetails
            let supportStoryBoard = UIStoryboard.init(name: "Support", bundle: nil)
            let vc = supportStoryBoard.instantiateViewController(withIdentifier: "MiquanDetailsController") as! MiquanDetailsController
            let mModel = ArticleModel()
            mModel.setValuesForKeys(dic as! [String : Any])
            vc.model = mModel
//            print(vc.model.mj_keyValues())
            vc.needToRecord = false
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PicDetail") as! PicDetail
            let pModel = PictureModel()
            pModel.setValuesForKeys(dic as! [String : Any])
            vc.model = pModel
            let nav = UINavigationController.init(rootViewController: vc)
            self.present(nav, animated: false, completion: nil)
        case 3:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoDetail") as! VideoDetail
            let vModel = VideoModel()
            vModel.setValuesForKeys(dic as! [String : Any])
            vc.model = vModel
            let nav = UINavigationController.init(rootViewController: vc)
            self.present(nav, animated: false, completion: nil)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let model = resultVC.object(at: indexPath) as! Aimi
        resultVC.managedObjectContext.delete(model)
        do {
             try resultVC.managedObjectContext.save()
            DeeShareMenu.messageFrame(msg: NSLocalizedString("删除记录成功!", comment: ""), view: self.view)
        } catch _ {
            print("尝试删除记录失败!")
        }
    }

    @IBAction func deleteAll(_ sender: Any) {
        if resultVC.fetchedObjects?.count != 0{
            for i in resultVC.fetchedObjects!{
                resultVC.managedObjectContext.delete(i as! Aimi)
            }
            do {
                try resultVC.managedObjectContext.save()
                DeeShareMenu.messageFrame(msg: NSLocalizedString("清空历史成功!", comment: ""), view: self.view)
                
            } catch _ {
                print("尝试清空数据库失败!")
            }
        }
        else{
            DeeShareMenu.messageFrame(msg: NSLocalizedString("空空如也!", comment: ""), view: self.view)
        }
    }
}

