//
//  HCCalendarMonth.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/7.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class HCCalendarMonth: NSObject {

    static let numbersPerPage = 42
    
    var date:Date!
    var dayArray:Array<HCCalendarItem>! = []
    
    /// 构造器
    ///
    /// - Parameters:
    ///   - date: 月份
    ///   - selectedItem: 选中的日期，inout参数，因为此值会被重新赋值
    init(date:Date!, selectedItem:inout HCCalendarItem?) {
        self.date = date
        super.init()
        self.itemsInMonth(date: date, selectedItem:&selectedItem )
    }
    
    func itemsInMonth (date:Date, selectedItem:inout HCCalendarItem?) {
        self.dayArray.removeAll()
        let count = date.hc_maxDaysInMonth()
        let weekday = date.hc_firstDayOfMonth().hc_dateComponents().weekday! - 1
        for _ in 0 ..< weekday {
            let item = HCCalendarItem.init(date: nil)
            self.dayArray.append(item)
        }
        let selectedComponents = selectedItem?.date?.hc_dateComponents()
        let firstDateOfMonth = date.hc_firstDayOfMonth()
        let calendar = Calendar.current
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
        let remain = HCCalendarMonth.numbersPerPage - self.dayArray.count
        for _ in 0 ..< remain {
            let item = HCCalendarItem.init(date: nil)
            self.dayArray.append(item)
        }
    }
}
