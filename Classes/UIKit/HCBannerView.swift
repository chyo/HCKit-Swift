//
//  HCBannerView.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/23.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import SnapKit

public typealias HCBannerViewSelectionHandler = ((_ view:HCBannerView?, _ item:HCBannerItem?) -> Void)

/// 轮播组件
public class HCBannerView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    let collectionView:UICollectionView!
    var timer:Timer?
    
    /// 数据
    public var itemArray:Array<HCBannerItem>!
    /// 占位图
    public var placeholder:UIImage?
    /// item 点击事件
    public var selectionHandler:HCBannerViewSelectionHandler?
    /// 自动播放时间间隔
    public var scrollTimerInterval:TimeInterval = 3
    
    public override init(frame: CGRect) {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        super.init(frame: frame)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup () {
        
        collectionView.register(HCBannerCell.self, forCellWithReuseIdentifier: "HCBannerCell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.backgroundView = nil
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isDirectionalLockEnabled = true
        collectionView.isPagingEnabled = true
        collectionView.contentInset = UIEdgeInsets.zero
        collectionView.bounces = false
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        itemArray = []
    }
    
    public func reloadData () {
        collectionView.alpha = 0
        collectionView.reloadData()
        if itemArray.count <= 1 {
            return
        }
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath.init(row: 1, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
            self.collectionView.alpha = 1
            self.startScrolling()
        }
    }
    
    /// 开启自动滚动
    func startScrolling (){
        guard self.itemArray.count > 1 else {
            return
        }
        self.timer = Timer.hc_scheduledTimer(timeInterval: self.scrollTimerInterval, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
    }
    
    @objc func autoScroll () {
        let offsetX = self.collectionView.contentOffset.x
        var index = Int(offsetX / self.collectionView.bounds.size.width)
        index = min(index+1, itemArray.count+1)
        self.collectionView.scrollToItem(at: IndexPath.init(item: index, section: 0), at: UICollectionViewScrollPosition.left, animated: true)
        if index == itemArray.count+1 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                guard self.timer != nil else {
                    return
                }
                self.collectionView.scrollToItem(at: IndexPath.init(item: 1, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
            }
        }
    }
    
    public override func layoutSubviews() {
        // 修正顶部自动缩进问题
        collectionView.contentInset = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }
        super.layoutSubviews()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if itemArray.count <= 1 {
            return
        }
        // 实现无限循环滚动
        let offsetX = scrollView.contentOffset.x
        // 如果移动到了第0个item，将偏移量改为倒数第二个item的位置，因为总数量是itemArray.count+2
        if offsetX < scrollView.bounds.size.width {
            self.collectionView.scrollToItem(at: IndexPath.init(row: itemArray.count, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        }
        // 如果移动到最后一个item，将偏移量改为第1个item的位置（不是第0个）
        else if (offsetX >= CGFloat((itemArray.count+1))*scrollView.bounds.size.width){
            self.collectionView.scrollToItem(at: IndexPath.init(row: 1, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        }
        self.startScrolling()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if itemArray.count <= 1 {
            return itemArray.count
        } else {
            // +2 是为了实现无限滚动
            return itemArray.count + 2
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HCBannerCell", for: indexPath) as! HCBannerCell
        cell.placeholder = self.placeholder
        if itemArray.count <= 1 {
            cell.item = itemArray[indexPath.row]
        } else {
            if indexPath.row == 0 {
                cell.item = itemArray.last
            } else if (indexPath.row-1 == itemArray.count){
                cell.item = itemArray.first
            } else {
                cell.item = itemArray[indexPath.row-1]
            }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        weak var weakSelf = self
        var item:HCBannerItem?
        if itemArray.count <= 1 {
            item = itemArray[indexPath.row]
        } else if indexPath.row == 0 {
            item = itemArray.last
        } else if indexPath.row-1 == itemArray.count {
            item = itemArray.first
        } else {
            item = itemArray[indexPath.row-1]
        }
        if self.selectionHandler != nil {
            self.selectionHandler!(weakSelf, item)
        }
    }
}
