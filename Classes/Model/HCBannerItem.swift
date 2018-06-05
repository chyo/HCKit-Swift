//
//  HCBannerItem.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/23.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

/// 轮播组件Model
public class HCBannerItem: NSObject {

    /// 任意数据，可为nil
    public var data:Any?
    /// 图片绝对地址
    public var imgUrl:String!
    
    public init(data:Any?, imgUrl:String!) {
        self.data = data
        self.imgUrl = imgUrl
        super.init()
    }
}
