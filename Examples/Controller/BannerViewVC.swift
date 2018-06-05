//
//  BannerViewVC.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/5/23.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class BannerViewVC: UIViewController, UIScrollViewDelegate{

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bannerView: HCBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var itemArray = [HCBannerItem]()
        var item = HCBannerItem.init(data: String(0), imgUrl: "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=3564877025,796183547&fm=27&gp=0.jpg")
        itemArray.append(item)
        item = HCBannerItem.init(data: String(1), imgUrl: "http://pic1.ipadown.com/imgs/201206120925003281.jpg")
        itemArray.append(item)
        item = HCBannerItem.init(data: String(2), imgUrl: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1527140599971&di=a34fd8561429315409f7fa7a57264db8&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dshijue1%252C0%252C0%252C294%252C40%2Fsign%3D46a86bff3cd12f2eda08a62327abbf17%2Fb8389b504fc2d562b871dac5ed1190ef76c66c98.jpg")
        itemArray.append(item)
        self.bannerView.placeholder = UIImage.init(named: "placeholder")
        self.bannerView.selectionHandler = {(view, item) in
            HCConfig.hc_alert(title: item?.data as? String, message: nil, cancelTitle: "好", confirmTitle: nil)
        }
        self.bannerView.itemArray = itemArray
        self.bannerView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.bannerView.bannerViewDidZooming(scrollView)
    }
}
