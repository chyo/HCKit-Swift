//
//  CameraVC.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/7/11.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class CameraVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ratioLabel: UILabel!
    var ratio:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "HCCameraVC"
    }

    @IBAction func actionTakePhoto(_ sender: Any) {
        weak var weakSelf = self
        let options = HCCameraRequestOptions.init()
        options.saveToAlbum = true
        options.cropRatio = ratio
        if ratio < 0 {
            options.cropRatio = 1 / -ratio
        }
        let vc = HCCameraVC.init(options: options) { (image) in
            weakSelf?.imageView.image = image
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func actionRatio(_ sender: UISlider) {
        ratio = CGFloat(Int(sender.value))
        if ratio < 0 {
            ratioLabel.text = "宽高比：1:\(-ratio)"
        } else if ratio == 0 {
            ratioLabel.text = "宽高比：无"
        } else {
            ratioLabel.text = "宽高比：\(ratio):1"
        }
    }
}
