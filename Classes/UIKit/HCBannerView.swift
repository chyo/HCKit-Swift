//
//  HCBannerView.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/23.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import SnapKit

/// 图片点击回调
public typealias HCBannerViewSelectionHandler = ((_ view:HCBannerView?, _ item:HCBannerItem?) -> Void)

/// 指示器协议
public protocol HCBannerIndicatorProtocol {
    /// 返回view
    var view:UIView {get}
    /// 总页数
    var totalPages:Int {get set}
    /// 当前页
    var currentIndex:Int {get set}
}


/// 轮播组件
/// 无限滚动的实现方式原理 C A B C A， 前后添加一个item，当移动到第0个或最后一个item时，自动无动画移动回第3个或者1个，由于开启了pageEnabled，用户只能一页一页翻，因此对用户是无感知的。
/// 如需开启拖动放大效果，参见 bannerViewDidZooming 方法说明
public class HCBannerView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    let collectionView:UICollectionView!
    var timer:Timer?
    var zoomingScale:CGFloat = 1.0
    
    /// 数据
    public var itemArray:Array<HCBannerItem>!
    /// 占位图
    public var placeholder:UIImage?
    /// item 点击事件
    public var selectionHandler:HCBannerViewSelectionHandler?
    /// 是否开启自动播放
    public var enabledScrollTimer:Bool = true
    /// 自动播放时间间隔
    public var scrollTimerInterval:TimeInterval = 3
    /// 指示器，默认使用HCBannerIndicaotrView，可以通过协议.view获取。如果要自定义，必须遵循HCBannerIndicatorProtocol协议，并且手动将view添加到HCBannerView上。
    public var indicator:HCBannerIndicatorProtocol? {
        willSet (newValue){
            if newValue?.view != indicator?.view {
                indicator?.view.removeFromSuperview()
            }
        }
    }
    
    /// 刷新
    public func reloadData () {
        collectionView.alpha = 0
        collectionView.reloadData()
        self.indicator?.totalPages = itemArray.count
        self.indicator?.currentIndex = 0
        DispatchQueue.main.async {
            self.collectionView.alpha = 1
            if self.itemArray.count <= 1 {
                return
            }
            self.collectionView.scrollToItem(at: IndexPath.init(row: 1, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
            self.startScrolling()
        }
    }
    
    /// BannerView跟随scrollView做zooming，需要在scrollViewDidScroll中调用此方法。
    /// - Parameter scrollView: scrollview
    public func bannerViewDidZooming(_ scrollView:UIScrollView!) {
        if itemArray.count == 0 {
            return
        }
        // 由于scrollView在初始化的时候会触发一次scrollViewDidScroll，需要判断是否是由拖动触发的滚动
        // 当手势放开时，如果bannerView处于形变状态，则继续做形变恢复
        if !scrollView.isDragging && zoomingScale == 1.0 {
            return
        }
        var topInset = scrollView.contentInset.top
        if #available(iOS 11.0, *) {
            topInset = scrollView.safeAreaInsets.top + scrollView.contentInset.top
        }
        let different = -scrollView.contentOffset.y - topInset
        // different等于0代表scrollView偏移量恢复到初始状态，开启自动播放
        if different == 0 {
            self.startScrolling()
        }
        guard different > 0 else {
            return
        }
        // 形变的时候停止自动播放
        self.timer?.invalidate()
        self.timer = nil
        let scale = max((different+self.bounds.size.height)/self.bounds.size.height, 1.0)
        self.zoomingScale = scale
        self.collectionView.layer.transform = CATransform3DMakeScale(scale, scale, 1)
        self.collectionView.center.y = self.bounds.size.height/2.0 - different/2.0
    }
    
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
        
        let indicator = HCBannerIndicatorView.init(frame: CGRect.zero)
        self.addSubview(indicator)
        indicator.snp.makeConstraints({ (maker) in
            maker.left.equalTo(0)
            maker.right.equalTo(0)
            maker.bottom.equalTo(0)
            maker.height.equalTo(20)
        })
        self.indicator = indicator
    }
    
    /// 开启自动滚动
    func startScrolling (){
        guard self.itemArray.count > 1 && self.enabledScrollTimer else {
            return
        }
        self.timer?.invalidate()
        self.timer = Timer.hc_scheduledTimer(timeInterval: self.scrollTimerInterval, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
    }
    
    @objc func autoScroll () {
        let offsetX = self.collectionView.contentOffset.x
        var index = Int(offsetX / self.collectionView.bounds.size.width)
        index = min(index+1, itemArray.count+1)
        self.collectionView.scrollToItem(at: IndexPath.init(item: index, section: 0), at: UICollectionViewScrollPosition.left, animated: true)
        if index == itemArray.count+1 {
            self.indicator?.currentIndex = 0
            // 当移动到最后一个item时，自动移动回第1个（不是第0个）item
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                guard self.timer != nil else {
                    return
                }
                self.collectionView.scrollToItem(at: IndexPath.init(item: 1, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
            }
        } else {
            self.indicator?.currentIndex = index-1
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
        var index = Int(offsetX / self.collectionView.bounds.size.width) - 1
        // 如果移动到了第0个item，将偏移量改为倒数第二个item的位置，因为总数量是itemArray.count+2
        if offsetX < scrollView.bounds.size.width {
            index = itemArray.count-1
            self.collectionView.scrollToItem(at: IndexPath.init(row: itemArray.count, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        }
        // 如果移动到最后一个item，将偏移量改为第1个item的位置（不是第0个）
        else if (offsetX >= CGFloat((itemArray.count+1))*scrollView.bounds.size.width){
            self.collectionView.scrollToItem(at: IndexPath.init(row: 1, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
            index = 0
        }
        self.indicator?.currentIndex = index
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
