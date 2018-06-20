//
//  HCPhotoListVC.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/8.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import Photos
import SnapKit

class HCPhotoListVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HCPhotoBrowserAnimatorProtocal {
    
    
    let margin:CGFloat = 2
    var toolbar:HCPhotoToolbar?
    var collectionView:UICollectionView?
    var assetsFetchResults:PHFetchResult<PHAsset>!
    var photoManager:PHCachingImageManager?
    var selectionHandler:HCPhotoSelectionHandler?
    var options:HCPhotoRequestOptions?
    
    var animationParentView:UIView?
    var animationIndex:Int = 0
    weak var animationCell:HCPhotoListCell?
    
    deinit {
        print("HCPhotoListVC deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
        self.title = "选择照片"
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.actionCancel))
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        self.collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        self.collectionView?.backgroundView = nil
        self.collectionView?.backgroundColor = UIColor.clear
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.register(HCPhotoListCell.classForCoder(), forCellWithReuseIdentifier: "HCPhotoListCell")
        self.view.addSubview(self.collectionView!)
        self.collectionView?.snp.makeConstraints({ (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        })
        weak var weakSelf = self
        let sendHandler:HCPhotoToolbarSendHandler = {(array) in
            if weakSelf?.selectionHandler == nil {
                DispatchQueue.main.async {
                    weakSelf?.actionCancel()
                }
                return
            }
            var photoArray:Array<HCPhotoItem> = []
            let options = PHImageRequestOptions.init()
            options.isSynchronous = true
            options.resizeMode = .exact
            options.deliveryMode = .fastFormat
            let queue = DispatchQueue.init(label: "HCKit_Swift.PhotoListVCReadPhoto", qos: DispatchQoS.unspecified, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
            for asset in array {
                weakSelf?.photoManager?.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: options, resultHandler: { (image, info) in
                    queue.async {
                        let item = HCPhotoItem.init(fullImage: image, options: weakSelf?.options)
                        photoArray.append(item)
                        if weakSelf != nil && photoArray.count == array.count {
                            DispatchQueue.main.async {
                                weakSelf!.selectionHandler!(photoArray)
                                weakSelf!.actionCancel()
                            }
                        }
                    }
                })
            }
        }
        let selectionHandler:HCPhotoToolbarSelectionHandler = {(cell, array, index) in
            let browserVC = HCPhotoBrowserVC()
            browserVC.photoBrowserDidScrollHandler = {(index) in
                weakSelf?.animationIndex = index
            }
            weakSelf?.animationIndex = index
            weakSelf?.animationParentView = weakSelf?.toolbar
            browserVC.reloadData(assetArray: array, selectAt: index, cacheManager: weakSelf!.toolbar!.photoManager!)
            weakSelf?.navigationController?.pushViewController(browserVC, animated: true)
        }
        let toolbar = HCPhotoToolbar.toolbar(sendHandler: sendHandler, selectionHandler: selectionHandler)
        self.view.addSubview(toolbar)
        toolbar.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(49)
        }
        self.toolbar = toolbar
    }
    
    @objc func actionCancel () {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hc_setNavigationBarTransparent(false)
        weak var weakSelf = self
        DispatchQueue.main.async {
            HCConfig.hc_isAuthorizedPhoto(openSettingsIfNeeded: true) { (granted) in
                if granted == false || (weakSelf?.assetsFetchResults != nil && weakSelf?.assetsFetchResults.count != 0) {
                    return
                }
                weakSelf?.fetchPhotos()
            }
        }
    }
    
    /// 获取照片信息列表
    func fetchPhotos () {
        let options = PHFetchOptions.init()
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        self.assetsFetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
        
        self.photoManager = PHCachingImageManager.init()
        self.collectionView?.reloadData()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
            self.toolbar?.snp.updateConstraints({ (make) in
                make.height.equalTo(self.view.safeAreaInsets.bottom+49)
            })
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.assetsFetchResults == nil {
            return 0
        } else {
            return self.assetsFetchResults.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIEdgeInsets.init(top: margin, left: margin, bottom: self.toolbar!.bounds.size.height-self.view.safeAreaInsets.bottom+margin, right: margin)
        } else {
            return UIEdgeInsets.init(top: margin, left: margin, bottom: self.toolbar!.bounds.size.height+margin, right: margin)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (collectionView.bounds.size.width - 5*margin)/4
        return CGSize.init(width: w, height: w)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        weak var weakSelf = self
        let scale = UIScreen.main.scale
        let w = (collectionView.bounds.size.width - 5*margin)/4*scale
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HCPhotoListCell", for: indexPath) as! HCPhotoListCell
        let asset = self.assetsFetchResults[indexPath.row]
        cell.selectionHandler = {(cell) in
            let idx = weakSelf?.toolbar?.index(of: asset)
            // 取消选择
            if idx != nil {
                weakSelf?.toolbar?.remove(at: idx!)
            }
            // 选择图片
            else {
                // 如果没限制，则无限添加
                if weakSelf?.options == nil {
                    weakSelf?.toolbar?.append(asset: asset)
                }
                // 如果最大选择数量是1，则直接替换选择的照片
                else if weakSelf!.options!.maximumNumber == 1 {
                    let exist = weakSelf?.toolbar?.asset(at: 0)
                    weakSelf?.toolbar?.replace(at: 0, with: asset)
                    // 取消上一个勾选的cell
                    if exist != nil {
                        collectionView.reloadItems(at: [IndexPath.init(item: weakSelf!.assetsFetchResults.index(of: exist!), section: 0)])
                    }
                }
                // 如果选择的照片数量小于最大选择数，则添加
                else if weakSelf!.options!.maximumNumber > weakSelf!.toolbar!.count() {
                    weakSelf?.toolbar?.append(asset: asset)
                }
                // 如果超过了最大选择数量，则取消当前cell的勾选
                else {
                    cell.checkButton?.isSelected = false
                }
            }
        }
        self.photoManager?.requestImage(for: asset, targetSize: CGSize.init(width: w, height: w), contentMode: PHImageContentMode.aspectFit, options: nil, resultHandler: { (image, info) in
            cell.imageView?.image = image
            cell.checkButton?.isSelected = weakSelf?.toolbar?.index(of: asset) != nil
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        weak var weakSelf = self
        collectionView.deselectItem(at: indexPath, animated: false)
        let browserVC = HCPhotoBrowserVC()
        browserVC.photoBrowserDidScrollHandler = {(index) in
            weakSelf?.animationIndex = index
        }
        weakSelf?.animationIndex = indexPath.row
        weakSelf?.animationParentView = self.view
        browserVC.reloadData(assetsFetchResults: self.assetsFetchResults, selectAt: indexPath.row, cacheManager: self.photoManager!)
        weakSelf?.navigationController?.pushViewController(browserVC, animated: true)
    }
    
    func animationImage () -> UIImage? {
        if self.animationCell?.imageView?.image == nil {
            return UIImage.init()
        } else {
            return self.animationCell?.imageView?.image
        }
    }
    
    func animationFrame(image: UIImage?) -> CGRect {
        // 获取cell相对于self.view的frame
        if self.animationCell == nil {
            return CGRect.init(x: self.view.center.x, y: self.view.center.y, width: 0, height: 0)
        }
        var frame = self.animationCell!.superview!.convert(self.animationCell!.frame, to: self.view)
        // iOS11以下的平台进入大图浏览返回后，会出现contentOffset变成0，获得的frame往上偏移了64px，导致动画位置不正确
        if Double(UIDevice.current.systemVersion)! < 11.0 && self.animationCell?.superview == self.collectionView && self.collectionView?.contentInset.top == 0 {
            frame.origin.y += 64
        }
        return frame
    }
    
    func prepare() {
        if self.animationParentView == self.toolbar {
            self.animationCell = self.toolbar?.scrollToItem(at: self.animationIndex)
        } else if self.animationParentView == self.view {
            self.animationCell = self.collectionView!.cellForItem(at: IndexPath.init(item: self.animationIndex, section: 0)) as? HCPhotoListCell
            if self.animationCell == nil {
                var position = UICollectionViewScrollPosition.bottom
                if self.collectionView!.indexPath(for: self.collectionView!.visibleCells.first!)!.item > self.animationIndex {
                    position = .top
                }
                self.collectionView!.scrollToItem(at: IndexPath.init(item: self.animationIndex, section: 0), at: position, animated: false)
                self.collectionView?.layoutIfNeeded()
                self.animationCell = self.collectionView!.cellForItem(at: IndexPath.init(item: self.animationIndex, section: 0)) as? HCPhotoListCell
            }
            var offset = self.collectionView!.contentOffset
            let frame = self.animationFrame(image: nil)
            if #available(iOS 11, *){
                if frame.origin.y <= self.collectionView!.safeAreaInsets.top {
                    offset.y -= (self.collectionView!.safeAreaInsets.top + margin - frame.origin.y)
                }
            } else {
                if frame.origin.y <= self.collectionView!.contentInset.top {
                    offset.y -= (self.collectionView!.contentInset.top + margin - frame.origin.y)
                }
            }
            if (frame.origin.y + frame.size.height + margin > self.toolbar!.frame.origin.y) {
                offset.y += (frame.origin.y + frame.size.height + margin - self.toolbar!.frame.origin.y)
            }
            collectionView?.contentOffset = offset
        }
    }
}
