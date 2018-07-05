//
//  HCPhotoBrowserVC.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/14.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import SnapKit
import Photos

/// 过渡动画的图片frame，需要返回用于动画的图片在上一个控制器的绝对位置
/// idx 图片index
public typealias HCPhotoBrowserFetchAnimationFrameHandler = ((_ idx:Int)->CGRect)
/// 过渡动画的图片
/// idx 图片index
public typealias HCPhotoBrowserFetchAnimationImageHandler = ((_ idx:Int)->UIImage?)
/// 图片浏览回调
/// toPageIndex 正在浏览的图片的idex
public typealias HCPhotoBrowserDidScrollHandler = ((_ toPageIndex:Int)->Void)

/**
 
 ## 图片浏览器 V1.0.0
 
 ### 支持过渡动画
 需要实现frameHandler和imageHandler用于获取过渡动画的图片及位置
 
 ### 三种初始化方法
 各自对应不同的图片来源方式，可以是网络图片，也可以是照片图库中的图片
 
 **/
public class HCPhotoBrowserVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIViewControllerTransitioningDelegate  {
    
    /// 自定义导航栏
    var naviBar:HCNavigationBar?
    /// 集合视图
    var collectionView:UICollectionView?
    /// 图片缓存对象
    weak var photoManager:PHCachingImageManager?
    /// 当前浏览的图片index
    var selectedIndex:Int = 0
    var photoBrowserDidScrollHandler:HCPhotoBrowserDidScrollHandler?
    var photoBrowserFetchAnimationFrameHandler:HCPhotoBrowserFetchAnimationFrameHandler?
    var photoBrowserFetchAnimationImageHandler:HCPhotoBrowserFetchAnimationImageHandler?
    
    /// 照片图库的图片列表
    var photoArray:Array<PHAsset>?
    /// 照片图库的图片集合
    var assetsFetchResults:PHFetchResult<PHAsset>?
    /// 自定义图片来源
    var itemArray:Array<HCPhotoItem>?
    /// 总页数
    var total:Int = 0
    
    deinit {
//        print("HCPhotoBrowserVC deinit")
        self.collectionView?.delegate = nil
        self.collectionView?.dataSource = nil
    }
    
    /// 使用照片图库来源的图片初始化大图浏览器
    ///
    /// - Parameters:
    ///   - assetArray: 照片图库列表
    ///   - index: 当前图片的位置
    ///   - cacheManager: 照片缓存对象
    ///   - animationFrameHandler: 获取过渡动画用的frame
    ///   - animationImageHandler: 获取过渡动画用的image
    public init (assetArray:Array<PHAsset>, selectAt index:Int, cacheManager:PHCachingImageManager, animationFrameHandler:HCPhotoBrowserFetchAnimationFrameHandler?, animationImageHandler:HCPhotoBrowserFetchAnimationImageHandler?) {
        super.init(nibName: nil, bundle: nil)
        self.photoManager = cacheManager
        self.photoArray = assetArray
        self.selectedIndex = index
        self.photoBrowserFetchAnimationFrameHandler = animationFrameHandler
        self.photoBrowserFetchAnimationImageHandler = animationImageHandler
        self.transitioningDelegate = self
        // 此处需要设置样式为overCurrentContext，否则在通过手势dismiss的时候看不到上一个控制器
        self.modalPresentationStyle = .overCurrentContext
        self.total = assetArray.count
    }
    
    /// 使用照片图库结果集初始化大图浏览器
    ///
    /// - Parameters:
    ///   - assetsFetchResults: 照片图库结果集
    ///   - index: 图片位置
    ///   - cacheManager: 缓存对象
    ///   - animationFrameHandler: 过渡动画用的frame
    ///   - animationImageHandler: 过渡动画用的图片
    public init (assetsFetchResults:PHFetchResult<PHAsset>, selectAt index:Int, cacheManager:PHCachingImageManager, animationFrameHandler:HCPhotoBrowserFetchAnimationFrameHandler?, animationImageHandler:HCPhotoBrowserFetchAnimationImageHandler?) {
        super.init(nibName: nil, bundle: nil)
        self.assetsFetchResults = assetsFetchResults
        self.selectedIndex = index
        self.photoManager = cacheManager
        self.photoBrowserFetchAnimationFrameHandler = animationFrameHandler
        self.photoBrowserFetchAnimationImageHandler = animationImageHandler
        self.transitioningDelegate = self
        self.modalPresentationStyle = .overCurrentContext
        self.total = assetsFetchResults.count
    }
    
