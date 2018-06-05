//
//  ViewController.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/22.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let rowArray = [
        ["text":"轮播组件（HCBannerView）", "storyboard":"Example", "identifier":"BannerViewVC", "push":true],
        ["text":"字母组件（HCLetterView）", "storyboard":nil, "identifier":"LetterViewVC", "push":true],
        ["text":"下拉刷新组件（HCRefreshTableView）", "storyboard":"Example", "identifier":"TableViewVC", "push":true],
        ["text":"下拉刷新组件（HCRefreshScrollView）", "storyboard":"Example", "identifier":"ScrollViewVC", "push":true],
        ["text":"下拉刷新组件（HCRefreshCollectionView）", "storyboard":"Example", "identifier":"CollectionViewVC", "push":true]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "HC_Swift组件库"
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 70))
        footerView.backgroundColor = UIColor.clear
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light)
        label.textColor = UIColor.init(red: 189/255.0, green: 189/255.0, blue: 189/255.0, alpha: 1)
        label.textAlignment = NSTextAlignment.center
        label.text = "Copyright © 2018 ChenHongchao"
        label.backgroundColor = UIColor.clear
        footerView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.equalTo(footerView)
        }
        let sep = UIView.init()
        sep.backgroundColor = UIColor.init(red: 224/255.0, green: 224/255.0, blue: 224/255.0, alpha: 1.0)
        footerView.addSubview(sep)
        sep.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(0.5)
        }
        self.tableView.tableFooterView = footerView
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
        let vc:UIViewController!
        if storyboard == nil {
            let cls = NSClassFromString(HCConfig.hc_bundleName() + "." + identifier!) as! UIViewController.Type
            vc = cls.init()
        } else {
            vc = UIStoryboard.init(name: storyboard!, bundle: nil).instantiateViewController(withIdentifier: identifier!)
        }
        if push! {
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.present(vc, animated: true, completion: nil)
        }
    }

}

