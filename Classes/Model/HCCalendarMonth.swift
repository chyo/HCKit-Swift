//
//  HCCalendarMonth.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/7.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

/// 月历
class HCCalendarMonth: NSObject {

    /// 每页的item数量，一个月的周分布最多是6周，一周7天，因此是42
    static let numbersPerPage = 42
    /// 月份
    var date:Date!
    /// 日期数组，上个月和下个月的部分同样使用calendarItem，但对应的date=nil
    var dayArray:Array<HCCalendarItem>! = []
    
    /// 构造器
    ///
    /// - Parameters:
    ///   - date: 月份
    ///   - selectedItem: 默认选中的日期，inout参数，因为此值会被重新赋值
    init(date:Date!, selectedItem:inout HCCalendarItem?) {
        self.date = date
        super.init()
        self.itemsInMonth(date: date, selectedItem:&selectedItem )
    }
    
    func itemsInMonth (date:Date, selectedItem:inout HCCalendarItem?) {
        self.dayArray.removeAll()
        let count = date.hc_maxDaysInMonth()
        let firstDateOfMonth = date.hc_firstDayOfMonth()
        /// 判断当前月的第一天是周几，补足前面几天用于占位
        let weekday = firstDateOfMonth.hc_dateComponents().weekday! - 1
        for _ in 0 ..< weekday {
            let item = HCCalendarItem.init(date: nil)
            self.dayArray.append(item)
        }
        let selectedComponents = selectedItem?.date?.hc_dateComponents()
        let calendar = Calendar.current
        // 添加当前月的日期
        for i in 0 ..< count {
            var components = DateComponents.init()
            components.day = i
            let item = HCCalendarItem.init(date: calendar.date(byAdding: components, to: firstDateOfMonth))
            if selectedComponents?.year == item.year && selectedComponents?.month == item.month && selectedComponents?.day == item.day {
                item.selected = true
                selectedItem = item
            } else {
                item.selected = false
            }
            self.dayArray.append(item)
        }
        // 补足最后一周的空缺占位
        let remain = HCCalendarMonth.numbersPerPage - self.dayArray.count
        for _ in 0 ..< remain {
            let item = HCCalendarItem.init(date: nil)
            self.dayArray.append(item)
        }
    }
}
