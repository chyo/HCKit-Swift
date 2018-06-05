//
//  HCLetterItem.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/28.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

/// 字母组件Model
public class HCLetterItem: NSObject {
    
    /// 字母，默认#
    public var letter:String! = "#"
    /// 关联的数据，可为nil
    public var data:Any?
    
    public init(letter:String!, data:Any?) {
        self.letter = letter
        self.data = data
        super.init()
    }
}
