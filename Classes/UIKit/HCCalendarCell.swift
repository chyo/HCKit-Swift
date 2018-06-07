//
//  HCCalendarCell.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/6.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class HCCalendarCell: UICollectionViewCell {
    
    weak var item:HCCalendarItem? {
        didSet {
            if item != nil && item!.day != 0 && label != nil{
                label?.text = String(item!.day)
                self.isUserInteractionEnabled = true
                label?.textColor = item?.isWeekend == true ? UIColor.orange : UIColor.darkGray
            } else {
                self.isUserInteractionEnabled = false
                label?.text = ""
            }
            if item?.selected == true {
                label?.backgroundColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
            } else {
                label?.backgroundColor = UIColor.clear
            }
        }
    }
    
    var label:UILabel?
    
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
        let width = min(self.bounds.size.width, self.bounds.size.height)
        let label = UILabel.init()
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = NSTextAlignment.center
        label.textColor = item?.isWeekend == true ? UIColor.orange : UIColor.darkGray
        label.frame = CGRect.init(x: 0, y: 0, width: width, height: width)
        label.center = CGPoint.init(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        label.clipsToBounds = true
        label.layer.cornerRadius = width / 2
        if item != nil && item!.day != 0 {
            label.text = String(item!.day)
        } else {
            label.text = ""
        }
        if item?.selected == true {
            label.backgroundColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
        } else {
            label.backgroundColor = UIColor.clear
        }
        self.addSubview(label)
        self.label = label
    }
}
