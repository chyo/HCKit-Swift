//
//  HCMonthPicker.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/7.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import SnapKit

/// 年月选择器模式
///
/// - year: 只显示年
/// - month: 只显示月
/// - yearMonth: 同时显示年、月
public enum HCYearMonthPickerMode {
    case year, month, yearMonth
}

/// 选中回调
public typealias HCMonthPickerSelectionHandler = ((_ year:Int, _ month:Int)->Void)

/***
 # 年月选择器 V1.0.0
 
 ## 仅支持弹窗模式
 调用showAsDialog方法显示弹窗
 
 */
public class HCYearMonthPicker: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    /// 弹窗高度
    let ViewHeight:CGFloat = 340
    /// 默认前后100年
    let numbersOfYear:Int = 200
    /// 弹窗遮罩
    var cover:UIControl?
    /// 取消按钮
    var cancelButton:UIButton?
    /// 确认按钮
    var confirmButton:UIButton?
    /// 标题
    var titleLabel:UILabel?
    /// 选择器
    var pickerView:UIPickerView?
    /// 回调
    var selectionHandler:HCMonthPickerSelectionHandler?
    /// 年
    var yearArray:Array<Int> = []
    /// 月
    let monthArray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    
    public var mode:HCYearMonthPickerMode! = .yearMonth
    
    deinit {
        print("HCYearMonthPicker deinit")
        self.pickerView?.dataSource = nil
        self.pickerView?.delegate = nil
    }
    
    public convenience init(selectionHandler:HCMonthPickerSelectionHandler!) {
        self.init(frame: CGRect.zero)
        self.selectionHandler = selectionHandler
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assert(false, "HCYearMonthPicker - 请使用init(selectionHandler:HCMonthPickerSelectionHandler!)方法构造")
    }
    
    func setup () {
        // 标题
        self.titleLabel = UILabel.init()
        titleLabel?.backgroundColor = UIColor.clear
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel?.text = "选择年月"
        self.addSubview(self.titleLabel!)
        self.titleLabel!.snp.makeConstraints({ (make) in
            make.top.equalTo(6)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        })
        
        /// 取消按钮
        self.cancelButton = UIButton.init(type: UIButtonType.custom)
        self.cancelButton?.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.cancelButton?.setTitleColor(UIColor.black, for: UIControlState.normal)
        self.cancelButton?.setTitle("取消", for: UIControlState.normal)
        self.cancelButton?.backgroundColor = UIColor.clear
        self.cancelButton?.addTarget(self, action: #selector(self.dismissDialog), for: UIControlEvents.touchUpInside)
        self.addSubview(self.cancelButton!)
        self.cancelButton?.snp.makeConstraints({ (make) in
            make.left.equalTo(0)
            make.top.equalTo(6)
            make.width.equalTo(60)
            make.height.equalTo(40)
        })
        /// 确认按钮
        self.confirmButton = UIButton.init(type: UIButtonType.custom)
        self.confirmButton?.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.confirmButton?.setTitleColor(UIColor.init(red: 56.0/255.0, green: 141.0/255.0, blue: 94.0/255.0, alpha: 1), for: UIControlState.normal)
        self.confirmButton?.setTitle("确认", for: UIControlState.normal)
        self.confirmButton?.backgroundColor = UIColor.clear
        self.confirmButton?.addTarget(self, action: #selector(self.actionConfirm), for: UIControlEvents.touchUpInside)
        self.addSubview(self.confirmButton!)
        self.confirmButton?.snp.makeConstraints({ (make) in
            make.right.equalTo(0)
            make.centerY.equalTo(self.cancelButton!)
            make.width.equalTo(60)
            make.height.equalTo(40)
        })
        
        /// 遮罩
        self.cover = UIControl.init()
        self.cover?.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
        self.cover?.addTarget(self, action: #selector(self.dismissDialog), for: UIControlEvents.touchUpInside)
        
        self.pickerView = UIPickerView.init()
        self.pickerView?.backgroundColor = UIColor.clear
        self.pickerView?.showsSelectionIndicator = true
        self.pickerView?.delegate = self
        self.pickerView?.dataSource = self
        self.addSubview(self.pickerView!)
        self.pickerView?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.confirmButton!.snp.bottom).offset(6)
            make.left.equalTo(0)
            make.right.equalTo(0)
        })
        // 初始化年，当前年的前后100年
        let now = Date.init()
        let year = now.hc_dateComponents().year! - numbersOfYear / 2
        for i in 0 ..< numbersOfYear {
            yearArray.append(year+i)
        }
        
        self.pickerView?.reloadAllComponents()
        self.pickerView?.selectRow(numbersOfYear/2, inComponent: 0, animated: false)
        self.pickerView?.selectRow(now.hc_dateComponents().month!-1, inComponent: 1, animated: false)
    }
    
    /// 确认选择
    @objc func actionConfirm () {
        var year = 0
        var month = 1
        if self.mode == .year {
            year = self.yearArray[self.pickerView!.selectedRow(inComponent: 0)]
        } else if self.mode == .month {
            month = self.monthArray[self.pickerView!.selectedRow(inComponent: 0)]
        } else {
            year = self.yearArray[self.pickerView!.selectedRow(inComponent: 0)]
            month = self.monthArray[self.pickerView!.selectedRow(inComponent: 1)]
        }
        self.snp.updateConstraints { (make) in
            make.bottom.equalTo(ViewHeight)
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.cover?.alpha = 0.0
            self.superview?.layoutIfNeeded()
        }) { (finish) in
            if self.selectionHandler != nil {
                self.selectionHandler!(year, month)
            }
            self.removeFromSuperview()
        }
    }
    
    /// 隐藏弹窗
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
    
    /// 显示弹窗
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
    
    /// 刷新数据
    ///
    /// - Parameters:
    ///   - selectedYear: 选中的年，可为nil，默认当前年
    ///   - selectedMonth: 选中的月，可为nil，默认当前月
    ///   - mode: 年月选择器模式
    public func reloadData (selectedYear:Int?, selectedMonth:Int?, mode:HCYearMonthPickerMode!) {
        self.mode = mode
        self.pickerView?.reloadAllComponents()
        if self.mode == .year && selectedYear != nil {
            let index = selectedYear! - self.yearArray[0]
            if index >= 0 && index < self.yearArray.count {
                self.pickerView?.selectRow(selectedYear! - self.yearArray[0], inComponent: 0, animated: false)
            }
        } else if (self.mode == .month && selectedMonth != nil) {
            if selectedMonth! >= 1 && selectedMonth! <= 12 {
                self.pickerView?.selectRow(selectedMonth! - 1, inComponent: 0, animated: false)
            }
        } else if (selectedYear != nil && selectedMonth != nil){
            let index = selectedYear! - self.yearArray[0]
            if index >= 0 && index < self.yearArray.count {
                self.pickerView?.selectRow(selectedYear! - self.yearArray[0], inComponent: 0, animated: false)
            }
            if selectedMonth! >= 1 && selectedMonth! <= 12 {
                self.pickerView?.selectRow(selectedMonth! - 1, inComponent: 1, animated: false)
            }
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if self.mode == .year || self.mode == .month {
            return 1
        } else {
            return 2
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.mode == .year {
            return self.yearArray.count
        } else if self.mode == .month {
            return self.monthArray.count
        } else if (component == 0) {
            return self.yearArray.count
        } else {
            return self.monthArray.count
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 56
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel.init()
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = NSTextAlignment.center
        if self.mode == .year {
            label.text = "\(self.yearArray[row])年"
        } else if self.mode == .month {
            label.text = "\(self.monthArray[row])月"
        } else if component == 0 {
            label.text = "\(self.yearArray[row])年"
        } else {
            label.text = "\(self.monthArray[row])月"
        }
        return label
    }
    
}
