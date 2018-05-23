//
//  BannerViewVC.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/23.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class BannerViewVC: UIViewController {

    @IBOutlet weak var bannerView: HCBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.automaticallyAdjustsScrollViewInsets = false
        var itemArray = [HCBannerItem]()
        for _ in 0..<10 {
            var item = HCBannerItem.init(data: nil, imgUrl: nil)
            itemArray.append(item)
        }
        
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now()+2){
            self.bannerView.itemArray = itemArray
            self.bannerView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
