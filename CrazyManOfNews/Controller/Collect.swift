//
//  Collect.swift
//  CrazyManOfNews
//
//  Created by Dee Money on 2016/11/7.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage
import SwiftTheme
class Collect: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var isOpen = [true,true,true,true]
    @IBOutlet var tb: UITableView!
    let likeArr = NSMutableArray()
    let unlikeArr = NSMutableArray()
    let likeGifArr = NSMutableArray()
    let unlikeGifArr = NSMutableArray()
    var allArr = NSArray()
    var delegate : AppDelegate?
    var context : NSManagedObjectContext?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.allArr = [likeArr,likeGifArr,unlikeArr,unlikeGifArr]
        self.tb.register(UINib.init(nibName: "collectNewsCell", bundle: nil), forCellReuseIdentifier: "collectNewsCell")
        delegate = UIApplication.shared.delegate as? AppDelegate
        context = delegate?.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Model")
        let entity = NSEntityDescription.entity(forEntityName: "Model", in: context!)
        request.entity = entity
        let arr = try! context?.fetch(request)
        for i in arr!{
            let tmp = i as! Model
            if tmp.isLike == true{
                if tmp.isGif == true{
                    likeGifArr.add(tmp)
                }
                else{
                    likeArr.add(tmp)
                }
            }
            else if tmp.isLike == false{
                if tmp.isGif == true{
                    unlikeGifArr.add(tmp)
                }
                else{
                    unlikeArr.add(tmp)
                }
            }
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectNewsCell") as! collectNewsCell
        let arr = allArr.object(at: indexPath.section) as! NSMutableArray
        let model = arr.object(at: indexPath.row) as! Model
        if model.isGif{
            if UserDefaults.standard.bool(forKey: "saveMode"){
                cell.img.image = UIImage.init(named: "PS")
            }
            else{
                DispatchQueue.global().async {
                    let image = UIImage.animatedImage(withAnimatedGIFURL: URL.init(string: model.url!))
                    DispatchQueue.main.async {
                        cell.img.image = image
                    }
                }
            }
        }
        else{
            cell.img.sd_setImage(with: URL.init(string: model.url!))
        }
        cell.label.text = model.title
        cell.date.isHidden = true
        cell.sourceName.isHidden = true
        return cell
    }

    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isOpen[section] == true{
            let arr = allArr.object(at: section) as! NSArray
            return arr.count
        }
        else{
            return 0
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel.init()
        label.theme_backgroundColor = ThemeColorPicker(colors: "#FF0000","#555550")
        switch section {
        case 0:
            label.text = "Like Pictures"
            label.tag = 20
        case 1:
            label.text = "Like Gif Pictures"
            label.tag = 21
        case 2:
            label.text = "Unlike Pictures"
            label.tag = 22
        case 3:
            label.text = "Unlike Gif Pictures"
            label.tag = 23
        default:
            break
        }
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.layer.cornerRadius = 15
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapSection(tap:)))
        label.addGestureRecognizer(tap)
        return label
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let arr = allArr.object(at: section) as! NSMutableArray
        if arr.count > 0 {
            return 30
        }
        else{
            return 0
        }
    }
    func tapSection(tap:UITapGestureRecognizer) -> Void {
        if  let s = tap.view?.tag{
            isOpen[s-20] = !isOpen[s-20]
            let index = NSIndexSet.init(index: s - 20)
            self.tb.reloadSections(index as IndexSet, with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "collectPic") as! collectPic
        var arr = NSArray()
        var title = ""
        switch indexPath.section {
        case 0:
            arr = likeArr
            title = "Like Pictures"
        case 1:
            arr = likeGifArr
            title = "Like Gif Pictures"
        case 2:
            arr = unlikeArr
            title = "Unlike Pictures"
        case 3:
            arr = unlikeGifArr
            title = "Unlike Gif Pictures"
        default:
            break
        }
        vc.picArr = arr
        vc.showIndex = indexPath.row
        vc.itemName = title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func cleanAllCollect(_ sender: Any) {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Model")
        let entity = NSEntityDescription.entity(forEntityName: "Model", in: context!)
        request.entity = entity
        let arr = try! context?.fetch(request)
        for i in arr!{
            context?.delete(i as! NSManagedObject)
        }
        likeArr.removeAllObjects()
        likeGifArr.removeAllObjects()
        unlikeArr.removeAllObjects()
        unlikeGifArr.removeAllObjects()
        self.tb.reloadData()
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
            let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Model")
            let entity = NSEntityDescription.entity(forEntityName: "Model", in: context!)
            request.entity = entity
            let modelArr = allArr.object(at: indexPath.section) as! NSMutableArray
            let model = modelArr.object(at: indexPath.row) as! Model
            modelArr.remove(model)
            context?.delete(model)
            self.tb.reloadData()
            do {
                try context?.save()
            } catch let err as NSError  {
                print("删除收藏失败,错误是\(err)")
            }
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tb.setEditing(editing, animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.tb.reloadData()
    }
    
}
