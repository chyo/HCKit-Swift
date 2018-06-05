//
//  HCRefreshFooterView.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/1.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import SnapKit

public class HCRefreshFooterView: UIView, HCPullToRefreshViewProtocol {
    
    var label:UILabel?
    var indicator:UIActivityIndicatorView?
    
    public var view: UIView! { return self }
    
    public var heightForView: CGFloat! { return 50 }
    
    public var offsetToBeganLoading: CGFloat! { return 10 }
    
    public var enabled: Bool! = true {
        didSet {
            if enabled {
                self.label?.text = "获取更多"
            } else {
                self.label?.text = ""
                self.indicator?.stopAnimating()
            }
        }
    }
    
    public func pullAnimation(_ offset: CGFloat) {
        self.label?.text = "获取更多"
        self.indicator?.stopAnimating()
    }
    
    public func loadingAnimation() {
        self.label?.text = "加载中"
        self.indicator?.startAnimating()
    }
    
    public func doneAnimation(_ complete: (() -> Void)!) {
        self.label?.text = self.enabled ? "获取更多" : ""
        self.indicator?.stopAnimating()
        if complete != nil {
            complete()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup () {
        self.backgroundColor = UIColor.clear
        
        self.label = UILabel.init()
        self.label?.backgroundColor = UIColor.clear
        self.label?.textColor = UIColor.init(red: 89.0/255.0, green: 89.0/255.0, blue: 89.0/255.0, alpha: 1)
        self.label?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.light)
        self.label?.text = "获取更多"
        self.addSubview(self.label!)
        self.label?.snp.makeConstraints({ (make) in
            make.center.equalTo(self)
        })
        
        self.indicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.indicator?.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1)
        self.indicator?.hidesWhenStopped = true
        self.addSubview(self.indicator!)
        self.indicator?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(self.label!.snp.left).offset(0)
        })
    }
    
    
}
