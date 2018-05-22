//
//  String+HCExtension.swift
//  HCSwift
//
//  Created by 陈宏超 on 2018/3/9.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import Foundation
import CCommonCrypto

public extension String {
    
    /// 从起始位置（默认0）截取长度为length的字符串
    ///
    /// - Parameter length: 截取长度，必须 >= 1
    /// - Returns: 参数有误或截取失败均返回nil，截取成功返回子字符串
    public func hc_subString (length:Int) -> String? {
        guard length >= 1 else {
            print("error: 'length' must be greater than or equal to 1")
            return nil
        }
        let aLength = min(self.count.hashValue, length)
        guard aLength > 0 else {
            return nil
        }
        let endIndex = String.Index.init(encodedOffset: aLength)
        return String(self[..<endIndex])
    }
    
    /// 从指定位置截取字符串
    ///
    /// - Parameter from: 指定位置，必须 >= 0
    /// - Returns: 参数有误或截取失败均返回nil，截取成功返回子字符串
    public func hc_subString (from:Int) -> String? {
        guard from >= 0 else {
            print("error: 'from' must be greater than or equal to 0")
            return nil
        }
        guard self.count.hashValue - from > 0 else {
            return nil
        }
        let startIndex = self.index(self.startIndex, offsetBy: from)
        return String(self[startIndex...])
    }
    
    /// 从指定位置截取指定长度的字符串
    ///
    /// - Parameters:
    ///   - from: 指定位置，必须 >= 0
    ///   - length: 截取长度，必须 >= 1
    /// - Returns: 参数有误或截取失败均返回nil，截取成功返回子字符串
    public func hc_subString(from:Int, length:Int) -> String? {
        guard from >= 0 else {
            print("error: 'from' must be greater than or equal to 0")
            return nil
        }
        guard from < self.count.hashValue else {
            print("error: 'from' must be less than length of string")
            return nil
        }
        guard length >= 1 else {
            print("error: 'length' must be greater than or equal to 1")
            return nil
        }
        let maxLength = min(self.count.hashValue - from, length)
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: from+maxLength)
        return String(self[startIndex..<endIndex])
    }
    
    /// 获取32位MD5加密字符串
    ///
    /// - Returns: 32位大写加密字符串
    public func hc_md5 () -> String? {
        guard self.count.hashValue > 0 else {
            return nil
        }
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        var hash = String()
        for i in 0 ..< digestLen {
            hash += String.init(format: "%02x", result[i])
        }
        // Swift4.1之前可以使用 result.deinitialize()
        result.deinitialize(count:digestLen)
        return hash.uppercased()
    }
    
    /// 将JSON字符串转化为字典对象，字典的KEY必须是String类型，否则会失败
    ///
    /// - Returns: 成功返回字典对象，失败返回nil
    public func hc_jsonDictionary () -> Dictionary<String, Any>? {
        let data:Data = self.data(using: String.Encoding.utf8)!
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return json as? Dictionary<String, Any>
    }
}
