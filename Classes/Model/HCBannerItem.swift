//
//  HCBannerItem.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/23.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

public class HCBannerItem: NSObject {

    public var data:Any?
    public var imgUrl:String?
    
    public init(data:Any?, imgUrl:String?) {
        self.data = data
        self.imgUrl = imgUrl
        super.init()
    }
}
