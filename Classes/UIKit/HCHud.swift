//
//  HCHud.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/21.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import SnapKit

/// 隐藏或显示Hud后执行的回调事件
public typealias HCHudCompleteHandler = (()->Void)

/// 指示器模式
///
/// - text: 文本
/// - loading: 加载
/// - loadingWithText: 带提示文字的加载
/// - progress: 进度
/// - progressWithText: 带提示文字的进度
public enum HCHudMode {
    case text, loading, loadingWithText, progress, progressWithText
}

/// HUD风格
///
/// - light: 亮色（白）
/// - dark: 暗色（黑）
public enum HCHudStyle {
    case light, dark
}

/**
 
 # 指示器组件 V1.0.0

 ## 支持两种风格
 初始化时设定HCHudStyle
 
 ## 支持五种模式
 初始化时设定HCHudMode
 
 ## 支持锁定触摸
 当Hud显示时如果要限制父控件的触摸时间，直接设定isUserInteractionEnabled=true即可
 
 */
public class HCHud: UIVisualEffectView {
    
    /// 提示文本，根据style自动配色，也可自定义颜色。支持多行文本，最大宽度为300px。
    public var label:UILabel?
    /// 指示器，根据style自动配色，也可自定义颜色
    public var indicator:UIActivityIndicatorView?
    /// Hud最小尺寸，默认(80,80)，如果mode设定为text，那么最小尺寸默认为(28,28)
    public var minSize:CGSize = CGSize.init(width: 80, height: 80) {
        didSet {
            if self.superview != nil {
                self.snp.updateConstraints { (make) in
                    make.width.greaterThanOrEqualTo(minSize.width)
                    make.height.greaterThanOrEqualTo(minSize.height)
                }
            }
        }
    }
    /// Hud是否正在显示
    public var isShowing:Bool {
        get { return self.alpha == 1.0 }
    }
    /// 隐藏Hud时是否从父组件移除（显示时会自动添加）
    public var removeOnHide:Bool = true
    /// 进度，进当mode=progress或progressWithText有效
    public var progress:CGFloat = 0 {
        didSet {
            self.progressLayer?.strokeEnd = progress
        }
    }
    
    /// 模式
    var mode:HCHudMode
    /// 风格
    var style:HCHudStyle
    /// 父容器
    weak var inView:UIView?
    /// 进度主视图
    var progressView:UIView?
    /// 进度视图
    var progressLayer:CAShapeLayer?
    
    deinit {
        print("HCHud deinit")
    }
    
    public init(in view:UIView, mode:HCHudMode, style:HCHudStyle) {
        self.mode = mode
        self.style = style
        self.inView = view
        var effect:UIVisualEffect
        if style == .light {
            effect = UIBlurEffect.init(style: .light)
        } else {
            effect = UIBlurEffect.init(style: .dark)
        }
        super.init(effect: effect)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        assert(false, "请使用 init(view, mode, style) 初始化")
        self.mode = .text
        self.style = .dark
        super.init(coder: aDecoder)
    }
    
