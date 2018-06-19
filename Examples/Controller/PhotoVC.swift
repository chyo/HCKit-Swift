//
//  PhotoVC.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/12.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class PhotoVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var array:Array<HCPhotoItem> = []
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tfNumber: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionChoose(_ sender: Any) {
        weak var weakSelf = self
        let options = HCPhotoRequestOptions.init(maximumNumber: Int(self.tfNumber.text!)!)
        options.thumbnailWidth = 1000
        HCPhotoVC.showsPhotoVC(fromViewController: self, options: options) { (array) in
            for item in array {
                weakSelf?.array.append(item)
            }
            weakSelf?.collectionView.reloadData()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 2, bottom: 2, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (collectionView.bounds.size.width - 8)/3
        return CGSize.init(width: w, height: w)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
        let imageView = cell.viewWithTag(100) as! UIImageView
        imageView.image = self.array[indexPath.row].thumbnail
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}
