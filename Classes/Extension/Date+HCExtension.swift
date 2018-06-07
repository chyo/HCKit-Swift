//
//  Date+HCExtension.swift
//  HCSwift
//
//  Created by 陈宏超 on 2018/3/12.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import Foundation

public extension Date {
    
    /// 获取详细的日历组件
    ///
    /// - Returns: 日历组件
    public func hc_dateComponents () -> DateComponents {
        return Calendar.current.dateComponents(in: TimeZone.current, from: self);
    }
    
    /// 获取本周第一天（默认是周天）
    ///
    /// - Returns: 本周第一天
    public func hc_firstDayOfWeek () -> Date {
        var components = self.hc_dateComponents();
        components.day! -= components.weekday!-1;
        return Calendar.current.date(from: components)!
    }
    
    /// 判断是否周末
    ///
    /// - Returns: true or false
    public func hc_isWeekend () -> Bool {
        let weekday = self.hc_dateComponents().weekday;
        if weekday == 1 || weekday == 7 {
            return true;
        } else {
            return false;
        }
    }
    
    /// 格式化日期
    ///
    /// - Parameter format: 格式化字符串，如 yyyyMMdd
    /// - Returns: 日期字符串
    public func hc_dateFormat (format:String) -> String {
        let fmt:DateFormatter = DateFormatter.init();
        fmt.calendar = Calendar.current;
        fmt.dateFormat = format;
        return fmt.string(from: self);
    }
    
    /// 每个月的最大天数
    ///
    /// - Returns: 天数
    public func hc_maxDaysInMonth () -> Int{
        let components = self.hc_dateComponents();
        if components.month! == 1 || components.month! == 3 || components.month! == 5 || components.month! == 7 || components.month! == 8 || components.month! == 10 ||
            components.month! == 12 {
            return 31;
        } else if components.month! == 2 {
            if components.year! % 4 == 0 {
                return 29;
            } else {
                return 28;
            }
        } else {
            return 30;
        }
    }
    
    /// 获取当前日期处于所属年份的第几天
    ///
    /// - Returns: 该年中的第几天，从1开始，如1月1日为第1天
    public func hc_dayOfYear () -> Int {
        let components = self.hc_dateComponents();
        let fmt = DateFormatter.init();
        fmt.dateFormat = "yyyyMMdd";
        let firstDayOfYear = fmt.date(from: "\(components.year!)0101");
        let different = self.timeIntervalSince(firstDayOfYear!)
        return Int(different/(3600*24))+1;
    }
    
    /// 返回上个月的同一天
    ///
    /// - Returns: 上个月同一天
    public func hc_lastMonth () -> Date {
        let calendar = Calendar.current
        var components = DateComponents.init()
        components.month = -1
        return calendar.date(byAdding: components, to: self)!
    }
    
    /// 返回本月第一天
    ///
    /// - Returns: 本月第一天
    public func hc_firstDayOfMonth () -> Date {
        var components = self.hc_dateComponents()
        components.day = 1
        return components.date!
    }
    
    /// 返回下个月同一天
    ///
    /// - Returns: 下个月同一天
    public func hc_nextMonth () -> Date {
        let calendar = Calendar.current
        var components = DateComponents.init()
        components.month = 1
        return calendar.date(byAdding: components, to: self)!
    }
    
    /// 差值运算符
    /// 计算日期1和日期2之间相差的天数，只计算day，不考虑时分秒。
    /// 即1月1日23:59:59与1月2日00:00:00秒相差1天。
    /// - Parameters:
    ///   - left: 日期1
    ///   - right: 日期2
    /// - Returns: 天数
    public static func - (left:Date, right:Date) -> Int {
        return left.hc_dayOfYear() - right.hc_dayOfYear()
    }
    
}
