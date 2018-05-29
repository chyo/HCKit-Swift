//
//  HCConfig.swift
//  HCSwift
//
//  Created by 陈宏超 on 2018/5/17.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import CoreLocation

let FrameworkName = "HCKit_Swift"

public class HCConfig : NSObject {
    
    static public func hc_bundleName () -> String!{
        var bundle = Bundle.init(for: HCConfig.self)
        let resourcePath:String? = bundle.path(forResource: FrameworkName, ofType: "framework", inDirectory: "Frameworks")
        if resourcePath != nil {
            bundle = Bundle.init(path: resourcePath!)!
        }
        let bundleName = bundle.object(forInfoDictionaryKey: "CFBundleName") as! String
        return bundleName.replacingOccurrences(of: "-", with: "_")
    }
    
    /// 获取资源文件bundle
    ///
    /// - Returns: nil or bundle
    static public func hc_resourceBundle () -> Bundle?{
        let mainBundle = Bundle.init(for: HCConfig.self)
        // 作为pods引入的库时编译后会被打包进Frameworks文件夹里。
        var resourcePath:String? = mainBundle.path(forResource: FrameworkName, ofType: "framework", inDirectory: "Frameworks")
        if resourcePath != nil {
            let bundle = Bundle.init(path: resourcePath!)
            resourcePath = bundle?.path(forResource: "resources", ofType: "bundle")
        } else {
            resourcePath = mainBundle.path(forResource: "resources", ofType: "bundle")
        }
        return Bundle.init(path: resourcePath!)
    }
    
    /// 弹出常规的UIAlertController
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 内容
    ///   - cancelTitle: 取消按钮标题
    ///   - cancelHandler: 取消按钮事件
    ///   - confirmTitle: 确认按钮标题，风格为UIAlertActionStyle.destructive
    ///   - confirmHandler: 确认按钮事件
    static public func hc_alert (title:String?, message:String?, cancelTitle:String?, cancelHandler:((UIAlertAction) -> Swift.Void)? = nil, confirmTitle:String?, confirmHandler:((UIAlertAction) -> Swift.Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            if cancelTitle != nil {
                let cancelAction = UIAlertAction.init(title: cancelTitle, style: UIAlertActionStyle.cancel, handler: cancelHandler)
                alert.addAction(cancelAction)
            }
            if confirmTitle != nil {
                let confirmAction = UIAlertAction.init(title: confirmTitle, style: UIAlertActionStyle.destructive, handler:confirmHandler)
                alert.addAction(confirmAction)
            }
            let rootVC = UIApplication.shared.keyWindow?.rootViewController
            rootVC!.present(alert, animated: true, completion: nil)
        }
    }
    
    /// 判断是否允许访问相机，如果未选择会自动弹出授权提示
    ///
    /// - Parameters:
    ///   - openSettingsIfNeeded: 当权限未被允许时是否打开设置
    ///   - authorizationHandler: true 已授权 false 未授权
    static public func hc_isAuthorizedCamera (openSettingsIfNeeded:Bool, authorizationHandler: @escaping (_ granted:Bool) ->Void) {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if status == AVAuthorizationStatus.authorized {
            authorizationHandler(true)
        }
        else if status == AVAuthorizationStatus.notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                authorizationHandler(granted)
            }
        }
        else if openSettingsIfNeeded {
            authorizationHandler(false)
            self.hc_alert(title: "相机访问受限", message: "请前往设置-隐私-相机中启用访问权限", cancelTitle: "知道了", cancelHandler: nil, confirmTitle: "前往设置") { (action) in
                UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
            }
        }
        else {
            authorizationHandler(false)
        }
    }
    
    /// 判断是否允许访问照片，如果未选择会自动弹出授权提示
    ///
    /// - Parameters:
    ///   - openSettingsIfNeeded: 当权限未被允许时是否打开设置
    ///   - authorizationHandler: true 已授权 false 未授权
    static public func hc_isAuthorizedPhoto (openSettingsIfNeeded:Bool, authorizationHandler: @escaping (_ granted:Bool) ->Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.authorized {
            authorizationHandler(true)
        }
        else if status == PHAuthorizationStatus.notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                authorizationHandler(status==PHAuthorizationStatus.authorized)
            }
        }
        else if openSettingsIfNeeded {
            authorizationHandler(false)
            self.hc_alert(title: "照片访问受限", message: "请前往设置-隐私-照片中启用访问权限", cancelTitle: "知道了", cancelHandler: nil, confirmTitle: "前往设置") { (action) in
                UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
            }
        }
        else {
            authorizationHandler(false)
        }
    }
    
    /// 判断是否允许访问麦克风，如果未选择会自动弹出授权提示。
    /// 模拟器会返回已授权
    /// - Parameters:
    ///   - openSettingsIfNeeded: 当权限未被允许时是否打开设置
    ///   - authorizationHandler: true 已授权 false 未授权
    static public func hc_isAuthorizedMicrophone (openSettingsIfNeeded:Bool, authorizationHandler: @escaping (_ granted:Bool) ->Void) {
        let permission = AVAudioSession.sharedInstance().recordPermission()
        if permission == AVAudioSessionRecordPermission.granted {
            authorizationHandler(true)
        }
        else if permission == AVAudioSessionRecordPermission.undetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                authorizationHandler(granted)
            }
        }
        else if openSettingsIfNeeded {
            authorizationHandler(false)
            self.hc_alert(title: "麦克风访问受限", message: "请前往设置-隐私-麦克风中启用访问权限", cancelTitle: "知道了", cancelHandler: nil, confirmTitle: "前往设置") { (action) in
                UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
            }
        }
        else {
            authorizationHandler(false)
        }
    }
    
    /// 判断是否允许定位，如果未选择会返回false，不会自动弹出选择。
    ///
    /// - Parameters:
    ///   - openSettingsIfNeeded: 当权限未被允许时是否打开设置
    ///   - authorizationHandler: true 已授权 false 未授权
    static public func hc_isAuthorizedLocation (openSettingsIfNeeded:Bool, authorizationHandler: @escaping (_ granted:Bool) ->Void) {
        let status = CLLocationManager.authorizationStatus()
        if CLLocationManager.locationServicesEnabled() && (status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse) {
            authorizationHandler(true)
        }
        else if status == CLAuthorizationStatus.notDetermined {
            authorizationHandler(false)
        }
        else if openSettingsIfNeeded {
            authorizationHandler(false)
            self.hc_alert(title: "位置访问受限", message: "请前往设置-隐私-位置中启用访问权限", cancelTitle: "知道了", cancelHandler: nil, confirmTitle: "前往设置") { (action) in
                UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
            }
        }
        else {
            authorizationHandler(false)
        }
    }
}
