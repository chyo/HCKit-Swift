//
//  HCBannerCell.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/23.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class HCBannerCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }
}
