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
 */
public class HCPhotoVC: UINavigationController, UINavigationControllerDelegate {

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
        self.delegate = self
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == UINavigationControllerOperation.push && fromVC.isKind(of: HCPhotoListVC.classForCoder()) && toVC.isKind(of: HCPhotoBrowserVC.classForCoder()) {
            let listVC = fromVC as! HCPhotoBrowserAnimatorProtocal
            let browserVC = toVC as! HCPhotoBrowserAnimatorProtocal
            listVC.prepare()
            let animator = HCPhotoBrowserPushAnimator.init(fromImage: listVC.animationImage()!, fromFrame: listVC.animationFrame(image: nil), toFrame: browserVC.animationFrame(image: listVC.animationImage()))
            return animator
        }
        else if operation == .pop && fromVC.isKind(of: HCPhotoBrowserVC.classForCoder()) && toVC.isKind(of: HCPhotoListVC.classForCoder()) {
            let listVC = toVC as! HCPhotoBrowserAnimatorProtocal
            let browserVC = fromVC as! HCPhotoBrowserAnimatorProtocal
            listVC.prepare()
            let animator = HCPhotoBrowserPopAnimator.init(fromImage: browserVC.animationImage()!, fromFrame: browserVC.animationFrame(image:nil), toFrame: listVC.animationFrame(image: nil))
            return animator
        }
        else {
            return nil
        }
    }
}
