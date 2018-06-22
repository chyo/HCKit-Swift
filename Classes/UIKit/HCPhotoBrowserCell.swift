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

class HCPhotoBrowserCell: UICollectionViewCell, UIScrollViewDelegate {
    
    var scrollView:UIScrollView?
    var imageView:UIImageView?
    var index:Int?
    
    deinit {
        self.scrollView?.delegate = nil
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
        
        self.scrollView = UIScrollView.init(frame: self.bounds)
        self.scrollView?.backgroundColor = UIColor.clear
        self.scrollView?.delegate = self
        self.scrollView?.alwaysBounceVertical = true
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.contentSize = self.bounds.size
        self.scrollView?.minimumZoomScale = 1.0
        self.scrollView?.maximumZoomScale = 3
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
        self.scrollView?.addSubview(self.imageView!)
    }
    
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
    }
    
    func showsImage (item:HCPhotoItem) {
        weak var weakSelf = self
        let queue = DispatchQueue.init(label: "HCKit_Swift.HCPhotoBrowserCellImageReadQueue", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
        if item.fullImageUrl!.hasPrefix("http") {
            self.showsImage(image: item.thumbnail)
            self.imageView?.kf.setImage(with: URL.init(string: item.fullImageUrl!), placeholder: nil, options: [.fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: { (image, error, type, url) in
                if weakSelf != nil && image != nil {
                    DispatchQueue.main.async {
                        weakSelf!.showsImage(image: image)
                    }
                }
            })
        } else if item.fullImageUrl!.contains("/") {
            queue.async {
                let data = try? Data.init(contentsOf: URL.init(fileURLWithPath: item.fullImageUrl!))
                if data != nil {
                    let image = UIImage.init(data: data!)
                    DispatchQueue.main.async {
                        self.showsImage(image: image)
                    }
                }
            }
        } else {
            let image = UIImage.init(named: item.fullImageUrl!)
            self.showsImage(image: image)
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // 缩放图片
        let w = max(self.imageView!.frame.size.width, self.scrollView!.frame.size.width)
        let h = max(self.imageView!.frame.size.height, self.scrollView!.frame.size.height)
        self.scrollView?.contentSize = CGSize.init(width: w, height: h)
        self.imageView?.center = CGPoint.init(x: w/2, y: h/2)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
}
