//
//  HCCalendarItem.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/6.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

public class HCCalendarItem: NSObject {
    
    /// 日期
    public let date:Date?
    /// 是否选中
    public var selected:Bool?
    
    /// 日
    public var day:Int! {
        get { return date != nil ? date!.hc_dateComponents().day : 0 }
    }
    /// 月
    public var month:Int! {
        get { return date != nil ? date!.hc_dateComponents().month : 0 }
    }
    /// 年
    public var year:Int! {
        get { return date != nil ? date!.hc_dateComponents().year! : 0 }
    }
    /// 是否周末
    public var isWeekend:Bool {
        get { return date != nil ? date!.hc_isWeekend() : false}
    }
    
    private override init() {
        self.date = Date.init()
        super.init()
    }
    
    public init(date:Date?) {
        self.date = date
        super.init()
    }
    
    
}
