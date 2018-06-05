//
//  HCPullToRefreshProtocol.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/29.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

/// 状态
///
/// - stop: 无动作，停止状态
/// - pulling: 拖动状态，包括下拉和上拖
/// - loading: 加载状态，包括刷新和获取更多
/// - done: 完成状态，执行加载完成的动画，动画执行完毕后会改为stop状态
public enum HCPullToRefreshState {
    case stop, pulling, loading, done, secondFloor
}

/// 视图类型
///
/// - secondFloor：第二层级的下拉
/// - header: 顶部刷新
/// - footer: 底部获取更多
public enum HCPullToRefreshViewType {
    case secondFloor, header, footer
}

/// 触发事件，刷新、获取更多等
public typealias HCPullToRefreshHandler = ((_ type:HCPullToRefreshViewType)->Void)

/// 主视图协议，可参考HCRefreshTableView实现
public protocol HCPullToRefreshProtocol {
    /// 事件处理器
    var refreshHandler:HCPullToRefreshHandler? {get set}
    /// 顶部动画视图
    var refreshHeaderView:HCPullToRefreshViewProtocol? {get set}
    /// 底部动画视图
    var refreshFooterView:HCPullToRefreshViewProtocol? {get set}
    /// 状态
    var refreshState:HCPullToRefreshState! {get set}
    /// 启动刷新动画
    func startRefreshingAnimation ()
    /// 停止刷新动画
    ///
    /// - Parameter withAnimation: 是否需要执行动画
    func stopRefreshingAnimation (_ withAnimation:Bool)
    /// 启动获取更多动画
    func startLoadMoreAnimation()
    /// 停止获取更多动画
    ///
    /// - Parameter withAnimation: 是否需要执行动画
    func stopLoadMoreAnimation (_ withAnimation: Bool)
    /// 进入下拉第二层级视图
    func showsSecondFloor ()
    /// 关闭下拉第二层级
    func hidesSecondFloor ()
}

/// 顶部或底部动画视图协议，可参考HCRefreshHeaderView实现
public protocol HCPullToRefreshViewProtocol {
    
    /// 动画视图，返回self
    var view:UIView! {get}
    /// 视图高度
    var heightForView:CGFloat! {get}
    /// 触发数据加载动画的偏移量，可以跟视图高度不一样
    var offsetToBeganLoading:CGFloat! {get}
    /// 是否可用
    var enabled:Bool! {get set}
    /// 拖动时的动画
    ///
    /// - Parameter offset: 偏移量
    func pullAnimation (_ offset:CGFloat)
    /// 触发加载时的动画
    func loadingAnimation ()
    /// 执行加载完成的动画，动画结束后需调用complete通知主视图
    ///
    /// - Parameter complete: 回调
    func doneAnimation (_ complete:(() -> Void)!)
    /// 进入第二层级下拉视图所需要的偏移量，如果无需实现两级下拉效果，此值可为nil，
    var offsetToArriveSecondFloor:CGFloat? {get}
    /// 进入第二层级下拉视图后触发的动画，如果无需实现两级下拉效果，方法空实现即可
    func secondFloorAnimation ()
}




