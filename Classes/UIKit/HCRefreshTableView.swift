//
//  HCRefreshTableView.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/29.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import SnapKit

/**
 # 下拉刷新组件 V1.0.0
 
 需实现refreshHandler回调，否则无法触发。
 
 ## 支持下拉刷新
 内置下拉刷新动画，可自定义，参考HCRefreshHeaderView实现，并赋值给refreshHeaderView。
 
 ## 支持获取更多
 内置获取更多动画，可自定义，参考HCRefreshFooterView实现，并赋值给refrehsFooterView
 
 */
public class HCRefreshTableView: UITableView, HCPullToRefreshProtocol {
    
    /// 原始缩进量
    var originalContentInsets:UIEdgeInsets!
    
    public var refreshHandler: HCPullToRefreshHandler?
    
    public override var contentOffset: CGPoint {
        didSet {
            // 当偏移量发生变化时处理动画
            self.contentOffsetDidChange(self.contentOffset)
        }
    }
    
    public var refreshState: HCPullToRefreshState! = .stop
    
    public var refreshHeaderView:HCPullToRefreshViewProtocol? {
        willSet (newValue) {
            if newValue?.view != refreshHeaderView?.view {
                refreshHeaderView?.view.removeFromSuperview()
            }
        }
        didSet {
            guard refreshHeaderView != nil && refreshHeaderView!.view.superview == nil else {return}
            self.addSubview(refreshHeaderView!.view)
            refreshHeaderView!.view.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.snp.top)
                make.centerX.equalTo(self)
                make.width.equalTo(self)
                make.height.equalTo(self.refreshHeaderView!.heightForView)
            }
        }
    }
    
    public var refreshFooterView: HCPullToRefreshViewProtocol? {
        didSet {
            if refreshFooterView == nil {
                self.tableFooterView = nil
            } else {
                refreshFooterView!.view.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: refreshFooterView!.heightForView)
                self.tableFooterView = refreshFooterView!.view
            }
        }
    }

    deinit {
        print("HCRefreshTableView deinit")
    }
    
    public override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    public override func safeAreaInsetsDidChange() {
        // iPhoneX此方法会触发两次，第一次bottom缩进为0，第二次为34
        if #available(iOS 11.0, *) {
            super.safeAreaInsetsDidChange()
            self.originalContentInsets = self.safeAreaInsets
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        if self.refreshFooterView != nil {
            self.refreshFooterView?.view.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.refreshFooterView!.heightForView)
        }
        
        if self.originalContentInsets == nil {
            if #available(iOS 11.0, *) {
                self.originalContentInsets = self.safeAreaInsets
            } else {
                self.originalContentInsets = self.contentInset
            }
        }
    }
    
    func contentOffsetDidChange(_ point: CGPoint) {
        // 当下拉/上托可用，并且列表未处于加载中的动画时才判断拖动事件
        guard originalContentInsets != nil && (self.refreshHeaderView?.enabled == true || self.refreshFooterView?.enabled == true) && self.refreshState != .loading else {
            return
        }
        let offsetY = point.y + self.originalContentInsets.top
        // 判断是否是下拉，并且下拉刷新是否启用
        if offsetY <= 0 && self.refreshHeaderView?.enabled == true {
            // 手指释放，并且处于减速状态时判断是否已经拖动到可以刷新的位置，因为reloadData等操作也会触发contentOffset的变化，所以加一个减速判断
            if !self.isDragging && fabs(offsetY) > self.refreshHeaderView!.offsetToBeganLoading {
                self.startRefreshingAnimation()
                return
            }
            // 当列表不处于拖动状态，也不处于减速状态时，不继续处理。因为列表初始化时，contentOffset受缩进影响，会变化，因此要加拖动判断。加了拖动判断后，如果手指释放了，处于减速状态也希望能有动画，因此还要加上减速判断
            if !self.isDragging && !self.isDecelerating {
                return
            }
            self.refreshState = .pulling
            self.refreshHeaderView?.pullAnimation(fabs(offsetY))
        }
        // 判断拖动获取更多
        else if (offsetY > 0 && self.refreshFooterView?.enabled == true){
            var contentHeight = self.contentSize.height
            if self.refreshFooterView != nil {
                contentHeight -= self.refreshFooterView!.heightForView
            }
            var height = self.frame.size.height
            // 实际可视高度要减去顶部缩进高度
            if self.originalContentInsets != nil {
                height -= self.originalContentInsets.top
            }
            if (contentHeight < height && offsetY > self.refreshFooterView!.offsetToBeganLoading) || (contentHeight - height + self.refreshFooterView!.offsetToBeganLoading) < offsetY {
                self.startLoadMoreAnimation()
            }
        }
        
        
    }
    
    public func startRefreshingAnimation() {
        if self.refreshHandler == nil {
            print("未实现下拉处理函数函数")
            return
        }
        if self.refreshHeaderView?.enabled == false || self.refreshState == .loading {
            return
        }
        self.refreshState = .loading
        // 隐藏底部视图
        self.refreshFooterView?.view.isHidden = true
        DispatchQueue.main.async {
            // 更新缩进和偏移量
            var insets = self.originalContentInsets!
            if #available(iOS 11.0, *) {
                insets.top = self.refreshHeaderView!.offsetToBeganLoading
            } else {
                insets.top += self.refreshHeaderView!.offsetToBeganLoading
            }
            UIView.animate(withDuration: 0.2) {
                if #available(iOS 11.0, *) {
                    self.contentInset = insets
                    self.contentOffset = CGPoint.init(x: 0, y: -insets.top-self.originalContentInsets.top)
                } else {
                    self.contentInset = insets
                    self.contentOffset = CGPoint.init(x: 0, y: -insets.top)
                }
            }
            self.refreshHeaderView?.loadingAnimation()
            if self.refreshHandler != nil {
                self.refreshHandler!(HCPullToRefreshViewType.header)
            }
        }
    }
    
    public func stopRefreshingAnimation(_ withAnimation: Bool) {
        if self.refreshHeaderView?.enabled == false {
            return
        }
        weak var weakSelf = self
        DispatchQueue.main.async {
            if withAnimation {
                // 执行结束动画
                self.refreshHeaderView?.doneAnimation(){
                    if weakSelf == nil {
                        return
                    }
                    weakSelf?.refreshState = .stop
                    weakSelf?.refreshFooterView?.view.isHidden = false
                    UIView.animate(withDuration: 0.2, animations: {
                        if #available(iOS 11.0, *) {
                            weakSelf!.contentInset = UIEdgeInsets.zero
                        } else {
                            weakSelf!.contentInset = weakSelf!.originalContentInsets
                        }
                        weakSelf!.contentOffset = CGPoint.init(x: 0, y: -weakSelf!.originalContentInsets.top)
                        weakSelf!.refreshHeaderView?.pullAnimation(0)
                    })
                }
            } else {
                // 不执行结束动画
                weakSelf?.refreshState = .stop
                weakSelf?.refreshFooterView?.view.isHidden = false
                UIView.animate(withDuration: 0.2, animations: {
                    if #available(iOS 11.0, *) {
                        weakSelf!.contentInset = UIEdgeInsets.zero
                    } else {
                        weakSelf!.contentInset = weakSelf!.originalContentInsets
                    }
                    weakSelf!.contentOffset = CGPoint.init(x: 0, y: -weakSelf!.originalContentInsets.top)
                })
            }
        }
    }
    
    public func startLoadMoreAnimation (){
        if self.refreshHandler == nil {
            print("未实现下拉处理函数函数")
            return
        }
        if self.refreshFooterView?.enabled == false || self.refreshState == .loading {
            return
        }
        self.refreshState = .loading
        DispatchQueue.main.async {
            self.refreshFooterView?.loadingAnimation()
            if self.refreshHandler != nil {
                self.refreshHandler!(HCPullToRefreshViewType.footer)
            }
        }
    }
    
    public func stopLoadMoreAnimation (_ withAnimation: Bool) {
        if self.refreshFooterView?.enabled == false {
            return
        }
        weak var weakSelf = self
        DispatchQueue.main.async {
            if withAnimation {
                weakSelf!.refreshFooterView?.doneAnimation(){
                    if weakSelf == nil {
                        return
                    }
                    weakSelf!.refreshState = .stop
                }
            } else {
                weakSelf!.refreshState = .stop
            }
        }
    }
    
    func setup() {
        self.bounces = true
        self.refreshHeaderView = HCRefreshHeaderView.init(frame: CGRect.zero)
        self.refreshFooterView = HCRefreshFooterView.init(frame: CGRect.zero)
    }
}
