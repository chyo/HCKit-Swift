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

/// 照片选择控制器
class HCPhotoListVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// 照片之间的间距
    let margin:CGFloat = 2
    /// 底部工具栏
    var toolbar:HCPhotoToolbar?
    /// 集合视图
    var collectionView:UICollectionView?
    /// 照片结果集
    var assetsFetchResults:PHFetchResult<PHAsset>!
    /// 照片缓存对象
    var photoManager:PHCachingImageManager?
    /// 选择回调
    var selectionHandler:HCPhotoSelectionHandler?
    /// 处理函数
    var options:HCPhotoRequestOptions?
    /// 提示
    var hud:HCHud?
    
    /// 点击的照片的祖视图，self.view或者self.toolbar，点击照片时会赋值，用于区分该照片的来源
    weak var animationParentView:UIView?
    /// 点击的照片的位置
    var animationIndex:Int = 0
    /// 点击的照片的来源cell
    weak var animationCell:HCPhotoListCell?
    
    deinit {
//        print("HCPhotoListVC deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
        self.title = "选择照片"
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.actionCancel))
        
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
        
        self.setupToolbar()
    }
    
    /// 初始化底部工具条
    func setupToolbar () {
        weak var weakSelf = self
        // 发送按钮事件
        let sendHandler:HCPhotoToolbarSendHandler = {(array) in
            if weakSelf?.selectionHandler == nil {
                DispatchQueue.main.async {
                    weakSelf?.actionCancel()
                }
                return
            }
            // 显示加载指示器
            let hud = HCHud.init(in: weakSelf!.view, mode: .loading, style: .dark)
            hud.isUserInteractionEnabled = true
            hud.show(animated: true)
            var photoArray:Array<HCPhotoItem> = []
            // 从照片图库中读取图片的配置参数
            let options = PHImageRequestOptions.init()
            options.isSynchronous = true
            options.resizeMode = .exact
            options.deliveryMode = .fastFormat
            // 开一条线程，防止卡主线
            let queue = DispatchQueue.init(label: "HCKit_Swift.PhotoListVCReadPhoto", qos: DispatchQoS.unspecified, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
            queue.async {
                for asset in array {
                    weakSelf?.photoManager?.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: options, resultHandler: { (image, info) in
                        let item = HCPhotoItem.init(fullImage: image, options: weakSelf?.options)
                        photoArray.append(item)
                        // 当获得的最终图片和要求图片数量一致时，返回结果
                        if weakSelf != nil && photoArray.count == array.count {
                            DispatchQueue.main.async {
                                hud.hide(animated: true)
                                weakSelf!.selectionHandler!(photoArray)
                                weakSelf!.actionCancel()
                            }
                        }
                    })
                }
            }
            
        }
        // 点击事件处理，打开大图浏览
        let selectionHandler:HCPhotoToolbarSelectionHandler = {(cell, array, index) in
            let browserVC = HCPhotoBrowserVC.init(assetArray: array, selectAt: index, cacheManager: weakSelf!.toolbar!.photoManager!, animationFrameHandler: { (idx) -> CGRect in
                // 获取图片在本控制器中的frame
                weakSelf?.animationIndex = idx
                weakSelf?.scrollAnimationCellToVisible()
                return weakSelf!.animationFrame()
            }) { (idx) -> UIImage? in
                // 获取本控制器中对应的图片
                weakSelf?.animationIndex = idx
                weakSelf?.scrollAnimationCellToVisible()
                return weakSelf?.animationCell?.imageView?.image
            }
            weakSelf?.animationParentView = weakSelf?.toolbar
            weakSelf?.present(browserVC, animated: true, completion: nil)
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
            // 请求照片权限
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
        // 调整集合视图底部缩进
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
                    let hud = HCHud.init(in: weakSelf!.view, mode: .text, style: .dark)
                    hud.label?.text = "最多只能选择\(weakSelf!.options!.maximumNumber)张照片"
                    hud.toast(afterDelay: 1.5, complete: nil)
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
        let browserVC = HCPhotoBrowserVC.init(assetsFetchResults: self.assetsFetchResults, selectAt: indexPath.row, cacheManager: self.photoManager!, animationFrameHandler: { (idx) -> CGRect in
            // 获取动画图片对应的frame
            weakSelf?.animationIndex = idx
            weakSelf?.scrollAnimationCellToVisible()
            return weakSelf!.animationFrame()
        }) { (idx) -> UIImage? in
            // 获取动画图片
            weakSelf?.animationIndex = idx
            weakSelf?.scrollAnimationCellToVisible()
            return weakSelf?.animationCell?.imageView?.image
        }
        self.animationParentView = self.view
        self.present(browserVC, animated: true, completion: nil)
    }
    
    /// 获取动画图片
    ///
    /// - Returns: 图片
    func animationImage () -> UIImage? {
        if self.animationCell?.imageView?.image == nil {
            return UIImage.init()
        } else {
            return self.animationCell?.imageView?.image
        }
    }
    
    /// 获取动画CELL相对于UIWindow的Frame
    ///
    /// - Returns: frame
    func animationFrame() -> CGRect {
        if self.animationCell == nil {
            return CGRect.init(x: self.view.center.x, y: self.view.center.y, width: 0, height: 0)
        }
        return self.animationCell!.superview!.convert(self.animationCell!.frame, to: UIApplication.shared.keyWindow)
    }
    
    /// 将动画CELL滚动到可视位置
    func scrollAnimationCellToVisible() {
        // 来源位置是底部toolbar
        if self.animationParentView == self.toolbar {
            self.animationCell = self.toolbar?.scrollToItem(at: self.animationIndex)
        }
        // 来源位置是中间集合视图
        else if self.animationParentView == self.view {
            self.animationCell = self.collectionView!.cellForItem(at: IndexPath.init(item: self.animationIndex, section: 0)) as? HCPhotoListCell
            // 如果找不到，说明CELL在屏幕外，现将cell滚动到屏幕可视区域再次获取
            if self.animationCell == nil {
                var position = UICollectionViewScrollPosition.bottom
                if self.collectionView!.indexPath(for: self.collectionView!.visibleCells.first!)!.item > self.animationIndex {
                    position = .top
                }
                self.collectionView!.scrollToItem(at: IndexPath.init(item: self.animationIndex, section: 0), at: position, animated: false)
                self.collectionView?.layoutIfNeeded()
                self.animationCell = self.collectionView!.cellForItem(at: IndexPath.init(item: self.animationIndex, section: 0)) as? HCPhotoListCell
            }
            // 确保cell完整显示在屏幕中
            var offset = self.collectionView!.contentOffset
            let frame = self.animationFrame()
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
