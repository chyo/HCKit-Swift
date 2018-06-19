//
//  HCPhotoListCell.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/8.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

typealias HCPhotoListCellSelectionHandler = ((_ cell:HCPhotoListCell)->Void)

class HCPhotoListCell: UICollectionViewCell {
    
    var imageView:UIImageView?
    var checkButton:UIButton?
    var selectionHandler:HCPhotoListCellSelectionHandler?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup () {
        self.backgroundColor = UIColor.init(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
        self.imageView = UIImageView.init()
        self.imageView?.backgroundColor = UIColor.clear
        self.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        self.imageView?.clipsToBounds = true
        self.imageView?.frame = self.bounds
        self.addSubview(self.imageView!)
        
        let bundle = HCConfig.hc_resourceBundle()
        self.checkButton = UIButton.init(type: UIButtonType.custom)
        self.checkButton?.backgroundColor = UIColor.clear
        self.checkButton?.setImage(UIImage.init(named: "hcPhotoUnchecked", in: bundle, compatibleWith: nil), for: UIControlState.normal)
        self.checkButton?.setImage(UIImage.init(named: "hcPhotoChecked", in: bundle, compatibleWith: nil), for: UIControlState.selected)
        self.checkButton?.frame = CGRect.init(x: self.bounds.size.width-28, y: 4, width: 24, height: 24)
        self.checkButton?.addTarget(self, action: #selector(self.actionCheck), for: UIControlEvents.touchUpInside)
        self.addSubview(self.checkButton!)
    }
    
    @objc func actionCheck () {
        self.checkButton!.isSelected = !self.checkButton!.isSelected
        if self.selectionHandler != nil {
            self.selectionHandler!(self)
        }
    }
}
