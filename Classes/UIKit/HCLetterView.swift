//
//  HCLetterView.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/28.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import SnapKit

/// 指示器协议，具体应用参考HCLetterHudView
public protocol HCLetterHudProtocol {
    
    /// 指示器视图，return self
    var view:UIView {get}
    /// 需要显示指示器
    func show ()
    /// 需要隐藏指示器
    func hide ()
    /// 选中的字符变化
    ///
    /// - Parameter item: 数据
    func letterDidChanged (item:HCLetterItem)
}

/// 选中回调
public typealias HCLetterViewSelectionHandler = ((_ view:HCLetterView?, _ selectedIndex:Int) -> Void)

/**
 # 字母组件 V1.0.0
 常见的应用场景：通讯录侧边字母，设置完相关属性后请调用reloadData刷新界面
 
 请尽量使用代码的方式创建此视图，并且不添加高度约束，或者添加高度约束为 >= 0，高度会根据字母数量变化
 
 ## 支持自定义Hud
 如需自定义hud，请在视图中遵循HCLetterHudProtocol协议，协议中的view属性返回self。自定义视图需手动添加到指定的父视图上，比如viewControll.view，并且赋值给letterview
 */
public class HCLetterView: UIView {
    
    /// 选中的字母
    var selectedIndex:Int?
    
    /// 数据
    public var letterArray:Array<HCLetterItem>! = []
    /// 字母高度，默认30
    public var heightForItem:CGFloat! = 30
    /// 字体
    public var font:UIFont!
    /// 文字颜色
    public var textColor:UIColor!
    /// 常规背景色，默认透明
    public var defaultBackgroundColor:UIColor!
    /// 手指长按时的高亮背景色，默认黑色透明度0.1，
    public var highlightedBackgroundColor:UIColor!
    /// 是否显示指示器
    public var letterHudEnabled:Bool = true
    /// 指示器视图，可以自定义，但必须实现HCLetterHudProtocol协议，指示器需自己添加到指定的父控件上
    public var letterHud:HCLetterHudProtocol? {
        willSet (newValue){
            if newValue?.view != letterHud?.view {
                letterHud?.view.removeFromSuperview()
            }
        }
    }
    /// 字母选择回调
    public var selectionHandler:HCLetterViewSelectionHandler?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup () {
        self.isUserInteractionEnabled = true
        self.defaultBackgroundColor = UIColor.clear
        self.highlightedBackgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1)
        self.backgroundColor = self.defaultBackgroundColor
        self.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.light)
        self.textColor = UIColor.black
        self.letterHud = HCLetterHudView.init(effect: UIBlurEffect.init(style: UIBlurEffectStyle.light))
    }
    
    /// 刷新数据
    public func reloadData () {
        if self.superview != nil && self.letterHud != nil && self.letterHud!.view.superview == nil {
            self.superview?.addSubview(self.letterHud!.view)
            self.letterHud!.view.snp.makeConstraints { (make) in
                make.center.equalTo(self.superview!)
                make.width.equalTo(100)
                make.height.equalTo(100)
            }
        }
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        var topLabel:UILabel?
        let count = self.letterArray.count
        for i in 0..<count {
            let label = UILabel.init()
            label.backgroundColor = UIColor.clear
            label.textAlignment = NSTextAlignment.center
            label.textColor = self.textColor
            label.font = self.font
            label.text = self.letterArray[i].letter
            self.addSubview(label)
            label.snp.makeConstraints { (make) in
                if topLabel == nil {
                    make.top.equalTo(0)
                } else {
                    make.top.equalTo(topLabel!.snp.bottom)
                }
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.height.equalTo(self.heightForItem)
                if i == count-1 {
                    make.bottom.equalTo(0)
                }
            }
            topLabel = label
        }
    }
    
    func onTouch (_ touches: Set<UITouch>) {
        let point = touches.first!.location(in: self)
        var index:Int!
        if point.y < 0 {
            index = 0
        } else if (point.y > self.bounds.size.height) {
            index = self.letterArray.count - 1
        } else {
            index = Int(point.y / self.heightForItem)
        }
        index = min(self.letterArray.count - 1, max(0, index))
        if self.selectedIndex != index {
            self.selectedIndex = index
            self.letterHud?.letterDidChanged(item: self.letterArray[index])
            weak var weakSelf = self
            self.selectionHandler?(weakSelf, self.selectedIndex!)
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = self.highlightedBackgroundColor
        if self.letterHudEnabled {
            self.letterHud?.show()
            if self.letterHud != nil {
                self.superview?.bringSubview(toFront: self.letterHud!.view)
            }
        }
        self.onTouch(touches)
        super.touchesBegan(touches, with: event)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.onTouch(touches)
        super.touchesMoved(touches, with: event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = self.defaultBackgroundColor
        if self.letterHudEnabled {
            self.letterHud?.hide()
        }
        super.touchesEnded(touches, with: event)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = self.defaultBackgroundColor
        if self.letterHudEnabled {
            self.letterHud?.hide()
        }
        super.touchesCancelled(touches, with: event)
    }
}
