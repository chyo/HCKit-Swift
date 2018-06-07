//
//  CalenderVC.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/6.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class CalendarVC: UIViewController {

    @IBOutlet weak var calendarView: HCCalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "日历"
        weak var weakSelf = self
        self.calendarView.didSelectItemHandler = {(item) in
            weakSelf?.title = item.date?.hc_dateFormat(format: "yyyy年MM月dd日")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionPickDate(_ sender: Any) {
        let fmt = DateFormatter.init()
        fmt.calendar = Calendar.current
        fmt.dateFormat = "yyyy年MM月dd日"
        let date = fmt.date(from: self.title!)
        weak var weakSelf = self
        let calendarView = HCCalendarView.init { (item) in
            weakSelf?.title = item.date?.hc_dateFormat(format: "yyyy年MM月dd日")
        }
        calendarView.reloadData(date: date)
        calendarView.showAsDialog()
    }
    
}
