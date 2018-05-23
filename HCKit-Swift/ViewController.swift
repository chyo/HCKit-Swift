//
//  ViewController.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/22.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let rowArray = [["text":"轮播组件（HCBannerView）", "storyboard":"Example", "identifier":"BannerViewVC", "push":true]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "HCKit-Swift"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // UITableViewDelegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        let label = cell.viewWithTag(1) as! UILabel
        let item = rowArray[indexPath.row]
        label.text = item["text"] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = rowArray[indexPath.row]
        let push = item["push"] as? Bool
        let storyboard = item["storyboard"] as? String
        let identifier = item["identifier"] as? String
        let vc = UIStoryboard.init(name: storyboard!, bundle: nil).instantiateViewController(withIdentifier: identifier!)
        if push! {
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.present(vc, animated: true, completion: nil)
        }
    }

}

