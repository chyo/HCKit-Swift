//
//  HudVC.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/21.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class HudVC: UIViewController {

    var hud:HCHud?
    
    @IBOutlet weak var tfText: UITextField!
    @IBOutlet weak var tfSize: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "HCHud"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func hudSize () -> CGSize {
        var components = self.tfSize.text?.components(separatedBy: ",")
        let size = CGSize.init(width: Int(components![0])!, height: Int(components![1])!)
        return size
    }
    
    @IBAction func actionLoading(_ sender: Any) {
        self.hud?.hide(animated: false)
        self.hud = HCHud.init(in: self.view, mode: .loading, style: self.segmentedControl.selectedSegmentIndex == 0 ? .dark:.light)
        self.hud?.minSize = self.hudSize()
        self.hud?.show(animated: true)
    }
    
    @IBAction func actionLoadingWithText(_ sender: Any) {
        self.hud?.hide(animated: false)
        self.hud = HCHud.init(in: self.view, mode: .loadingWithText, style: self.segmentedControl.selectedSegmentIndex == 0 ? .dark:.light)
        self.hud?.minSize = self.hudSize()
        self.hud?.label?.text = self.tfText.text
        self.hud?.show(animated: true)
    }
    
    @IBAction func actionText(_ sender: Any) {
        self.hud?.hide(animated: false)
        self.hud = HCHud.init(in: self.view, mode: .text, style: self.segmentedControl.selectedSegmentIndex == 0 ? .dark:.light)
        self.hud?.label?.text = self.tfText.text
        self.hud?.show(animated: true, complete: {
            print("Hud显示后回调")
        })
    }
    
    @IBAction func actionLock(_ sender: Any) {
        self.hud?.hide(animated: false)
        self.hud = HCHud.init(in: self.view, mode: .loading, style: self.segmentedControl.selectedSegmentIndex == 0 ? .dark:.light)
        self.hud?.minSize = self.hudSize()
        self.hud?.isUserInteractionEnabled = true
        self.hud?.show(animated: true)
    }
    
    @IBAction func actionHide(_ sender: Any) {
        self.hud?.hide(animated: false)
    }
    
    @IBAction func actionHideWithEvent(_ sender: Any) {
        self.hud?.hide(animated: true, afterDelay: 1.5, complete: {
            print("Hud隐藏后回调")
        })
    }
}
