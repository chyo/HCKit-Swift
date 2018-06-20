//
//  HCPhotoRequestOptions.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/20.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

/// 照片选择处理参数
public class HCPhotoRequestOptions: NSObject {
    
    /// 每次最大选择照片数，默认1.0
    public var maximumNumber:Int = 1
    /// 缩略图宽度，高度会等比例缩放，默认nil，不处理缩略图
    public var thumbnailWidth:CGFloat?
    /// 转存到缓存路径时的jpg图片质量，默认1.0
    public var compressionQuality:CGFloat = 1
    /// 缓存路径，默认SearchPathDirectory.cachesDirectory
    public var cacheDirectory:String!
    
    public init(maximumNumber:Int) {
        self.maximumNumber = maximumNumber
        self.cacheDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        super.init()
    }
    
    public override init() {
        thumbnailWidth = 200
        self.cacheDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        super.init()
    }
    
}
