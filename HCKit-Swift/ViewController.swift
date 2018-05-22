//
//  ViewController.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/22.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let text = "ABC"
        print(text.hc_md5())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

