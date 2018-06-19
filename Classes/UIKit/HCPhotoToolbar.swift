//
//  HCPhotoToolbar.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/11.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import SnapKit
import Photos

typealias HCPhotoToolbarSendHandler = ((_ assetArray:Array<PHAsset>)->Void)
typealias HCPhotoToolbarSelectionHandler = ((_ cell:HCPhotoListCell, _ assetArray:Array<PHAsset>, _ index:Int)->Void)

class HCPhotoToolbar: UIVisualEffectView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var assetArray:Array<PHAsset> = []
    var sendButton:UIButton?
    var collectionView:UICollectionView?
    var photoManager:PHCachingImageManager?
    var sendHandler:HCPhotoToolbarSendHandler?
    var selectionHandler:HCPhotoToolbarSelectionHandler?
    
    deinit {
        print("HCPhotoToolbar deinit")
        self.collectionView?.delegate = nil
        self.collectionView?.dataSource = nil
    }
    
    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup () {
        
        self.photoManager = PHCachingImageManager.init()
        
        // 分割线
        let sep = UIView.init()
        sep.backgroundColor = UIColor.init(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1)
        self.contentView.addSubview(sep)
        sep.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(0.5)
        }
        
        // 发送按钮
        let bundle = HCConfig.hc_resourceBundle()
        let sendButton = UIButton.init(type: UIButtonType.custom)
        sendButton.backgroundColor = UIColor.clear
        sendButton.setTitle("发送", for: UIControlState.normal)
        sendButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        sendButton.setBackgroundImage(UIImage.init(named: "hcButtonNormal", in: bundle, compatibleWith: nil)?.stretchableImage(withLeftCapWidth: 5, topCapHeight: 5), for: UIControlState.normal)
        sendButton.setBackgroundImage(UIImage.init(named: "hcButtonHighlighted", in: bundle, compatibleWith: nil)?.stretchableImage(withLeftCapWidth: 5, topCapHeight: 5), for: UIControlState.highlighted)
        sendButton.setBackgroundImage(UIImage.init(named: "hcButtonDisabled", in: bundle, compatibleWith: nil)?.stretchableImage(withLeftCapWidth: 5, topCapHeight: 5), for: UIControlState.disabled)
        sendButton.layer.cornerRadius = 4.0
        sendButton.isEnabled = false
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        sendButton.addTarget(self, action: #selector(self.actionSend), for: UIControlEvents.touchUpInside)
        
        self.contentView.addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.right.equalTo(-12)
            make.height.equalTo(29)
            make.width.equalTo(60)
            make.top.equalTo(10)
        }
        self.sendButton = sendButton
        
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        self.collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        self.collectionView?.backgroundView = nil
        self.collectionView?.backgroundColor = UIColor.clear
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView?.register(HCPhotoListCell.classForCoder(), forCellWithReuseIdentifier: "CELL")
        self.contentView.addSubview(self.collectionView!)
        self.collectionView!.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(10)
            make.height.equalTo(29)
            make.right.equalTo(self.sendButton!.snp.left).offset(-12)
        }
    }
    
    func index (of asset: PHAsset) -> Int? {
        return self.assetArray.index(of: asset)
    }
    
    func asset (at index:Int) -> PHAsset? {
        if  index >= 0 && index < self.assetArray.count {
            return self.assetArray[index]
        } else {
            return nil
        }
    }
    
    func remove (at idx:Int) {
        if idx < 0 || idx >= self.assetArray.count {
            return
        }
        self.assetArray.remove(at: idx)
        self.sendButton?.isEnabled = self.assetArray.count != 0
        DispatchQueue.main.async {
            self.collectionView?.deleteItems(at: [IndexPath.init(item: idx, section: 0)])
        }
    }
    
    func replace (at idx:Int, with asset:PHAsset) {
        if idx >= 0 && idx < self.assetArray.count {
            self.assetArray.remove(at: idx)
        }
        if self.assetArray.count == idx {
            self.assetArray.append(asset)
        } else {
            self.assetArray.insert(asset, at: idx)
        }
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.collectionView?.scrollToItem(at: IndexPath.init(item: self.assetArray.count-1, section: 0), at: UICollectionViewScrollPosition.right, animated: true)
            self.sendButton?.isEnabled = true
        }
    }
    
    func append (asset:PHAsset) {
        self.assetArray.append(asset)
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.collectionView?.scrollToItem(at: IndexPath.init(item: self.assetArray.count-1, section: 0), at: UICollectionViewScrollPosition.right, animated: true)
            self.sendButton?.isEnabled = true
        }
    }
    
    func count () -> Int {
        return self.assetArray.count
    }
    
    func scrollToItem (at index:Int) -> HCPhotoListCell?{
        let cell = self.collectionView?.cellForItem(at: IndexPath.init(item: index, section: 0)) as? HCPhotoListCell
        if cell == nil {
            var position:UICollectionViewScrollPosition = .right
            if self.collectionView!.indexPath(for: self.collectionView!.visibleCells.first!)!.item > index {
                position = .left
            }
            self.collectionView?.scrollToItem(at: IndexPath.init(item: index, section: 0), at: position, animated: false)
            self.collectionView?.layoutIfNeeded()
            return self.collectionView?.cellForItem(at: IndexPath.init(item: index, section: 0)) as? HCPhotoListCell
        } else {
            return cell
        }
    }
    
    /// 确认选择
    @objc func actionSend () {
        if self.assetArray.count == 0 || self.sendHandler == nil {
            return
        }
        self.sendHandler!(self.assetArray)
    }
    
    /// 新建一个toolbar实例
    ///
    /// - Returns: 实例
    static func toolbar (sendHandler:@escaping HCPhotoToolbarSendHandler, selectionHandler:@escaping HCPhotoToolbarSelectionHandler) -> HCPhotoToolbar {
        let toolbar = HCPhotoToolbar.init(effect: UIBlurEffect.init(style: UIBlurEffectStyle.extraLight))
        toolbar.sendHandler = sendHandler
        toolbar.selectionHandler = selectionHandler
        return toolbar
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.bounds.size.height, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath) as! HCPhotoListCell
        let asset = self.assetArray[indexPath.row]
        cell.checkButton?.isHidden = true
        cell.layer.cornerRadius = 5.0
        cell.clipsToBounds = true
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1
        self.photoManager?.requestImage(for: asset, targetSize: CGSize.init(width: collectionView.bounds.size.height*UIScreen.main.scale, height: collectionView.bounds.size.height*UIScreen.main.scale), contentMode: PHImageContentMode.aspectFit, options: nil, resultHandler: { (image, info) in
            cell.imageView?.image = image
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if self.selectionHandler != nil {
            let cell = collectionView.cellForItem(at: indexPath) as! HCPhotoListCell
            self.selectionHandler!(cell, self.assetArray, indexPath.row)
        }
    }
    
}
