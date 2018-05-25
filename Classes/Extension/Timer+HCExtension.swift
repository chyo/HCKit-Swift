//
//  Timer+HCExtension.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/24.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import Foundation

public extension Timer {
    
    /// 使用此方法避免未调用invalidate所带来的循环引用问题
    ///
    /// - Parameters:
    ///   - ti: 时间间隔
    ///   - aTarget: 对象
    ///   - aSelector: 方法
    ///   - aInfo: 数据
    ///   - yesOrNo: 是否重复
    /// - Returns: Timer
    public class func hc_scheduledTimer(timeInterval ti: TimeInterval, target aTarget: NSObjectProtocol, selector aSelector: Selector, userInfo aInfo: Any?, repeats yesOrNo: Bool) -> Timer {
        let proxy = HCWeakTimerProxy.init(target: aTarget, sel: aSelector)
        let timer = Timer.scheduledTimer(timeInterval: ti, target: proxy, selector: aSelector, userInfo:aInfo, repeats: yesOrNo)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        proxy.timer = timer
        return timer
    }
}
