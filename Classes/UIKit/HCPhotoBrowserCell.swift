//
//  HCPhotoBrowserCell.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/14.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import Photos
import Kingfisher

/// 单击事件
typealias HCPhotoBrowserCellDidTapHandler = (()->Void)
/// 图片拖动事件
/// - Parameter percent: 百分比 0.0 - 0.9999
typealias HCPhotoBrowserCellDidPanHandler = ((_ percent:CGFloat)->Void)

/// 大图浏览CELL
class HCPhotoBrowserCell: UICollectionViewCell, UIScrollViewDelegate {
    
    /// 用于各种手势的scrollView
    var scrollView:UIScrollView?
    /// 原图，添加在scrollView上
    var imageView:UIImageView?
    /// cell的index
    var index:Int?
    var didTapHandler:HCPhotoBrowserCellDidTapHandler?
    var didPanHandler:HCPhotoBrowserCellDidPanHandler?
    
    /// 开始拖动时手指在view的位置
    var panBeganPoint:CGPoint?
    /// 开始拖动时imageView的frame
    var panBeganFrame:CGRect?
    /// 向下拖动的百分比
    var percent:CGFloat = 1.0
    /// 拖动时所用的imageView，原本的imageView会被隐藏
    var movingImageView:UIImageView?
    /// 标记是否正在拖动
    var isMoving:Bool = false
    /// 标记是否正在缩放
    var isZooming:Bool = false
    /// 重置缩放标记
    var endZoomingTimer:Timer?
    /// 做dismiss动画时使用的frame，会跟随imageView或者movingImageView的frame变化而变化
    var animateFrame:CGRect = CGRect.zero
    /// 开始拖动时间，如果拖动时长小于0.2秒会触发dismiss
    var beganDraggingTimeInterval:TimeInterval = 0
    var beganContentOffset:CGPoint = CGPoint.zero
    
