//
//  Function1.swift
//  AimiHealth
//
//  Created by apple on 2016/12/5.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit

class Function1: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FourBtnCell", for: indexPath) as! FourBtnCell
        switch indexPath.row {
        case 0:
            cell.img.image = UIImage.init(named: "lishi")
            cell.label.text = NSLocalizedString("历史", comment: "")
        case 1:
            cell.img.image = UIImage.init(named: "shoucnag")
            cell.label.text = NSLocalizedString("收藏", comment: "")
        case 2:
            cell.img.image = UIImage.init(named: "pinglun")
            cell.label.text = NSLocalizedString("评论", comment: "")
        case 3:
            cell.img.image = UIImage.init(named: "jinbi")
            cell.label.text = NSLocalizedString("米币", comment: "")

        default:
            break
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    @IBOutlet weak var CV: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.CV.delegate  =  self
        self.CV.dataSource = self

        // Initialization code
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: UIwidth/4 + 10, height: 80)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    var action_0 = {Void()}
    var action_1 = {Void()}
    var action_2 = {Void()}
    var action_3 = {Void()}

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            action_0()
        case 1:
            action_1()
        case 2:
            action_2()
        case 3:
            action_3()
        default:
            break
        }
    }
    
}
