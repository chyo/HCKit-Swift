//
//  HCPhotoVC.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/8.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

/// 图片选择回调
public typealias HCPhotoSelectionHandler = ((_ photoArray:Array<HCPhotoItem>)->Void)

/**
 # 照片选择器 V1.0.0
 
 ## 需要配置
 Privacy - Photo Library Usage Description
 
 ## 处理参数
 目前支持对选择的照片质量、生成的缩略图大小、缓存路径等参数进行设置，详见HCPhotoRequestOptions
 
 */
public class HCPhotoVC: UINavigationController {
    
    deinit {
//        print("HCPhotoVC deinit")
    }
    
    /// 显示照片选择控制器
    ///
    /// - Parameters:
    ///   - fromViewController: 来源控制器
    ///   - options: 图片处理参数
    ///   - selectionHandler: 回调
    /// - Returns: photoVC
    static public func showsPhotoVC (fromViewController:UIViewController, options:HCPhotoRequestOptions,  selectionHandler:@escaping HCPhotoSelectionHandler) -> HCPhotoVC {
        let photoListVC = HCPhotoListVC.init(nibName: nil, bundle: nil)
        photoListVC.selectionHandler = selectionHandler
        photoListVC.options = options
        let photoVC = HCPhotoVC.init(rootViewController: photoListVC)
        fromViewController.present(photoVC, animated: true, completion: nil)
        return photoVC
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
}
