//
//  CollectionViewVC.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/5.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class CollectionViewVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var itemArray:Array<String> = []
    @IBOutlet weak var collectionView: HCRefreshCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "下拉刷新CollectionView"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "两级下拉", style: UIBarButtonItemStyle.plain, target: self, action: #selector(enabledSecondFloor))
        weak var weakSelf = self
        self.collectionView.refreshHandler = { type in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
                if weakSelf == nil {
                    return
                }
                if type == .header {
                    weakSelf!.itemArray = ["0"]
                    weakSelf!.collectionView.reloadData()
                    weakSelf!.collectionView.refreshFooterView?.enabled = true
                    weakSelf!.collectionView.stopRefreshingAnimation(true)
                } else {
                    weakSelf?.collectionView.stopLoadMoreAnimation(true)
                    for _ in 0 ..< 5 {
                        weakSelf!.itemArray.append(String(weakSelf!.itemArray.count))
                    }
                    if weakSelf!.itemArray.count > 20 {
                        weakSelf!.collectionView.refreshFooterView?.enabled = false
                    }
                    weakSelf!.collectionView.reloadData()
                }
            }
        }
        self.collectionView.startRefreshingAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func enabledSecondFloor () {
        let headerView = SecondFloorHeaderView.init(frame: CGRect.zero)
        self.collectionView.refreshHeaderView = headerView
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemArray.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: (collectionView.bounds.size.width - 24) / 2, height: (collectionView.bounds.size.width-24)/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
        let label = cell.viewWithTag(100) as? UILabel
        label?.text = self.itemArray[indexPath.row]
        return cell
    }
}
