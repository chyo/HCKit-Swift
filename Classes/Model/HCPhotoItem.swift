//
//  HCPhotoItem.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/11.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

public class HCPhotoItem: NSObject {
    
    /// 缩略图
    public var thumbnail:UIImage?
    /// 完整图的地址
    public var fullImageUrl:URL?
    
    /// 将图片以jpg的形式转存到cache目录下，同步执行。
    ///
    /// - Parameters:
    ///   - fullImage: 原图
    ///   - thumbnailWidth: 缩略图目标宽度，高度根据比例缩放。传nil时缩略图和原图一致
    ///   - quality: 质量，默认1.0，如果不需要这个参数，在构造函数时可以不必传递nil
    public init (fullImage:UIImage?, thumbnailWidth:CGFloat?, quality:CGFloat? = 1.0) {
        super.init()
        if fullImage != nil {
            if thumbnailWidth != nil && fullImage!.size.width > thumbnailWidth! {
                self.thumbnail = fullImage?.hc_fixToWidth(width: thumbnailWidth!)
            } else {
                self.thumbnail = fullImage
            }
            let data = UIImageJPEGRepresentation(fullImage!, (quality != nil ? quality! : 1.0))
            let fileName = String.init(format: "%.0f", Date.init().timeIntervalSince1970*10000) + ".jpg"
            var path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
            path.append("/"+fileName)
            do {
                let url = URL.init(fileURLWithPath: path)
                try data?.write(to: url, options: Data.WritingOptions.atomic)
                self.fullImageUrl = url
            } catch (let error) {
                print(error)
            }
        }
    }
}
