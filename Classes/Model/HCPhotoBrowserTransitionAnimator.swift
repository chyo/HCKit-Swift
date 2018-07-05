//
//  HCPhotoBrowserTransitionAnimator.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/15.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

/// 图片浏览动画基础类
public class HCPhotoBrowserAnimator:NSObject, UIViewControllerAnimatedTransitioning {
    
    /// 时长
    var transitionDuration = 0.35
    /// 来源控制器
    var fromVC:UIViewController!
    /// 目标控制器
    var toVC:UIViewController!
    /// 容器
    var containerView:UIView!
    /// 上下文
    var transitionContext:UIViewControllerContextTransitioning!
    
    /// 动画图片
    public var fromImage:UIImage?
    /// 动画起始位置
    public var fromFrame:CGRect!
    /// 动画目标位置
    public var toFrame:CGRect!
    
    public init(fromImage:UIImage?, fromFrame:CGRect, toFrame:CGRect) {
        self.fromImage = fromImage
        self.fromFrame = fromFrame
        self.toFrame = toFrame
        super.init()
    }
    
    /// 动画完成后需执行此方法
    public func completeTransition () {
        self.transitionContext.completeTransition(!(self.transitionContext.transitionWasCancelled))
    }
    
    /// 动画执行方法，需重写
    public func excuteTransition () {
        self.completeTransition()
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        fromVC = transitionContext.viewController(forKey: .from)
        toVC = transitionContext.viewController(forKey: .to)
        containerView = transitionContext.containerView
        self.transitionContext = transitionContext
        // 这边调用了动画执行方法
        self.excuteTransition()
    }
}

/// 图片浏览push动画
public class HCPhotoBrowserPresentAnimator: HCPhotoBrowserAnimator {
    public override func excuteTransition() {
        self.containerView.backgroundColor = UIColor.clear
        self.containerView.addSubview(self.toVC.view)
        self.toVC.view.alpha = 0.0
        let bg = UIView.init(frame: self.containerView.bounds)
        bg.backgroundColor = UIColor.black
        bg.alpha = 0.0
        self.containerView.addSubview(bg)
        let iv = UIImageView.init(frame: self.fromFrame)
        iv.image = self.fromImage
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        self.containerView.addSubview(iv)
        UIView.animate(withDuration: self.transitionDuration, animations: {
            iv.frame = self.toFrame
            bg.alpha = 1.0
        }) { (finish) in
            iv.removeFromSuperview()
            bg.removeFromSuperview()
            self.toVC.view.alpha = 1.0
            self.completeTransition()
        }
    }
}

/// 图片浏览pop动画
public class HCPhotoBrowserDismissAnimator: HCPhotoBrowserAnimator {
    
    public var fromAlpha:CGFloat = 1.0
    
    public override func excuteTransition() {
        self.containerView.backgroundColor = UIColor.clear
        self.fromVC.view.alpha = 0.0
        let bg = UIView.init(frame: self.containerView.bounds)
        bg.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        bg.alpha = fromAlpha
        self.containerView.addSubview(bg)
        let iv = UIImageView.init(frame: self.fromFrame)
        iv.image = self.fromImage
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        self.containerView.addSubview(iv)
        UIView.animate(withDuration: self.transitionDuration, animations: {
            iv.frame = self.toFrame
            bg.alpha = 0.0
        }) { (finish) in
            iv.removeFromSuperview()
            bg.removeFromSuperview()
            self.completeTransition()
        }
    }
}

