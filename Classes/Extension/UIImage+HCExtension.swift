//
//  UIImage+HCExtension.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/11.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

public extension UIImage {
    
    /// 返回一个目标宽度的图片，高度自动等比缩放
    ///
    /// - Parameter width: 目标宽度
    /// - Returns: 图片
    public func hc_fixToWidth (width:CGFloat) -> UIImage?{
        let scale = width / self.size.width
        let height = self.size.height * scale
        let size = CGSize.init(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect.init(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
