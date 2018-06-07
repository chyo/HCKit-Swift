//
//  HCCalendarView.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/6.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import SnapKit

/// CELL选中处理器
public typealias CalendarViewDidSelectItemHandler = ((_ item:HCCalendarItem)->Void)

/**
 
 */
public class HCCalendarView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    let ViewHeight:CGFloat = 340
    var cover:UIControl?
    var cancelButton:UIButton?
    var confirmButton:UIButton?
    var monthButton:UIButton?
    var collectionView:UICollectionView!
    var monthArray:Array<HCCalendarMonth>! = []
    var selectedDayItem:HCCalendarItem?
    
    /// CELL选中回调
    public var didSelectItemHandler:CalendarViewDidSelectItemHandler?
    
    deinit {
        print("HCRefreshCollectionView deinit")
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
    }
    
    public convenience init(didSelectItemHandler:CalendarViewDidSelectItemHandler!) {
        self.init(frame: CGRect.zero)
        self.didSelectItemHandler = didSelectItemHandler
        self.backgroundColor = UIColor.white
    }
    
    public override init(frame: CGRect) {
        let collectionLayout = HCCalendarFlowLayout.init()
        self.collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: collectionLayout)
        self.collectionView?.isPagingEnabled = true
        super.init(frame: frame)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        let collectionLayout = HCCalendarFlowLayout.init()
        self.collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: collectionLayout)
        self.collectionView?.isPagingEnabled = true
        super.init(coder: aDecoder)
        self.setup()
    }
    
    public override func layoutSubviews() {
        // 修正顶部自动缩进问题
        collectionView?.contentInset = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }
        super.layoutSubviews()
    }
    
    @objc func changeMonth(button:UIButton!) -> Void {
        if button.tag == 100 {
            self.reloadData(pageIndex: 0)
        } else {
            self.reloadData(pageIndex: 2)
        }
    }
    
    func setup () {
        
        /// 标题
        self.monthButton = UIButton.init(type: UIButtonType.custom)
        self.monthButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.monthButton?.setTitleColor(UIColor.black, for: UIControlState.normal)
        self.monthButton?.backgroundColor = UIColor.clear
        self.monthButton?.addTarget(self, action: #selector(self.actionPickMonth), for: UIControlEvents.touchUpInside)
        self.addSubview(self.monthButton!)
        self.monthButton?.snp.makeConstraints({ (make) in
            make.top.equalTo(6)
            make.height.equalTo(40)
            make.centerX.equalTo(self)
        })
        
        let bundle = HCConfig.hc_resourceBundle()
        /// 上一月
        var image = UIImage.init(named: "hcArrowLeft", in: bundle, compatibleWith: nil)
        let leftButton = UIButton.init(type: UIButtonType.custom)
        leftButton.backgroundColor = UIColor.clear
        leftButton.setImage(image, for: UIControlState.normal)
        leftButton.addTarget(self, action: #selector(self.changeMonth(button:)), for: UIControlEvents.touchUpInside)
        leftButton.tag = 100
        self.addSubview(leftButton)
        leftButton.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.centerY.equalTo(self.monthButton!)
            make.right.equalTo(self.monthButton!.snp.left).offset(-12)
        }
        /// 下一月
        image = UIImage.init(named: "hcArrowRight", in: bundle, compatibleWith: nil)
        let rightButton = UIButton.init(type: UIButtonType.custom)
        rightButton.backgroundColor = UIColor.clear
        rightButton.setImage(image, for: UIControlState.normal)
        rightButton.addTarget(self, action: #selector(self.changeMonth(button:)), for: UIControlEvents.touchUpInside)
        rightButton.tag = 200
        self.addSubview(rightButton)
        rightButton.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.centerY.equalTo(self.monthButton!)
            make.left.equalTo(self.monthButton!.snp.right).offset(12)
        }
        /// 取消按钮，默认隐藏，只有在弹窗模式才会显示
        self.cancelButton = UIButton.init(type: UIButtonType.custom)
        self.cancelButton?.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.cancelButton?.setTitleColor(UIColor.black, for: UIControlState.normal)
        self.cancelButton?.setTitle("取消", for: UIControlState.normal)
        self.cancelButton?.backgroundColor = UIColor.clear
        self.cancelButton?.isHidden = true
        self.cancelButton?.addTarget(self, action: #selector(self.dismissDialog), for: UIControlEvents.touchUpInside)
        self.addSubview(self.cancelButton!)
        self.cancelButton?.snp.makeConstraints({ (make) in
            make.left.equalTo(0)
            make.centerY.equalTo(self.monthButton!)
            make.width.equalTo(60)
            make.height.equalTo(40)
        })
        /// 确认按钮，默认隐藏，只有在弹窗模式才会显示
        self.confirmButton = UIButton.init(type: UIButtonType.custom)
        self.confirmButton?.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.confirmButton?.setTitleColor(UIColor.init(red: 56.0/255.0, green: 141.0/255.0, blue: 94.0/255.0, alpha: 1), for: UIControlState.normal)
        self.confirmButton?.setTitle("确认", for: UIControlState.normal)
        self.confirmButton?.backgroundColor = UIColor.clear
        self.confirmButton?.isHidden = true
        self.confirmButton?.addTarget(self, action: #selector(self.actionConfirm), for: UIControlEvents.touchUpInside)
        self.addSubview(self.confirmButton!)
        self.confirmButton?.snp.makeConstraints({ (make) in
            make.right.equalTo(0)
            make.centerY.equalTo(self.monthButton!)
            make.width.equalTo(60)
            make.height.equalTo(40)
        })
        
        /// 遮罩
        self.cover = UIControl.init()
        self.cover?.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
        self.cover?.addTarget(self, action: #selector(self.dismissDialog), for: UIControlEvents.touchUpInside)
        
        /// 绘制表头
        let headerView = UIView.init()
        headerView.backgroundColor = UIColor.clear
        let titleArray = ["日", "一", "二", "三", "四", "五", "六"]
        weak var leftView:UIView?
        for i in 0 ..< titleArray.count {
            let label = UILabel.init(frame: CGRect.zero)
            label.backgroundColor = UIColor.clear
            label.textColor = (i == 0 || i == titleArray.count-1) ? UIColor.orange : UIColor.darkGray
            label.textAlignment = NSTextAlignment.center
            label.text = titleArray[i]
            label.font = UIFont.boldSystemFont(ofSize: 14)
            headerView.addSubview(label)
            label.snp.makeConstraints { (make) in
                if i == 0 {
                    make.left.equalTo(0)
                } else {
                    make.left.equalTo(leftView!.snp.right)
                    make.width.equalTo(leftView!)
                }
                make.top.equalTo(0)
                make.bottom.equalTo(0)
                if i + 1 == titleArray.count {
                    make.right.equalTo(0)
                }
            }
            leftView = label
        }
        self.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.monthButton!.snp.bottom)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(44)
        }
        
        self.collectionView?.backgroundView = nil
        self.collectionView?.backgroundColor = UIColor.clear
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.showsVerticalScrollIndicator = false
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.addSubview(self.collectionView!)
        self.collectionView?.snp.makeConstraints({ (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        })
        self.collectionView.register(HCCalendarCell.classForCoder(), forCellWithReuseIdentifier: "HCCalendarCell")
        self.reloadData(date: nil)
    }
    
    public func reloadData (date:Date?) {
        self.collectionView.isScrollEnabled = false
        var now = date
        if now == nil {
            now = Date.init()
        }
        if date != nil {
            self.selectedDayItem = HCCalendarItem.init(date: date)
        }
        self.monthArray.removeAll()
        self.monthArray.append(HCCalendarMonth.init(date: now!.hc_lastMonth(), selectedItem: &self.selectedDayItem))
        self.monthArray.append(HCCalendarMonth.init(date: now!, selectedItem: &self.selectedDayItem))
        self.monthArray.append(HCCalendarMonth.init(date: now!.hc_nextMonth(), selectedItem: &self.selectedDayItem))
        self.reloadCollectionView()
    }
    
    func reloadData (pageIndex:Int) {
        var array:Array<HCCalendarMonth> = []
        self.collectionView.isScrollEnabled = false
        if pageIndex == 0 {
            array.append(HCCalendarMonth.init(date: self.monthArray[0].date.hc_lastMonth(), selectedItem: &self.selectedDayItem))
            array.append(self.monthArray[0])
            array.append(self.monthArray[1])
            self.monthArray = array
        } else if pageIndex == 2{
            array.append(self.monthArray[1])
            array.append(self.monthArray[2])
            array.append(HCCalendarMonth.init(date: self.monthArray[2].date.hc_nextMonth(), selectedItem: &self.selectedDayItem))
            self.monthArray = array
        }
        self.reloadCollectionView()
    }
    
    @objc func actionPickMonth () {
        weak var weakSelf = self
        let monthPicker = HCYearMonthPicker.init { (year, month) in
            let fmt = DateFormatter.init()
            fmt.dateFormat = "yyyyM"
            weakSelf?.collectionView.isScrollEnabled = false
            let date = fmt.date(from: "\(year)\(month)")
            weakSelf?.monthArray.removeAll()
            weakSelf?.monthArray.append(HCCalendarMonth.init(date: date!.hc_lastMonth(), selectedItem: &weakSelf!.selectedDayItem))
            weakSelf?.monthArray.append(HCCalendarMonth.init(date: date!, selectedItem: &weakSelf!.selectedDayItem))
            weakSelf?.monthArray.append(HCCalendarMonth.init(date: date!.hc_nextMonth(), selectedItem: &weakSelf!.selectedDayItem))
            weakSelf?.reloadCollectionView()
        }
        let date = self.monthArray[1].date
        monthPicker.reloadData(selectedYear: date?.hc_dateComponents().year, selectedMonth: date?.hc_dateComponents().month, mode: .yearMonth)
        monthPicker.showAsDialog()
    }
    
    @objc func actionConfirm () {
        self.snp.updateConstraints { (make) in
            make.bottom.equalTo(ViewHeight)
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.cover?.alpha = 0.0
            self.superview?.layoutIfNeeded()
        }) { (finish) in
            if self.didSelectItemHandler != nil && self.selectedDayItem != nil {
                self.didSelectItemHandler!(self.selectedDayItem!)
            }
            self.removeFromSuperview()
        }
    }
    
    @objc public func dismissDialog (){
        self.snp.updateConstraints { (make) in
            make.bottom.equalTo(ViewHeight)
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.cover?.alpha = 0.0
            self.superview?.layoutIfNeeded()
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
    public func showAsDialog () {
        
        self.cancelButton?.isHidden = false
        self.confirmButton?.isHidden = false
        
        weak var window = UIApplication.shared.keyWindow
        window?.windowLevel = UIWindowLevelNormal
        window?.addSubview(self.cover!)
        self.cover?.snp.makeConstraints({ (make) in
            make.edges.equalTo(window!)
        })
        self.cover?.alpha = 0.0
        window?.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(ViewHeight)
            make.bottom.equalTo(ViewHeight)
        }
        window?.layoutIfNeeded()
        self.snp.updateConstraints { (make) in
            make.bottom.equalTo(0)
        }
        UIView.animate(withDuration: 0.3) {
            self.cover?.alpha = 1.0
            window?.layoutIfNeeded()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(self.collectionView.contentOffset.x/self.collectionView.bounds.size.width)
        self.reloadData(pageIndex: pageIndex)
    }
    
    func reloadCollectionView () {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.collectionView?.contentOffset = CGPoint.init(x: self.collectionView.bounds.size.width, y: 0)
            self.collectionView.isScrollEnabled = true
            self.monthButton?.setTitle(self.monthArray[1].date.hc_dateFormat(format: "yyyy 年 M 月"), for: UIControlState.normal)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.collectionView.isScrollEnabled = false
        if !decelerate {
            self.scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.monthArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.bounds.size.width/7, height: collectionView.bounds.size.height/6)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.monthArray[section].dayArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HCCalendarCell", for: indexPath) as! HCCalendarCell
        cell.item = self.monthArray[indexPath.section].dayArray[indexPath.item]
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let dayItem = self.monthArray[indexPath.section].dayArray[indexPath.item]
        if self.selectedDayItem != dayItem {
            self.selectedDayItem?.selected = false
            dayItem.selected = true
            self.selectedDayItem = dayItem
            collectionView.reloadData()
        }
        if self.didSelectItemHandler != nil && self.confirmButton?.isHidden == true {
            self.didSelectItemHandler!(self.selectedDayItem!)
        }
    }
}
