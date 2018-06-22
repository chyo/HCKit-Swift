//
//  PhotoVC.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/12.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var array:Array<HCPhotoItem> = []
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tfNumber: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PhotoVC"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "网络图片", style: .plain, target: self, action: #selector(self.imagesFromInternet))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func imagesFromInternet () {
        let array = ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530239435&di=a0e16198009a2c297abba952e4a6dacf&imgtype=jpg&er=1&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F5%2F532931489604e.jpg", "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1161149267,3646555459&fm=27&gp=0.jpg", "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529644738076&di=16127ea7b953eb2e8f95351e7d29986f&imgtype=0&src=http%3A%2F%2Ffile28.mafengwo.net%2FM00%2FB6%2FE5%2FwKgB6lQtapOAbZs6AAkLcjP2A_Y54.jpeg"]
        self.array = []
        for url in array {
            let item = HCPhotoItem.init(thumbnail: nil, fullImageUrl: url)
            self.array.append(item)
        }
        self.collectionView.reloadData()
    }
    
    @IBAction func actionChoose(_ sender: Any) {
        weak var weakSelf = self
        let options = HCPhotoRequestOptions.init(maximumNumber: Int(self.tfNumber.text!)!)
        options.thumbnailWidth = 200
        options.compressionQuality = 0.8
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
        let item = self.array[indexPath.row]
        if item.thumbnail != nil {
            imageView.image = item.thumbnail
        } else {
            imageView.kf.setImage(with: URL.init(string: item.fullImageUrl!), placeholder: nil, options: nil, progressBlock: nil) { (image, error, type, url) in
                item.thumbnail = image
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let browser = HCPhotoBrowserVC.init(nibName: nil, bundle: nil)
        browser.reloadData(itemArray: self.array, selectAt: indexPath.row)
        self.navigationController?.pushViewController(browser, animated: true)
    }
}
