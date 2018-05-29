//
//  HCLetterHudView.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/28.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import SnapKit

public class HCLetterHudView: UIVisualEffectView, HCLetterHudProtocol {

    var label:UILabel!
    
    public var view: UIView { get { return self }}
    public var font: UIFont? {
        set (newValue){
            self.label!.font = newValue
        }
        get { return self.label!.font }
    }
    
    public override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup () {
        self.alpha = 0.0
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.05)
        self.clipsToBounds = true
        self.layer.cornerRadius = 6.0
        
        self.label = UILabel.init()
        self.label.font = UIFont.systemFont(ofSize: 48, weight: UIFont.Weight.bold)
        self.label.textColor = UIColor.darkGray
        self.contentView.addSubview(self.label)
        self.label.snp.makeConstraints({ (make) in
            make.center.equalTo(self.contentView)
        })
    }
    
    public func show() {
        self.alpha = 0.0
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1.0
        }
    }
    
    public func hide() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0.0
        }
    }
    
    public func letterDidChanged(item: HCLetterItem) {
        self.label.text = item.letter
    }
}
