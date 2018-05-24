//
//  HCBannerCell.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/23.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

class HCBannerCell: UICollectionViewCell {
    
    let imageView:UIImageView!
    weak var placeholder:UIImage?
    
    weak var item:HCBannerItem? {
        didSet {
            weak var weakImageView = imageView
            self.imageView.backgroundColor = UIColor.yellow
            self.imageView.kf.setImage(with: URL.init(string: item!.imgUrl!), placeholder: placeholder, options: [.fromMemoryCacheOrRefresh], progressBlock: nil) { (image, error, cacheType, url) in
                weakImageView?.contentMode = UIViewContentMode.scaleAspectFill
            }
        }
    }
    
    deinit {
        self.imageView.kf.cancelDownloadTask()
    }
    
    override init(frame: CGRect) {
        self.imageView = UIImageView.init()
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.imageView = UIImageView.init()
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.setup()
    }
    
    func setup () {
        self.imageView.contentMode = UIViewContentMode.center
        self.imageView.clipsToBounds = true
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
    }
    
    
}
