//
//  Dictionary+HCExtension.swift
//  HCSwift
//
//  Created by 陈宏超 on 2018/3/9.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import Foundation

public extension Dictionary {
    
    /// 将字典对象转为JSON字符串
    ///
    /// - Returns: 成功返回JSON字符串，否则返回nil
    public func hc_jsonString () -> String? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        let data:Data! = try? JSONSerialization.data(withJSONObject: self, options: [])
        return String(data:data,encoding: String.Encoding.utf8)
    }
}
