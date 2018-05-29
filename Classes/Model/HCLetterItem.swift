//
//  HCLetterItem.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/28.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

public class HCLetterItem: NSObject {
    
    public var letter:String! = "#"
    public var data:Any?
    
    public init(letter:String!, data:Any?) {
        self.letter = letter
        self.data = data
        super.init()
    }
}
