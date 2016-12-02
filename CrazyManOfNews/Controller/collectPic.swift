//
//  collectPic.swift
//  CrazyManOfNews
//
//  Created by Dee Money on 2016/11/7.
//  Copyright © 2016年 钱杰豪. All rights reserved.
//

import UIKit
import CoreImage
import MMPopupView
class collectPic: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate {
    var picArr = NSArray()
    var itemName = ""
    var delegate : AppDelegate?
    var superVC : Collect?
    var showIndex = 0
    var shareMenu = MMSheetView()
    var menu = DeeShareMenu()
    @IBOutlet var CV: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = UIApplication.shared.delegate as! AppDelegate?
        menu = DeeShareMenu()
        self.navigationItem.title = itemName
        self.shareMenu =  menu.shareMMpopMenu()
        // Do any additional setup after loading the view.
    }


    var keepWarning = true
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake{
            if UserDefaults.standard.bool(forKey: "shankeShare")
            {
                sharePic(self as UIViewController)
            }
            else{
                DeeShareMenu.showShankeMenu(Yes: {
                    UserDefaults.standard.set(true, forKey: "shankeShare")
                }, No: {
                    self.keepWarning = false
                }, ViewController: self, keepWarning: keepWarning)
            }
        }
    }
    var finish = UILabel()
    @IBAction func savePic(_ sender: Any) {
        let cell = self.CV.visibleCells.first as? collectPicCell
        if cell?.img.image != nil{
            UIImageWriteToSavedPhotosAlbum((cell?.img.image!)!, self, #selector(self.image(image:didFinishSavingWithErrorerror:contextInfo:)), nil)
        }
    }

    @objc private func image(image: UIImage, didFinishSavingWithErrorerror:NSError?,contextInfo:AnyObject) {
        if (didFinishSavingWithErrorerror == nil){
            DeeShareMenu.messageFrame(controller: self)
        }
        else{
            print(didFinishSavingWithErrorerror!)
        }
    }
    var contentType = SSDKContentType.image
    @IBAction func sharePic(_ sender: Any) {
        let model = self.picArr.object(at: (CV.indexPathsForVisibleItems.first?.row)!) as! Model
        let cell = self.CV.visibleCells.first as! collectPicCell
        var img = cell.img.image
        menu.shareDic = DeeShareMenu.shareContent(shareThumImage: &img, shareTitle: model.title, shareDescr: model.title, url: model.url, shareType: contentType)
        menu.stateHandler = DeeShareMenu.stateHandle(controller: self, success: {
            if self.contentType == SSDKContentType.text{
                self.contentType = SSDKContentType.image
            }
        }, fail: {
            self.contentType = SSDKContentType.text
        })
        self.shareMenu.show()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectPicCell", for: indexPath) as! collectPicCell
        let model = picArr.object(at: indexPath.row) as! Model
        cell.label.text = model.title!
        cell.img.layer.masksToBounds = true;
        cell.img.layer.borderWidth = 3.0; //边框宽度
        let url = URL.init(string: model.url!)
        DispatchQueue.global().async {
            let image = UIImage.animatedImage(withAnimatedGIFURL: url)
            DispatchQueue.main.async {
                cell.img.image = image
            }
        }
        return cell
    }

    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArr.count
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: UIwidth, height: UIheight - 104)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.CV.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        CV.scrollToItem(at: IndexPath.init(row: showIndex, section: 0), at: .centeredHorizontally, animated: false)
        UIView.animate(withDuration: 0.5, animations: {
            self.CV.alpha = 1
        })
    }
    
}
