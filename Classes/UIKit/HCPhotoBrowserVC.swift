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

public typealias HCPhotoBrowserDidScrollHandler = ((_ toPageIndex:Int)->Void)

public class HCPhotoBrowserVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, HCPhotoBrowserAnimatorProtocal {
    
    var barTintColor:UIColor?
    var tintColor:UIColor?
    var titleAttribute:[NSAttributedStringKey : Any]?
    var tapGesture:UITapGestureRecognizer!
    var collectionView:UICollectionView?
    var photoManager:PHCachingImageManager?
    var photoArray:Array<PHAsset>?
    var assetsFetchResults:PHFetchResult<PHAsset>?
    var selectedIndex:Int = 0
    var photoBrowserDidScrollHandler:HCPhotoBrowserDidScrollHandler?
    
    deinit {
        print("HCPhotoBrowserVC deinit")
        self.view.removeGestureRecognizer(self.tapGesture)
        self.collectionView?.delegate = nil
        self.collectionView?.dataSource = nil
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.barTintColor = self.navigationController?.navigationBar.barTintColor
        self.tintColor = self.navigationController?.navigationBar.tintColor
        self.titleAttribute = self.navigationController?.navigationBar.titleTextAttributes
        self.view.backgroundColor = UIColor.black
        self.tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.actionBack(tap:)))
        self.view.addGestureRecognizer(self.tapGesture)
        
        let flowLayout = HCPhotoBrowserFlowLayout.init()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        self.collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        self.collectionView!.backgroundView = nil
        self.collectionView!.backgroundColor = UIColor.clear
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self
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
    }
    
    public func reloadData (assetArray:Array<PHAsset>, selectAt index:Int, cacheManager:PHCachingImageManager) {
        self.photoManager = cacheManager
        self.photoArray = assetArray
        self.selectedIndex = index
        self.collectionView?.reloadData()
        DispatchQueue.main.async {
            self.collectionView?.scrollToItem(at: IndexPath.init(item: self.selectedIndex, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        }
    }
    
    public func reloadData (assetsFetchResults:PHFetchResult<PHAsset>, selectAt index:Int, cacheManager:PHCachingImageManager) {
        self.assetsFetchResults = assetsFetchResults
        self.selectedIndex = index
        self.photoManager = cacheManager
        self.collectionView?.reloadData()
        DispatchQueue.main.async {
            self.collectionView?.scrollToItem(at: IndexPath.init(item: self.selectedIndex, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hc_setNavigationBarTransparent(true)
        self.hc_setNavigationBarStyle(barTintColor: UIColor.clear, tintColor: UIColor.white, titleTextAttributes: nil)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        DispatchQueue.main.async {
            self.collectionView?.scrollToItem(at: IndexPath.init(item: self.selectedIndex, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hc_setNavigationBarStyle(barTintColor: self.barTintColor, tintColor: self.tintColor, titleTextAttributes: self.titleAttribute)
        self.hc_setNavigationBarTransparent(false)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @objc func actionBack (tap:UITapGestureRecognizer) {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.photoBrowserDidScrollHandler != nil {
            let index = self.collectionView?.indexPath(for: self.collectionView!.visibleCells.first!)?.item
            self.photoBrowserDidScrollHandler!(index!)
        }
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
        } else if self.photoArray != nil {
            return self.photoArray!.count
        } else {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HCPhotoBrowserCell", for: indexPath) as! HCPhotoBrowserCell
        var asset:PHAsset?
        if self.assetsFetchResults != nil {
            asset = self.assetsFetchResults![indexPath.row]
        } else if (self.photoArray != nil) {
            asset = self.photoArray![indexPath.row]
        }
        if asset != nil {
            self.photoManager?.requestImage(for: asset!, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: nil, resultHandler: { (image, info) in
                cell.showsImage(image: image!)
            })
        } else {
            cell.showsImage(image: nil)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 已经缓存的CELL不会经过cellForItemAt方法，如果该Cell的图片被缩放过，移动回来的时候会保持缩放状态，并影响新绘制的CELL。因此在这个地方将CELL的缩放状态改回1
        let bCell = cell as! HCPhotoBrowserCell
        bCell.showsImage(image: bCell.imageView?.image)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    public func animationImage () -> UIImage? {
        let cell = self.collectionView?.visibleCells.first as! HCPhotoBrowserCell
        if cell.imageView?.image == nil {
            return UIImage.init()
        } else {
            return cell.imageView?.image
        }
    }
    
    public func animationFrame (image:UIImage?) -> CGRect {
        let w = UIScreen.main.bounds.size.width
        if image == nil {
            let cell = self.collectionView!.visibleCells.first as! HCPhotoBrowserCell
            let rect = cell.scrollView!.convert(cell.imageView!.frame, to: self.view)
            return rect
        } else {
            let h = w/image!.size.width*image!.size.height
            return CGRect.init(x: 0, y: (UIScreen.main.bounds.size.height-h)/2, width: w, height: h)
        }
    }
    
    public func prepare() {
        // 不做任何事
    }
}
