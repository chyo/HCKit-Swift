//
//  TableViewVC.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/29.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class TableViewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: HCRefreshTableView!
    var itemArray:Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "下拉刷新TableView"
        weak var weakSelf = self
        self.tableView.refreshHandler = { type in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
                if weakSelf == nil {
                    return
                }
                if type == .header {
                    weakSelf!.itemArray = ["0"]
                    weakSelf!.tableView.reloadData()
                    weakSelf!.tableView.refreshFooterView?.enabled = true
                    weakSelf!.tableView.stopRefreshingAnimation(true)
                } else {
                    weakSelf?.tableView.stopLoadMoreAnimation(true)
                    for _ in 0 ..< 5 {
                        weakSelf!.itemArray.append(String(weakSelf!.itemArray.count))
                    }
                    if weakSelf!.itemArray.count > 20 {
                        weakSelf!.tableView.refreshFooterView?.enabled = false
                    }
                    weakSelf!.tableView.reloadData()
                }
            }
        }
        self.tableView.startRefreshingAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        cell.textLabel?.text = self.itemArray[indexPath.row]
        return cell
    }
}