    deinit {
        print("HCPhotoBrowserCell deinit")
        self.scrollView?.delegate = nil
        self.didTapHandler = nil
        self.didPanHandler = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup () {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        self.scrollView = UIScrollView.init(frame: self.bounds)
        self.scrollView?.backgroundColor = UIColor.clear
        self.scrollView?.delegate = self
        self.scrollView?.alwaysBounceVertical = true
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.contentSize = self.bounds.size
        self.scrollView?.minimumZoomScale = 1.0
        self.scrollView?.maximumZoomScale = 4
        self.scrollView?.decelerationRate = 0
        
        if #available(iOS 11, *) {
            self.scrollView?.contentInsetAdjustmentBehavior = .never
        }
        self.contentView.addSubview(self.scrollView!)
        
        self.imageView = UIImageView.init(frame:CGRect.init(x: 0, y: 0, width: self.scrollView!.contentSize.width / 2, height: self.scrollView!.contentSize.width / 2))
        self.imageView?.isUserInteractionEnabled = false
        self.imageView?.backgroundColor = UIColor.init(red: 29/255.0, green: 29/255.0, blue: 29/255.0, alpha: 1)
        self.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        self.imageView?.center = CGPoint.init(x: self.scrollView!.contentSize.width / 2, y: self.scrollView!.contentSize.height / 2)
        self.animateFrame = self.imageView!.frame
        self.scrollView?.addSubview(self.imageView!)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        self.contentView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap () {
        self.didTapHandler!()
    }
    
    /// 设置图片
    ///
    /// - Parameter image: 图片对象
    func showsImage (image:UIImage?) {
        // 将图片的比例重新设定为1
        self.imageView?.image = image
        let w:CGFloat = self.scrollView!.bounds.size.width
        var h:CGFloat = w
        if image != nil {
            h = image!.size.height/(image!.size.width/w)
        }
        var contentSize = self.bounds.size
        if h > contentSize.height {
            contentSize.height = h
        }
        self.scrollView?.zoomScale = 1
        self.scrollView?.contentSize = contentSize
        self.scrollView?.contentOffset = CGPoint.init(x: 0, y: contentSize.height/2-scrollView!.bounds.size.height/2)
        self.imageView?.frame = CGRect.init(x: 0, y: 0, width: w, height: h)
        self.imageView?.center = CGPoint.init(x: self.scrollView!.frame.size.width/2, y: self.scrollView!.frame.size.height/2)
        self.animateFrame = self.imageView!.frame
        self.scrollViewDidEndDecelerating(self.scrollView!)
    }
    
    /// 设置图片
    ///
    /// - Parameter item: 实例对象
    func showsImage (item:HCPhotoItem) {
        weak var weakSelf = self
        let queue = DispatchQueue.init(label: "HCKit_Swift.HCPhotoBrowserCellImageReadQueue", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
        // 网络图片
        if item.fullImageUrl!.hasPrefix("http") {
            self.showsImage(image: item.thumbnail)
            self.imageView?.kf.setImage(with: URL.init(string: item.fullImageUrl!), placeholder: nil, options: [.fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: { (image, error, type, url) in
                if weakSelf != nil && image != nil {
                    DispatchQueue.main.async {
                        weakSelf!.showsImage(image: image)
                    }
                }
            })
        }
        // 本地图片
        else if item.fullImageUrl!.contains("/") {
            queue.async {
                let data = try? Data.init(contentsOf: URL.init(fileURLWithPath: item.fullImageUrl!))
                if data != nil {
                    let image = UIImage.init(data: data!)
                    DispatchQueue.main.async {
                        self.showsImage(image: image)
                    }
                }
            }
        }
        // 资源包图片
        else {
            let image = UIImage.init(named: item.fullImageUrl!)
            self.showsImage(image: image)
        }
        self.scrollViewDidEndDecelerating(self.scrollView!)
    }
    
    /// 图片拖动
    ///
    /// - Parameter gesture: 手势
    func handlePan (gesture:UIPanGestureRecognizer?) {
        guard gesture!.numberOfTouches == 1 else { return }
        let point = gesture!.location(in: gesture!.view)
        // 初始化动画图片，每次手势结束时会被置空
        if self.movingImageView == nil {
            self.isMoving = true
            self.movingImageView = UIImageView.init(image: self.imageView?.image)
            self.movingImageView?.frame = self.imageView!.frame
            self.movingImageView?.contentMode = .scaleAspectFill
            self.movingImageView?.clipsToBounds = true
            self.panBeganFrame = self.scrollView?.convert(self.imageView!.frame, to: self.contentView)
            self.beganContentOffset = self.scrollView!.contentOffset
            // 防止暴力拖动导致最终停留位置不对
            self.beganContentOffset.x = min(self.scrollView!.contentSize.width-self.scrollView!.bounds.width, max(0, self.beganContentOffset.x))
            self.beganContentOffset.y = min(self.scrollView!.contentSize.height-self.scrollView!.bounds.height, max(0, self.beganContentOffset.y))
            self.panBeganPoint = point
            self.imageView?.isHidden = true
            self.contentView.addSubview(self.movingImageView!)
        }
        // 计算中心位置，因为movingImageView会跟随手势进度形变，所以需要设定的是center，不是origin
        var center = CGPoint.init(x: self.panBeganFrame!.origin.x+self.panBeganFrame!.size.width/2, y:  self.panBeganFrame!.origin.y+self.panBeganFrame!.size.height/2)
        center.x -= (self.panBeganPoint!.x - point.x)*1.3
        center.y -= (self.panBeganPoint!.y - point.y)*1.3
        // 判断向上或向下拖动
        let different = point.y - self.panBeganPoint!.y
        var percent:CGFloat = 1.0
        // 如果是向下拖动，设定最大百分比到0.9999，如果设定到1的话，下面的代码还要做一个1的处理
        if different >= 0 {
            percent = different / (self.scrollView!.frame.size.height/2.5)
            percent = min(0.9999, max(0, percent))
        }
        // 形变
        var frame = self.panBeganFrame!
        if percent < 1.0 {
            frame.size.width -= frame.size.width*0.6*percent
            frame.size.height -= frame.size.height*0.6*percent
        }
        self.movingImageView?.frame = frame
        self.movingImageView?.center = center
        self.animateFrame = self.movingImageView!.frame
        if self.didPanHandler != nil {
            self.didPanHandler!(percent)
        }
        self.percent = percent
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        if (scrollView.contentOffset.y < 0 || isMoving) && !self.isZooming && !scrollView.isDecelerating {
            self.handlePan(gesture: scrollView.panGestureRecognizer)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.beganDraggingTimeInterval = Date.init().timeIntervalSince1970
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.isMoving {
            // 如果是向下拖动，并且拖动时长小于0.2秒，触发dismiss
            if self.panBeganFrame!.origin.y < self.movingImageView!.frame.origin.y && (Date.init().timeIntervalSince1970 - self.beganDraggingTimeInterval) < 0.2 && self.didTapHandler != nil {
                self.didTapHandler!()
                return
            }
            // 将动画图片恢复到原本的位置
            self.isMoving = false
            self.scrollView?.isUserInteractionEnabled = false
            self.animateFrame = self.panBeganFrame!
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.movingImageView?.frame = self.panBeganFrame!
                if self.didPanHandler != nil {
                    self.didPanHandler!(1.0)
                }
            }) { (finish) in
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 释放动画图片
        if self.movingImageView != nil {
            self.scrollView?.contentOffset = self.beganContentOffset
            self.imageView?.isHidden = false
            self.movingImageView?.removeFromSuperview()
            self.movingImageView = nil
            self.panBeganPoint = CGPoint.zero
            self.scrollView?.isUserInteractionEnabled = true
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // 缩放图片
        self.endZoomingTimer?.invalidate()
        self.endZoomingTimer = nil
        self.isZooming = true
        let w = max(self.imageView!.frame.size.width, self.scrollView!.frame.size.width)
        let h = max(self.imageView!.frame.size.height, self.scrollView!.frame.size.height)
        self.scrollView?.contentSize = CGSize.init(width: w, height: h)
        self.imageView?.center = CGPoint.init(x: w/2, y: h/2)
        self.animateFrame = self.imageView!.frame
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // 延迟重置缩放标记，因为触发endZooming后，可能会误触didScroll方法，导致进入图片拖动事件
        self.endZoomingTimer?.invalidate()
        self.endZoomingTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.endZooming), userInfo: nil, repeats: false)
    }
    
    @objc func endZooming () {
        self.isZooming = false
        self.endZoomingTimer?.invalidate()
        self.endZoomingTimer = nil;
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
}
