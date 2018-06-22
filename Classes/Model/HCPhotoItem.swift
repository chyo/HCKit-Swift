//
//  HCPhotoItem.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/11.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

/// 照片选择对象
public class HCPhotoItem: NSObject {
    
    /// 缩略图
    public var thumbnail:UIImage?
    /// 完整图的地址
    public var fullImageUrl:String?
    
    /// 将图片以指定参数+jpg的形式转存到指定目录下，同步执行。
    ///
    /// - Parameters:
    ///   - fullImage: 原图
    ///   - options: 处理参数，可以不传
    public init (fullImage:UIImage!, options:HCPhotoRequestOptions? = nil) {
        super.init()
        let data = UIImageJPEGRepresentation(fullImage, (options?.compressionQuality != nil ? options!.compressionQuality : 1.0))
        if options?.thumbnailWidth != nil && fullImage.size.width > options!.thumbnailWidth! {
            self.thumbnail = UIImage.init(data: data!)!.hc_fixToWidth(width: options!.thumbnailWidth!)
        } else {
            self.thumbnail = UIImage.init(data: data!)!
        }
        
        let fileName = String.init(format: "%.0f", Date.init().timeIntervalSince1970*10000) + ".jpg"
        var path:String!
        if options == nil {
            path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        } else {
            path = options!.cacheDirectory
        }
        path.append("/"+fileName)
        do {
            let url = URL.init(fileURLWithPath: path)
            try data?.write(to: url, options: Data.WritingOptions.atomic)
            self.fullImageUrl = path
        } catch (let error) {
            print(error)
        }
    }
    
    public init(thumbnail:UIImage?, fullImageUrl:String) {
        self.thumbnail = thumbnail
        self.fullImageUrl = fullImageUrl
        super.init()
    }
}
