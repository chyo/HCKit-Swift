//
//  LetterViewVC.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/28.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import SnapKit

class LetterViewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let letters = ["\u{e651}", "#", "A", "B", "C", "D", "E", "F", "G", "H", "I"]
    var letterView:HCLetterView?
    var tableView:UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1)
        self.title = "字母组件（HCLetterView）"
        
        self.tableView = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.plain)
        self.tableView?.backgroundColor = UIColor.clear
        self.tableView?.backgroundView = nil
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.view.addSubview(self.tableView!)
        self.tableView!.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        var itemArray:Array<HCLetterItem!> = []
        for letter in letters {
            itemArray.append(HCLetterItem.init(letter: letter, data: nil))
        }
        let letterView = HCLetterView.init(frame: CGRect.zero)
        self.view.addSubview(letterView)
        letterView.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.centerY.equalTo(self.view)
            make.width.equalTo(30)
        }
        weak var weakSelf:LetterViewVC? = self
        letterView.selectionHandler = {(view, index) in
            weakSelf?.tableView?.scrollToRow(at: IndexPath.init(row: 0, section: index), at: UITableViewScrollPosition.top, animated: false)
        }
        letterView.letterHud?.font = UIFont.init(name: "iconfont", size: 48)
        letterView.font = UIFont.init(name: "iconfont", size: 12)
        letterView.layer.cornerRadius = 15
        letterView.letterArray = itemArray
        letterView.reloadData()
        self.letterView = letterView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return letters.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
        label.backgroundColor = UIColor.lightGray
        label.textColor = UIColor.white
        label.text = "  " + letters[section]
        label.font = UIFont.init(name: "iconfont", size: 12)
        return label
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "CELL")
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "示例采用了自定义iconfont字体"
            }
            else if indexPath.row == 1 {
                    cell.textLabel?.text = "因此可以显示搜索图标"
            }
            else {
                cell.textLabel?.text = "\(letters[indexPath.section])\(indexPath.row)"
            }
        } else {
            cell.textLabel?.text = "\(letters[indexPath.section])\(indexPath.row)"
        }
        cell.textLabel?.font = UIFont.init(name: "iconfont", size: 14)
        cell.textLabel?.textColor = UIColor.black
        return cell
    }
}
