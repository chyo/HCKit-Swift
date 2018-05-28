//
//  HCBannerIndicatorView.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/25.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

public class HCBannerIndicatorView: UIPageControl, HCBannerIndicatorProtocol {
    public var totalPages: Int {
        get { return self.numberOfPages }
        set (newValue) {
            self.numberOfPages = newValue
            self.alpha = self.numberOfPages <= 1 ? 0.0:1.0
        }
    }
    
    public var currentIndex: Int {
        get { return self.currentPage }
        set (newValue){ self.currentPage = newValue }
    }
    
    public var view: UIView {
        get {return self}
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.pageIndicatorTintColor = UIColor.lightGray
        self.currentPageIndicatorTintColor = UIColor.white
        self.backgroundColor = UIColor.clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.pageIndicatorTintColor = UIColor.lightGray
        self.currentPageIndicatorTintColor = UIColor.white
        self.backgroundColor = UIColor.clear
    }
}
