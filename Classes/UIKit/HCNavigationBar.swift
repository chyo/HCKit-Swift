//
//  HCNavigationBar.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/7/4.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import SnapKit

/// 自定义导航栏
public class HCNavigationBar: UIVisualEffectView {
    
    /// 导航栏高度，默认44
    public var barHeight:CGFloat = 44 {
        didSet {
            self.titleLabel?.snp.updateConstraints({ (make) in
                make.height.equalTo(barHeight)
            })
            self.leftButton?.snp.updateConstraints({ (make) in
                make.height.equalTo(barHeight)
            })
            self.rightButton?.snp.updateConstraints({ (make) in
                make.height.equalTo(barHeight)
            })
        }
    }
    /// 安全区域发生变化时是否自动改变导航栏高度，默认true，仅iOS11及以上系统有效，计算方式为safeAreaInsets.top+barHeight。
    public var fitSafeAreaInsets:Bool = true
    public override var tintColor: UIColor! {
        didSet {
            self.titleLabel?.textColor = tintColor
            self.leftButton?.tintColor = tintColor
            self.rightButton?.tintColor = tintColor
            self.leftButton?.setTitleColor(tintColor, for: .normal)
            self.rightButton?.setTitleColor(tintColor, for: .normal)
        }
    }
    /// 导航栏标题，默认不为空
    public var titleLabel:UILabel?
    /// 左侧按钮，默认不为空，但title和image均为nil，需要自己添加事件
    public var leftButton:UIButton?
    /// 右侧按钮，默认不为空，但title和image均为nil，需要自己添加事件
    public var rightButton:UIButton?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    public override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        self.setup()
    }
    
    func setup () {
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        let titleLabel = UILabel.init()
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.contentView.snp.bottom)
            make.centerX.equalTo(self.contentView)
            make.height.equalTo(barHeight)
        }
        self.titleLabel = titleLabel
        
        let leftButton = UIButton.init(type: .custom)
        leftButton.backgroundColor = .clear
        leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        leftButton.setTitleColor(.lightGray, for: .highlighted)
        self.contentView.addSubview(leftButton)
        leftButton.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.bottom.equalTo(self.contentView.snp.bottom)
            make.height.equalTo(barHeight)
        }
        self.leftButton = leftButton
        
        let rightButton = UIButton.init(type: .custom)
        rightButton.backgroundColor = .clear
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        rightButton.setTitleColor(.lightGray, for: .highlighted)
        self.contentView.addSubview(rightButton)
        rightButton.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.bottom.equalTo(self.contentView.snp.bottom)
            make.height.equalTo(barHeight)
        }
        self.rightButton = rightButton
        
        self.tintColor = .darkGray
    }
    
    public func setImage (button:UIButton, image:UIImage, state:UIControlState) {
        let img = image.withRenderingMode(.alwaysTemplate)
        button.setImage(img, for: state)
    }
    
    public override func safeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            if self.superview != nil && self.fitSafeAreaInsets {
                self.snp.updateConstraints { (make) in
                    make.height.equalTo(self.safeAreaInsets.top+barHeight)
                }
            }
            super.safeAreaInsetsDidChange()
        }
    }
}