    func setup () {
        self.alpha = 0.0
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
        self.isUserInteractionEnabled = false
        // 初始化加载指示器
        if self.mode == .loading || self.mode == .loadingWithText {
            self.indicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
            self.indicator?.hidesWhenStopped = false
            self.indicator?.startAnimating()
            self.contentView.addSubview(self.indicator!)
            self.indicator!.snp.makeConstraints { (make) in
                make.centerX.equalTo(self)
                if self.mode == .loading {
                    make.centerY.equalTo(self)
                } else {
                    make.top.equalTo(14)
                }
            }
        }
        // 设定纯文本的最小Size
        else if self.mode == .text {
            self.minSize = CGSize.init(width: 28, height: 28)
        }
        // 初始化进度指示器
        else if self.mode == .progress || self.mode == .progressWithText {
            self.progressView = UIView.init()
            self.progressView?.backgroundColor = UIColor.clear
            self.progressView?.layer.cornerRadius = 19
            self.progressView?.clipsToBounds = true
            self.progressView?.layer.borderColor = UIColor.white.cgColor
            self.progressView?.layer.borderWidth = 1.5
            self.contentView.addSubview(self.progressView!)
            self.progressView!.snp.makeConstraints { (make) in
                make.centerX.equalTo(self)
                make.width.equalTo(38)
                make.height.equalTo(38)
                if self.mode == .progress {
                    make.centerY.equalTo(self)
                } else {
                    make.top.equalTo(14)
                }
            }
            let path = UIBezierPath.init(arcCenter: CGPoint.init(x: 15, y: 15), radius: 7.5, startAngle: -0.5*CGFloat.pi, endAngle: 1.5*CGFloat.pi, clockwise: true)
            self.progressLayer = CAShapeLayer.init()
            self.progressLayer?.frame = CGRect.init(x: 4, y: 4, width: 30, height: 30)
            self.progressLayer?.fillColor = UIColor.clear.cgColor
            self.progressLayer?.strokeColor = UIColor.white.cgColor
            self.progressLayer?.strokeStart = 0
            self.progressLayer?.strokeEnd = 0
            self.progressLayer?.lineWidth = 15
            self.progressLayer?.path = path.cgPath
            self.progressView?.layer.addSublayer(self.progressLayer!)
        }
        // 初始化文本
        if self.mode != .loading && self.mode != .progress {
            self.label = UILabel.init()
            self.label?.backgroundColor = UIColor.clear
            self.label?.font = UIFont.systemFont(ofSize: 14)
            self.label?.textColor = UIColor.white
            self.label?.textAlignment = .center
            self.label?.numberOfLines = 0
            self.contentView.addSubview(self.label!)
            self.label?.snp.makeConstraints({ (make) in
                make.left.equalTo(14)
                make.right.equalTo(-14)
                make.bottom.equalTo(-14)
                make.width.lessThanOrEqualTo(300)
                if self.indicator != nil {
                    make.top.equalTo(self.indicator!.snp.bottom).offset(8)
                }
                else if self.progressView != nil {
                    make.top.equalTo(self.progressView!.snp.bottom).offset(8)
                }
                else {
                    make.top.equalTo(14)
                }
            })
        }
        
        if self.style == .light {
            let color = UIColor.init(red: 59/255.0, green: 59/255.0, blue: 59/255.0, alpha: 1)
            self.indicator?.color = color
            self.label?.textColor = color
            self.progressView?.layer.borderColor = UIColor.darkGray.cgColor
            self.progressLayer?.strokeColor = UIColor.darkGray.cgColor
            self.contentView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.8)
        }
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isUserInteractionEnabled {
            return self
        } else {
            return super.hitTest(point, with: event)
        }
    }

    /// 显示Hud
    ///
    /// - Parameter animated: 是否需要动画
    public func show (animated:Bool) {
        self.show(animated: animated, complete: nil)
    }
    
    /// 显示Hud
    ///
    /// - Parameters:
    ///   - animated: 是否需要动画
    ///   - complete: 显示后回调
    public func show (animated:Bool, complete:HCHudCompleteHandler?) {
        if self.superview == nil && self.inView != nil {
            self.inView!.addSubview(self)
            self.snp.makeConstraints { (make) in
                make.center.equalTo(self.inView!)
                make.width.greaterThanOrEqualTo(self.minSize.width)
                make.height.greaterThanOrEqualTo(self.minSize.height)
            }
        } else {
            self.superview?.bringSubview(toFront: self)
        }
        self.superview?.bringSubview(toFront: self)
        UIView.animate(withDuration: (animated ? 0.2:0), animations: {
            self.alpha = 1.0
        }, completion: { (finish) in
            complete?()
        })
    }
    
    /// 隐藏Hud
    ///
    /// - Parameter animated: 是否需要动画
    public func hide (animated:Bool) {
        self.superview?.bringSubview(toFront: self)
        self.hide(animated: animated, afterDelay: 0, complete: nil)
    }
    
    /// N秒后隐藏Hud
    ///
    /// - Parameters:
    ///   - animated: 是否需要动画
    ///   - afterDelay: 指定秒数
    ///   - complete: 隐藏后回调
    public func hide (animated:Bool, afterDelay:TimeInterval, complete:HCHudCompleteHandler?) {
        self.superview?.bringSubview(toFront: self)
        UIView.animate(withDuration: (animated ? 0.2:0), delay: afterDelay, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.alpha = 0.0
        }, completion: { (finish) in
            complete?()
            if self.removeOnHide {
                self.removeFromSuperview()
            }
        })
    }
    
    /// 显示并在指定时间后自动隐藏
    /// 
    /// - Parameters:
    ///   - afterDelay: 指定时间
    ///   - complete: 隐藏后回调
    public func toast (afterDelay:TimeInterval, complete: HCHudCompleteHandler?) {
        DispatchQueue.main.async {
            self.show(animated: true)
            self.hide(animated: true, afterDelay: afterDelay, complete: complete)
        }
    }

}
