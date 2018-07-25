//
//  HCCameraRequestOptions.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/7/24.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

/**
 ## 拍照参数
 
 */
public class HCCameraRequestOptions: NSObject {

    /// 是否保存到相册
    public var saveToAlbum:Bool = false
    /// 取景宽高比，默认0全屏，在非零的条件下，会设置一个取景框。
    public var cropRatio:CGFloat = 0
    /// 取景框缩进，当cropRatio!=0时有效
    let cropMargin:CGFloat = 22
    
    public override init() {
        super.init()
    }
}
