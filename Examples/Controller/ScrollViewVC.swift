//
//  ScrollViewVC.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/5.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class ScrollViewVC: UIViewController {

    @IBOutlet weak var scrollView: HCRefreshScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "下拉刷新ScrollView"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "两级下拉", style: UIBarButtonItemStyle.plain, target: self, action: #selector(enabledSecondFloor))
        weak var weakSelf = self
        self.scrollView.refreshHandler = { type in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
                if weakSelf == nil {
                    return
                }
                if type == .header {
                    weakSelf!.scrollView.stopRefreshingAnimation(true)
                }
            }
        }
        self.scrollView.startRefreshingAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func enabledSecondFloor () {
        let headerView = SecondFloorHeaderView.init(frame: CGRect.zero)
        self.scrollView.refreshHeaderView = headerView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
