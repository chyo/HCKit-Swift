//
//  HCWeakTimerProxy.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/24.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

/**
 ## 处理timer强引用类 V1.0.0
 
 用法：使用init(:,:)方法初始化后，赋值给Timer的target，再将timer赋值给此类的timer。
 
 详见Timer+HCExtension.swift
 */
public class HCWeakTimerProxy: NSObject {
    
    weak var target:NSObjectProtocol?
    var sel:Selector?
    /// required，实例化timer之后需要将timer赋值给proxy，否则就算target释放了，timer本身依然会继续运行
    public weak var timer:Timer?
    
    public required init(target:NSObjectProtocol?, sel:Selector?) {
        self.target = target
        self.sel = sel
        super.init()
        // 加强安全保护
        guard target?.responds(to: sel) == true else {
            return
        }
        // 将target的selector替换为redirectionMethod，该方法会重新处理事件
        let method = class_getInstanceMethod(self.classForCoder, #selector(HCWeakTimerProxy.redirectionMethod))!
        class_replaceMethod(self.classForCoder, sel!, method_getImplementation(method), method_getTypeEncoding(method))
    }
    
    @objc func redirectionMethod () {
        // 如果target未被释放，则调用target方法，否则释放timer
        if self.target != nil {
            self.target!.perform(self.sel)
        } else {
            self.timer?.invalidate()
            print("HCWeakProxy: invalidate timer.")
        }
    }
}