    /// 使用其他来源如本地图片、网路图片来初始化大图浏览器
    ///
    /// - Parameters:
    ///   - itemArray: 自定义图片来源
    ///   - index: 图片位置
    ///   - animationFrameHandler: 过渡动画的frame
    ///   - animationImageHandler: 过渡动画的image
    public init (itemArray:Array<HCPhotoItem>, selectAt index:Int, animationFrameHandler:HCPhotoBrowserFetchAnimationFrameHandler?, animationImageHandler:HCPhotoBrowserFetchAnimationImageHandler?) {
        super.init(nibName: nil, bundle: nil)
        self.itemArray = itemArray
        self.selectedIndex = index
        self.photoBrowserFetchAnimationFrameHandler = animationFrameHandler
        self.photoBrowserFetchAnimationImageHandler = animationImageHandler
        self.transitioningDelegate = self
        self.modalPresentationStyle = .overCurrentContext
        self.total = itemArray.count
    }
    
    required public init?(coder aDecoder: NSCoder) {
        assert(false)
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        
        self.setupNavigationBar()
        
        let flowLayout = HCPhotoBrowserFlowLayout.init()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        self.collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        self.collectionView!.backgroundView = nil
        self.collectionView!.backgroundColor = UIColor.clear
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self
        self.collectionView?.alwaysBounceVertical = false
        self.collectionView!.register(HCPhotoBrowserCell.classForCoder(), forCellWithReuseIdentifier: "HCPhotoBrowserCell")
        self.automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11, *) {
            self.collectionView?.contentInsetAdjustmentBehavior = .never
        }
        self.view.addSubview(self.collectionView!)
        self.collectionView!.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }

        self.view.bringSubview(toFront: self.naviBar!)
    }

    /// 初始化导航栏
    func setupNavigationBar () {
        let naviBar = HCNavigationBar.init(effect: nil)
        naviBar.tintColor = .white
        // 如果图片来源不是相册，则添加保存按钮
        if self.itemArray != nil {
            naviBar.rightButton?.setImage(UIImage.init(named: "hcDownload", in: HCConfig.hc_resourceBundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            naviBar.rightButton?.addTarget(self, action: #selector(self.saveImage), for: UIControlEvents.touchUpInside)
        }
        self.view.addSubview(naviBar)
        naviBar.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(20+naviBar.barHeight)
        }
        self.naviBar = naviBar
    }
    
    /// 导航栏右侧按钮事件：保存图片到相册
    @objc func saveImage () {
        weak var weakSelf = self
        let cell = self.collectionView?.visibleCells.first as! HCPhotoBrowserCell
        if cell.imageView?.image != nil {
            HCConfig.hc_isAuthorizedPhoto(openSettingsIfNeeded: true) { (granted) in
                if granted {
                    UIImageWriteToSavedPhotosAlbum(cell.imageView!.image!, weakSelf!, #selector(weakSelf!.saveImageCallback(image:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
    }
    
    /// 图片保存结果
    ///
    /// - Parameters:
    ///   - image: 图片
    ///   - error: 错误信息
    ///   - contextInfo: 上下文信息
    @objc func saveImageCallback (image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        let hud = HCHud.init(in: self.view, mode: .text, style: .light)
        if  error == nil {
            hud.label?.text = "保存成功"
        } else {
            hud.label?.text = "保存失败: " + error!.description
        }
        hud.toast(afterDelay: 1.5, complete: nil)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.collectionView?.scrollToItem(at: IndexPath.init(item: self.selectedIndex, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
            if self.total != 1 {
                self.naviBar?.titleLabel?.text = "\(self.selectedIndex+1) / \(self.total)"
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = self.collectionView?.indexPath(for: self.collectionView!.visibleCells.first!)?.item
        self.naviBar?.titleLabel?.text = "\(index!+1) / \(self.total)"
        self.selectedIndex = index!
        self.photoBrowserDidScrollHandler?(index!)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.assetsFetchResults != nil {
            return self.assetsFetchResults!.count
        }
        else if self.photoArray != nil {
            return self.photoArray!.count
        }
        else if self.itemArray != nil {
            return self.itemArray!.count
        }
        else {
            return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        weak var weakSelf = self
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HCPhotoBrowserCell", for: indexPath) as! HCPhotoBrowserCell
        var asset:PHAsset?
        var item:HCPhotoItem?
        if self.assetsFetchResults != nil {
            asset = self.assetsFetchResults![indexPath.row]
        } else if self.photoArray != nil {
            asset = self.photoArray![indexPath.row]
        } else if self.itemArray != nil {
            item = self.itemArray![indexPath.row]
        }
        cell.showsImage(image: nil)
        cell.index = indexPath.row
        // 图片单机隐藏
        cell.didTapHandler = {
            weakSelf?.dismiss(animated: true, completion: nil)
        }
        // 图片拖动时改变控制器背景的透明度，以便看见上一个控制器
        cell.didPanHandler = { percent in
            if percent >= 1 {
                weakSelf?.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: percent)
                weakSelf?.naviBar?.alpha = percent
            } else {
                weakSelf?.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1-percent)
                weakSelf?.naviBar?.alpha = 1-percent
            }
            
        }
        if asset != nil {
            self.photoManager?.requestImage(for: asset!, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: nil, resultHandler: { (image, info) in
                // 理论上CELL应该会被block拷贝到堆上使用，但是在iOS9出现很奇怪的问题，选择第二张照片后打开此控制器，照片会变成第一张，但实际位置还是index=1，iOS10和11都未发现此问题，因此加了一个index的判断
                if cell.index == indexPath.item {
                    cell.showsImage(image: image!)
                }
            })
        }
        else if item != nil {
            cell.showsImage(item: item!)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 已经缓存的CELL不会经过cellForItemAt方法，如果该Cell的图片被缩放过，移动回来的时候会保持缩放状态，并影响新绘制的CELL。因此在这个地方将CELL的缩放状态改回1
        if #available(iOS 10, *) {
            let bCell = cell as! HCPhotoBrowserCell
            bCell.showsImage(image: bCell.imageView?.image)
        }
    }
    
    // MARK - UIViewControllerTransitioningDelegate
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if self.photoBrowserFetchAnimationImageHandler != nil && self.photoBrowserFetchAnimationFrameHandler != nil {
            let cell = self.collectionView?.visibleCells.first as! HCPhotoBrowserCell
            let fromImage = cell.imageView?.image
            let fromFrame = cell.contentView.convert(cell.animateFrame, to: UIApplication.shared.keyWindow)
            let toFrame = self.photoBrowserFetchAnimationFrameHandler!(self.selectedIndex)
            let animator = HCPhotoBrowserDismissAnimator.init(fromImage: fromImage, fromFrame: fromFrame, toFrame: toFrame)
            // 初始透明度，由于dismiss是可以通过手势触发的，因此需要根据当前的透明度来确定剩余动画的透明效果
            if cell.percent != 1 {
                animator.fromAlpha = 1-cell.percent
            }
            return animator
        } else {
            return nil
        }
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if self.photoBrowserFetchAnimationImageHandler != nil && self.photoBrowserFetchAnimationFrameHandler != nil {
            let fromImage = self.photoBrowserFetchAnimationImageHandler!(self.selectedIndex)
            let fromFrame = self.photoBrowserFetchAnimationFrameHandler!(self.selectedIndex)
            let w = UIScreen.main.bounds.size.width
            var h = w
            if fromImage != nil {
                h = w / fromImage!.size.width * fromImage!.size.height
            }
            let toFrame = CGRect.init(x: 0, y: (UIScreen.main.bounds.size.height-h)/2, width: w, height: h)
            return HCPhotoBrowserPresentAnimator.init(fromImage: fromImage, fromFrame: fromFrame, toFrame: toFrame)
        } else {
            return nil
        }
    }
}
