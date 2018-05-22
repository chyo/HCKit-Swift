//
//  HCTimer.swift
//  HCSwift
//
//  Created by 陈宏超 on 2018/5/18.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

/// 计时器
public class HCTimer: NSObject {

    var displayLink:CADisplayLink?
    var startTimeInterval:TimeInterval = 0
    var countingHandler:((HCTimer)->Void)?
    /// 总的时间（秒）,只读
    public private(set) var totalSeconds:Int = 0
    /// 经过的时间（秒），只读
    public private(set) var passedSeconds:Int = 0
    
    public override init() {
        super.init()
    }
    
    /// 开始计时
    ///
    /// - Parameter countingHandler: 每秒计时回调
    public func startCounting (_ totalSeconds:Int, countingHandler:((HCTimer)->Void)?){
        self.countingHandler = countingHandler
        self.totalSeconds = totalSeconds
        if self.totalSeconds == 0{
            self.callHandler()
            return
        }
        self.passedSeconds = 0
        self.startTimeInterval = Date.init().timeIntervalSince1970*1000
        self.displayLink?.invalidate()
        self.displayLink = CADisplayLink.init(target: self, selector: #selector(counting(timer:)))
        self.displayLink?.frameInterval = 60
        self.displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    /// 停止计时
    public func stopCounting () {
        guard self.displayLink != nil else {
            return
        }
        self.displayLink?.remove(from: RunLoop.current, forMode: RunLoopMode.commonModes)
        self.displayLink?.invalidate()
        self.displayLink = nil
    }
    
    /// 回调事件
    func callHandler (){
        weak var weakSelf = self
        self.countingHandler?(weakSelf!)
        if self.passedSeconds >= self.totalSeconds {
            self.stopCounting()
        }
    }
    
    /// 计时
    ///
    /// - Parameter timer: 定时器
    @objc func counting (timer:CADisplayLink) {
        self.passedSeconds = Int((Date.init().timeIntervalSince1970*1000-self.startTimeInterval)/1000)
        self.callHandler()
    }
}
