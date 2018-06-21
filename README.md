# 一个简单的Swift库，一个森罗万象的Swift库
## 包含组件
1. 轮播组件：HCBannerView，常见场景：App顶部广告
2. 字母组件：HCLetterView ，常见场景：通讯录侧边字母
3. 下拉刷新组件：HCRefreshTableView、HCRefreshScrollView、HCRefreshCollectionView，支持两段式下拉，第一段为刷新数据，第二段为额外视图。常见场景：微信聊天列表头部小程序，淘宝二楼
4. 日历组件：HCCalendarView、HCYearMonthPicker
5. 指示器组件：HCHud
 
用法详见各组件说明以及Examples文件夹

## 其他
1. 一些以+HCExtension命名的拓展
2. 无需invalidate也不会引起循环引用的的timer代理：HCWeakTimerProxy

## 项目依赖
1. Snapkit 4.0.0
2. Kingfisher 4.8.0

项目依赖会自动下载，无需在podfile中配置
