//
//  SecondFloorHeaderView.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/5.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import SnapKit

class SecondFloorHeaderView: UIView, HCPullToRefreshViewProtocol {

    let lineWidth:CGFloat = 2.0
    let shapeSize = CGSize.init(width: 32, height: 32)
    var shapeLayer:CAShapeLayer?
    var doneShapeLayer:CAShapeLayer?
    
    public var view: UIView! { get { return self }}
    public var offsetToBeganLoading: CGFloat! { get { return 48 }}
    public var heightForView: CGFloat! { get { return 360 + self.offsetToBeganLoading}}
    public var offsetToArriveSecondFloor: CGFloat? { get { return 100 }}
    public var enabled: Bool! = true
    public var secondFloorView:UIButton?
    
    
    public func pullAnimation(_ offset: CGFloat) {
        self.shapeLayer?.removeAnimation(forKey: "rotation")
        self.shapeLayer?.opacity = 1.0
        self.doneShapeLayer?.opacity = 0.0
        let beganY:CGFloat = 14
        if offset < beganY {
            self.shapeLayer?.strokeEnd = 0
            return
        }
        let strokeEnd = max(0, min(1, (offset-beganY)/(self.offsetToBeganLoading-beganY)))
        self.shapeLayer?.strokeEnd = strokeEnd
    }
    
    public func loadingAnimation() {
        self.doneShapeLayer?.opacity = 0.0
        self.shapeLayer?.opacity = 1.0
        self.shapeLayer?.strokeEnd = 1.0
        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animation.duration = 2
        animation.fromValue = 0
        animation.toValue = 2*Double.pi
        animation.repeatCount = HUGE
        animation.autoreverses = false
        animation.isRemovedOnCompletion = false
        self.shapeLayer!.add(animation, forKey: "rotation")
    }
    
    public func doneAnimation(_ complete: (() -> Void)!) {
        self.shapeLayer?.opacity = 0.0
        self.shapeLayer?.strokeEnd = 0.0
        self.shapeLayer?.removeAnimation(forKey: "rotation")
        self.doneShapeLayer?.opacity = 1.0
        let animation = CABasicAnimation.init(keyPath: "strokeEnd")
        animation.duration = 0.5
        animation.fromValue = 0
        animation.toValue = 1.0
        animation.autoreverses = false
        animation.isRemovedOnCompletion = false
        self.doneShapeLayer!.add(animation, forKey: "strokeEnd")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.8) {
            complete!()
        }
    }
    
    deinit {
        print("HCRefreshView deinit")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        let view = UIButton.init(type: UIButtonType.custom)
        view.backgroundColor = UIColor.brown
        view.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        view.setTitle("第二层视图", for: UIControlState.normal)
        view.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(360)
        }
        self.secondFloorView = view
    }
    
    func secondFloorAnimation() {
        self.shapeLayer?.opacity = 0.0
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func draw(_ rect: CGRect) {
        
        self.shapeLayer?.removeFromSuperlayer()
        
        let fillColor = UIColor(red: 0.318, green: 0.318, blue: 0.318, alpha: 1.000)
        let bezierPath = UIBezierPath()
        bezierPath.addArc(withCenter: CGPoint.init(x: shapeSize.width/2.0, y: shapeSize.height/2.0), radius: shapeSize.width/2.0-lineWidth/2.0, startAngle: CGFloat(0.5*Double.pi), endAngle: CGFloat(0.32*Double.pi), clockwise: true)
        
        let x0 = bezierPath.currentPoint.x
        let y0 = bezierPath.currentPoint.y
        let x1 = shapeSize.width/2 + CGFloat(cos(0.4*Double.pi)) * (shapeSize.width/2)
        let y1 = shapeSize.height/2 + CGFloat(sin(0.4*Double.pi)) * (shapeSize.width/2)
        let l = -1/atan2(y0-y1, x0-x1)
        let b = y0-x0*l
        let x2 = x0-1.8
        let y2 = x2*l+b
        let x3 = x0+1.8
        let y3 = x3*l+b
        bezierPath.addLine(to: CGPoint.init(x: x2, y: y2))
        bezierPath.addLine(to: CGPoint.init(x: x1, y: y1))
        bezierPath.addLine(to: CGPoint.init(x: x3, y: y3))
        bezierPath.addLine(to: CGPoint.init(x: x0, y: y0))
        
        self.shapeLayer = CAShapeLayer.init()
        self.shapeLayer?.backgroundColor = UIColor.clear.cgColor
        self.shapeLayer?.frame = CGRect.init(x: (rect.size.width-shapeSize.width)/2, y: self.heightForView - self.offsetToBeganLoading + (self.offsetToBeganLoading - shapeSize.height)/2, width: shapeSize.width, height: shapeSize.height)
        self.shapeLayer?.path = bezierPath.cgPath
        self.shapeLayer?.strokeColor = fillColor.cgColor
        self.shapeLayer?.fillColor = UIColor.clear.cgColor
        self.shapeLayer?.strokeEnd = 0.0
        self.shapeLayer?.strokeStart = 0
        self.shapeLayer?.lineWidth = 2
        self.shapeLayer?.lineCap = kCALineCapRound
        
        self.layer.addSublayer(self.shapeLayer!)
        
        let endPath = UIBezierPath()
        endPath.addArc(withCenter: CGPoint.init(x: shapeSize.width/2.0, y: shapeSize.height/2.0), radius: shapeSize.width/2.0-lineWidth/2.0, startAngle: CGFloat.pi, endAngle: 1.1*CGFloat.pi, clockwise: false)
        let point = endPath.currentPoint
        endPath.addLine(to: CGPoint.init(x: point.x+10, y: point.y+10))
        endPath.addLine(to: CGPoint.init(x: shapeSize.width-5, y: shapeSize.height*0.25))
        self.doneShapeLayer?.removeFromSuperlayer()
        self.doneShapeLayer = CAShapeLayer.init()
        self.doneShapeLayer?.backgroundColor = UIColor.clear.cgColor
        self.doneShapeLayer?.frame = self.shapeLayer!.frame
        self.doneShapeLayer?.path = endPath.cgPath
        self.doneShapeLayer?.strokeColor = fillColor.cgColor
        self.doneShapeLayer?.fillColor = UIColor.clear.cgColor
        self.doneShapeLayer?.strokeEnd = 1.0
        self.doneShapeLayer?.strokeStart = 0
        self.doneShapeLayer?.lineWidth = 2
        self.doneShapeLayer?.lineCap = kCALineCapRound
        self.doneShapeLayer?.opacity = 0.0
        
        self.layer.addSublayer(self.doneShapeLayer!)
    }

}
