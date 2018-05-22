//
//  UIViewController+HCExtension.swift
//  HCSwift
//
//  Created by 陈宏超 on 2018/5/17.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    /// 设置导航栏背景色是否透明
    ///
    /// - Parameter transparent: ture 透明 false 不透明
    public func hc_setNavigationBarTransparent (transparent:Bool) {
        if !transparent {
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = nil
            return
        }
        let bundle = Bundle.main
        let image = UIImage.init(named: "hcTransparent", in: bundle, compatibleWith: nil)
        self.navigationController?.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = image
    }
    
    /// 设置导航栏背景色、文字颜色、标题属性
    ///
    /// - Parameters:
    ///   - barTintColor: 导航栏背景色
    ///   - tintColor: 左右按钮文字颜色
    ///   - titleTextAttributes: 标题属性
    public func hc_setNavigationBarStyle (barTintColor:UIColor?, tintColor:UIColor?, titleTextAttributes:[NSAttributedStringKey:Any]?){
        self.navigationController?.navigationBar.barTintColor = barTintColor
        self.navigationController?.navigationBar.tintColor = tintColor
        self.navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
    }
}
