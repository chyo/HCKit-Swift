//
//  HCCameraVC.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/7/11.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import CoreMotion
import Photos

/// 拍照回调
public typealias HCCameraVCDidTakePhotoHandler = ((_ image:UIImage?)->Void)

/**
 
 # 拍照对象 V1.0.0
 
 ## 需要配置
 Privacy - Camera Usage Description
 
 ## 参数设置
 通过HCCameraRequestOptions可以设置拍照参数，如裁剪长宽比等
 
 */
public class HCCameraVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    /// 初始化指示器
    weak var indicator:UIActivityIndicatorView?
    /// 底部工具条
    weak var toolbar:UIView?
    /// 实时图像容器
    weak var bufferView:UIView?
    /// 实时图像图层
    weak var bufferLayer:AVCaptureVideoPreviewLayer?
    /// 相机对象
    var capture:AVCaptureSession?
    /// 遮罩层
    var cropLayer:CAShapeLayer?
    /// 取景区域
    var cropRect:CGRect?
    /// 对焦动画图片
    var focusIV:UIImageView?
    /// 对焦动画定时器
    var focusAnimationTimer:Timer?
    /// 图像缓冲对象
    var imageBufferRef:CVImageBuffer?
    /// bufferView在图像的实际区域
    var bufferRect:CGRect = .zero
    /// 图像大小
    var bufferSzie:CGSize = .zero
    /// 传感器对象
    var motionMgr:CMMotionManager?
    /// 图像方向
    var imageOrientation:UIImageOrientation = .right
    /// 拍照参数
    var options:HCCameraRequestOptions!
    /// 拍照回调
    var takePhotoHandler:HCCameraVCDidTakePhotoHandler!
    
    deinit {
        self.motionMgr?.stopAccelerometerUpdates()
        print("HCCameraVC deinit")
    }
    
    /// 请使用此方法进行初始化
    ///
    /// - Parameters:
    ///   - options: 参数设置
    ///   - takePhotoHandler: 回调函数
    public init(options:HCCameraRequestOptions?, takePhotoHandler:@escaping HCCameraVCDidTakePhotoHandler) {
        super.init(nibName: nil, bundle: nil)
        if options == nil {
            self.options = HCCameraRequestOptions.init()
        } else {
            self.options = options!
        }
        self.takePhotoHandler = takePhotoHandler
    }
    
    required public init?(coder aDecoder: NSCoder) {
        assert(false, "instead of using init(takePhotoHandler:)")
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = .black
        
        self.setupBufferView()
        self.setupToolbar()
        self.setupCoreMotion()
        
        let indicator = UIActivityIndicatorView.init(activityIndicatorStyle: .white)
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        self.view.addSubview(indicator)
        indicator.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
        }
        self.indicator = indicator
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        weak var weakSelf = self
        if self.capture != nil {
            if self.capture?.isRunning == false {
                self.capture?.startRunning()
            }
        } else {
            HCConfig.hc_isAuthorizedCamera(openSettingsIfNeeded: true) { (granted) in
                if granted && weakSelf!.capture == nil {
                    weakSelf?.setupCapture()
                }
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.capture?.isRunning == true {
            self.capture?.stopRunning()
        }
    }
    
    public override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            self.toolbar?.snp.updateConstraints({ (make) in
                make.bottom.equalTo(-self.view.safeAreaInsets.bottom)
            })
            super.viewSafeAreaInsetsDidChange()
        }
    }
    
    /// 关闭相机
    @objc func actionDimiss () {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 改变手电筒模式
    @objc func actionChangeFlashMode (sender:UIButton) {
        guard self.capture != nil else { return }
        do {
            let bundle = HCConfig.hc_resourceBundle()
            let device = AVCaptureDevice.default(for: .video)
            try device?.lockForConfiguration()
            if device?.torchMode == AVCaptureDevice.TorchMode.off {
                device?.torchMode = .on
                sender.setImage(UIImage.init(named: "hcTorchOn", in: bundle, compatibleWith: nil), for: .normal)
            } else if device?.torchMode == AVCaptureDevice.TorchMode.on {
                device?.torchMode = .off
                sender.setImage(UIImage.init(named: "hcTorchOff", in: bundle, compatibleWith: nil), for: .normal)
            }
            device?.unlockForConfiguration()
        } catch let error as NSError {
            let hud = HCHud.init(in: self.view, mode: .text, style: .dark)
            hud.label?.text = error.description
            hud.toast(afterDelay: 1.5, complete: nil)
        }
    }
    
    /// 拍照
    @objc func actionTakePhoto () {
        self.capture?.stopRunning()
        guard self.imageBufferRef != nil else {
            self.actionDimiss()
            return
        }
        // 将缓存区的图像转为CGImage
        CVPixelBufferLockBaseAddress(self.imageBufferRef!, .init(rawValue: 0))
        let address = CVPixelBufferGetBaseAddress(self.imageBufferRef!)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self.imageBufferRef!)
        let width = CVPixelBufferGetWidth(self.imageBufferRef!)
        let height = CVPixelBufferGetHeight(self.imageBufferRef!)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext.init(data: address, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let imageRef = context?.makeImage()
        // 在Swift中不需要做context、colorSpace、cgimage的release操作
        CVPixelBufferUnlockBaseAddress(self.imageBufferRef!, .init(rawValue: 0))
        if imageRef == nil {
            self.actionDimiss()
            return
        }
        // 根据裁剪框的实际位置计算裁剪区域
        let cropWidth = self.cropRect!.size.height / self.bufferView!.frame.size.height * bufferRect.size.width
        let cropHeight = self.cropRect!.size.width / self.bufferView!.frame.size.width * bufferRect.size.height
        let cropX = self.cropRect!.origin.y / self.bufferView!.frame.size.height * bufferRect.size.width + bufferRect.origin.x
        let cropY = (1-(self.cropRect!.origin.x+self.cropRect!.size.width)/self.bufferView!.frame.size.width)*bufferRect.size.height+bufferRect.origin.y
        let cropImage = UIImage.init(cgImage: imageRef!.cropping(to: CGRect.init(x: cropX, y: cropY, width: cropWidth, height: cropHeight))!, scale: 1.0, orientation: imageOrientation)
        self.takePhotoHandler?(cropImage)
        // 保存到相册
        if self.options.saveToAlbum == true {
            weak var weakSelf = self
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: cropImage)
            }) { (finish, error) in
                weakSelf?.actionDimiss()
            }
        } else {
            self.actionDimiss()
        }
    }
    
    /// 对焦
    ///
    /// - Parameter tap: 手势
    @objc func actionFocus (tap:UITapGestureRecognizer) {
        let point = tap.location(in: self.bufferView!)
        // 判断点击区域
        guard self.capture != nil && self.cropRect?.contains(point) == true else { return }
        do {
            // 对焦
            let device = AVCaptureDevice.default(for: .video)
            guard device?.isFocusPointOfInterestSupported == true else { return }
            try device?.lockForConfiguration()
            device?.focusPointOfInterest = CGPoint.init(x: (point.y/self.bufferView!.bounds.size.height*bufferRect.size.width+bufferRect.origin.x)/bufferSzie.width, y: ((1 - point.x/self.bufferView!.bounds.size.width)*bufferRect.size.height+bufferRect.origin.y)/bufferSzie.height)
            device?.focusMode = .autoFocus
            device?.unlockForConfiguration()
            // 动画
            self.focusIV?.center = point
            self.focusIV?.isHidden = false
            let animation = CABasicAnimation.init(keyPath: "transform.scale")
            animation.fromValue = 1.3
            animation.toValue = 1.0
            animation.duration = 0.5
            self.focusIV?.layer.removeAllAnimations()
            self.focusIV?.layer.add(animation, forKey: "scale")
            self.bufferView?.bringSubview(toFront: self.focusIV!)
            // 定时隐藏
            self.focusAnimationTimer?.invalidate()
            self.focusAnimationTimer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(self.hideFocusIV), userInfo: nil, repeats: false)
            RunLoop.main.add(self.focusAnimationTimer!, forMode: .commonModes)
            
        } catch let error as NSError {
            let hud = HCHud.init(in: self.view, mode: .text, style: .dark)
            hud.label?.text = error.description
            hud.toast(afterDelay: 1.5, complete: nil)
        }
    }
    
    @objc func hideFocusIV () {
        self.focusIV?.isHidden = true
        self.focusAnimationTimer?.invalidate()
        self.focusAnimationTimer = nil
    }
    
    /// 调整焦距
    ///
    /// - Parameter pinch: 捏合手势
    @objc func actionPinch (pinch:UIPinchGestureRecognizer) {
        guard self.capture != nil else {
            return
        }
        do {
            // 每次手势最后都会将scale设定成1，因此pinch.scale会在极小的范围中变化，此处减1得到变化值，再乘以1.5是为了更快的变焦
            var delta = (pinch.scale - 1)*1.5
            let device = AVCaptureDevice.default(for: .video)
            if pinch.state == .began {
                try device?.lockForConfiguration()
            } else if pinch.state == .changed {
                delta += device!.videoZoomFactor
                // 将焦距设定在1-10之内
                delta = min(10, max(1.0, delta))
                device?.videoZoomFactor = delta
            } else {
                device?.unlockForConfiguration()
            }
            pinch.scale = 1.0
        } catch let err as NSError {
            print(err)
        }
    }
    
    /// 初始化实时图像容器
    func setupBufferView () {
        let bufferView = UIView.init()
        bufferView.backgroundColor = .black
        bufferView.isUserInteractionEnabled = true
        bufferView.clipsToBounds = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.actionFocus(tap:)))
        bufferView.addGestureRecognizer(tap)
        let pinch = UIPinchGestureRecognizer.init(target: self, action: #selector(self.actionPinch(pinch:)))
        bufferView.addGestureRecognizer(pinch)
        self.view.addSubview(bufferView)
        bufferView.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
            make.width.equalTo(self.view)
            make.height.equalTo(self.view.snp.width).multipliedBy(16.0/9)
        }
        self.bufferView = bufferView
        
        let bundle = HCConfig.hc_resourceBundle()
        let focusImageView = UIImageView.init(image: UIImage.init(named: "hcCameraFocus", in: bundle, compatibleWith: nil))
        focusImageView.isUserInteractionEnabled = false
        focusImageView.frame = CGRect.init(x: 0, y: 0, width: 53, height: 40)
        focusImageView.isHidden = true
        self.bufferView!.addSubview(focusImageView)
        self.focusIV = focusImageView
    }
    
    /// 初始化底部几个按钮
    func setupToolbar () {
        let toolbar = UIView.init()
        toolbar.backgroundColor = .clear
        self.view.addSubview(toolbar)
        toolbar.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(80)
        }
        self.toolbar = toolbar
        let bundle = HCConfig.hc_resourceBundle()
        // 拍照按钮
        let btnTakePhoto = UIButton.init(type: .custom)
        btnTakePhoto.clipsToBounds = true
        btnTakePhoto.layer.cornerRadius = 30
        btnTakePhoto.backgroundColor = .white
        btnTakePhoto.layer.borderColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        btnTakePhoto.layer.borderWidth = 6
        btnTakePhoto.addTarget(self, action: #selector(self.actionTakePhoto), for: .touchUpInside)
        toolbar.addSubview(btnTakePhoto)
        btnTakePhoto.snp.makeConstraints { (make) in
            make.width.equalTo(60)
            make.height.equalTo(60)
            make.centerX.equalTo(toolbar)
            make.top.equalTo(0)
        }
        // 关闭按钮
        let btnClose = UIButton.init(type: .custom)
        btnClose.backgroundColor = .clear
        btnClose.setImage(UIImage.init(named: "hcClose", in: bundle, compatibleWith: nil), for: .normal)
        btnClose.addTarget(self, action: #selector(self.actionDimiss), for: .touchUpInside)
        toolbar.addSubview(btnClose)
        btnClose.snp.makeConstraints { (make) in
            make.width.equalTo(24)
            make.height.equalTo(24)
            make.left.equalTo(UIScreen.main.bounds.width/3/2-24/2)
            make.centerY.equalTo(btnTakePhoto.snp.centerY)
        }
        // 闪光灯按钮
        let btnFlash = UIButton.init(type: .custom)
        btnFlash.backgroundColor = .clear
        btnFlash.setImage(UIImage.init(named: "hcTorchOff", in: bundle, compatibleWith: nil), for: .normal)
        btnFlash.addTarget(self, action: #selector(self.actionChangeFlashMode(sender:)), for: .touchUpInside)
        toolbar.addSubview(btnFlash)
        btnFlash.snp.makeConstraints { (make) in
            make.centerY.equalTo(btnTakePhoto.snp.centerY)
            make.width.equalTo(32)
            make.height.equalTo(32)
            make.right.equalTo(-(UIScreen.main.bounds.size.width/3/2-32/2))
        }
    }
    
    /// 初始化相机对象
    func setupCapture () {
        do {
            let capture = AVCaptureSession.init()
            capture.sessionPreset = .high
            let device = AVCaptureDevice.default(for: .video)
            if device == nil {
                throw NSError.init(domain: "HCKitSwiftErrorDomain", code: 1001, userInfo: [NSLocalizedDescriptionKey:"该硬件不支持拍照"])
            }
            // 设置硬件参数，默认对焦、关闭闪光灯，最小帧率为15
            try device?.lockForConfiguration()
            device?.activeVideoMinFrameDuration = CMTime.init(value: 1, timescale: 15)
            if device?.isFocusModeSupported(.autoFocus) == true {
                device?.focusMode = .autoFocus
            }
            if device?.isFlashModeSupported(.auto) == true {
                device?.flashMode = .off
            }
            if device?.isTorchModeSupported(.auto) == true {
                device?.torchMode = .off
            }
            device?.unlockForConfiguration()
            // 设置输入输出对象
            let deviceInput = try AVCaptureDeviceInput.init(device: device!)
            capture.addInput(deviceInput)
            let dataOutput = AVCaptureVideoDataOutput.init()
            let outputQueue = DispatchQueue.init(label: "HCKit_Swift.HCCameraVCOuputQueue", qos: .unspecified, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
            dataOutput.setSampleBufferDelegate(self, queue: outputQueue)
            dataOutput.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey):kCMPixelFormat_32BGRA]
            capture.addOutput(dataOutput)
            let bufferLayer = AVCaptureVideoPreviewLayer.init(session: capture)
            bufferLayer.videoGravity = .resizeAspectFill
            bufferLayer.frame = self.bufferView!.bounds
            self.bufferView?.layer.addSublayer(bufferLayer)
            capture.startRunning()
            self.setupCropLayer()
            self.capture = capture
            self.indicator?.stopAnimating()
            self.view.bringSubview(toFront: self.toolbar!)
            self.bufferLayer = bufferLayer
        } catch let error as NSError {
            weak var weakSelf = self
            HCConfig.hc_alert(title: error.description, message: nil, cancelTitle: "好", cancelHandler: { (alert) in
                weakSelf?.dismiss(animated: true, completion: nil)
            }, confirmTitle: nil, confirmHandler: nil)
        }
    }
    
    /// 设置裁剪区域
    /// 计算规则：① 裁剪区域y不得低于状态栏；② 裁剪区域y+height不得高于底部按钮区域；③ 裁剪区域必须在bufferView中; ④ 根据options中的cropMargin进行缩进
    func setupCropLayer () {
        let cropLayer = CAShapeLayer.init()
        var cropRect = self.bufferView!.bounds
        if self.options.cropRatio != 0 {
            let maxY = min(self.toolbar!.frame.origin.y, self.bufferView!.frame.origin.y+self.bufferView!.frame.size.height)
            var usableHeight = maxY
            // 适配刘海屏
            if self.bufferView!.frame.origin.y > 0 {
                usableHeight -= self.bufferView!.frame.origin.y
            }
            if #available(iOS 11, *) {
                if self.bufferView!.frame.origin.y < self.view.safeAreaInsets.top {
                    usableHeight -= self.view.safeAreaInsets.top
                }
            }
            cropRect.size.width = cropRect.size.width - 2*self.options.cropMargin
            var height = cropRect.size.width / self.options.cropRatio
            if height > usableHeight {
                height = usableHeight - 2*self.options.cropMargin
                cropRect.size.width = height * self.options.cropRatio
            }
            cropRect.size.height = height
            cropRect.origin.x = (self.bufferView!.frame.size.width - cropRect.size.width)/2
            if self.bufferView!.frame.origin.y < 0 {
                cropRect.origin.y = maxY - self.bufferView!.frame.origin.y - height - self.options.cropMargin
            } else {
                cropRect.origin.y = (usableHeight - height)/2
            }
            // 适配刘海屏
            if #available(iOS 11, *) {
                if self.bufferView!.convert(cropRect, to: self.view).origin.y < self.view.safeAreaInsets.top {
                    cropRect.origin.y = self.view.safeAreaInsets.top+self.options.cropMargin/2
                }
            }
        }
        let path = CGMutablePath()
        path.addRect(self.bufferView!.bounds)
        path.addRect(cropRect)
        cropLayer.fillColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.75).cgColor
        cropLayer.fillRule = kCAFillRuleEvenOdd
        cropLayer.path = path
        self.bufferView?.layer.addSublayer(cropLayer)
        self.cropRect = cropRect
    }
    
    /// 初始化设备传感器
    func setupCoreMotion () {
        let motionMgr = CMMotionManager.init()
        motionMgr.accelerometerUpdateInterval = 0.2
        if motionMgr.isAccelerometerAvailable == false {
            return
        }
        weak var weakSelf = self
        motionMgr.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
            if weakSelf == nil || data == nil {
                return
            }
            // 设备的方向和摄像头采集的图像方向向右偏差了90度
            let acceleration = data!.acceleration;
            if (acceleration.x <= -0.7) {
                weakSelf!.imageOrientation = .up;
            } else if (acceleration.x >= 0.7) {
                weakSelf!.imageOrientation = .down;
            } else if (acceleration.y <= -0.7){
                weakSelf!.imageOrientation = .right;
            } else if (acceleration.y >= 0.7){
                weakSelf!.imageOrientation = .left;
            }
        }
        self.motionMgr = motionMgr
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.imageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)
        DispatchQueue.main.async {
            /// 由于图像设置的aspectFill模式，并且bufferView设定为全屏，因此实际图像会超过屏幕可视区域，先算出屏幕可视区域在原图像中的区域，由于原图像实际是横向的，bufferRect也设定为跟原图像一样的模式
            if self.bufferRect == .zero {
                let imageBuffer = self.imageBufferRef!
                CVPixelBufferLockBaseAddress(imageBuffer, .init(rawValue: 0))
                let width = CVPixelBufferGetWidth(imageBuffer)
                let height = CVPixelBufferGetHeight(imageBuffer)
                CVPixelBufferUnlockBaseAddress(imageBuffer, .init(rawValue: 0))
                let bufferSize = CGSize.init(width: CGFloat(width), height: CGFloat(height))
                let previewFrame = self.bufferView!.bounds
                var bufferRect = CGRect.zero
                if bufferSize.width / bufferSize.height < previewFrame.size.height / previewFrame.size.width {
                    bufferRect.size.width = bufferSize.width
                    bufferRect.size.height = previewFrame.size.width / previewFrame.size.height * bufferSize.width
                    bufferRect.origin.x = 0
                    bufferRect.origin.y = (bufferSize.height - bufferRect.size.height) / 2
                }
                else {
                    bufferRect.size.width = previewFrame.size.height / previewFrame.size.width * bufferSize.height
                    bufferRect.size.height = bufferSize.height
                    bufferRect.origin.y = 0
                    bufferRect.origin.x = (bufferSize.width - bufferRect.size.width) / 2
                }
                self.bufferRect = bufferRect
                self.bufferSzie = CGSize.init(width: width, height: height)
            }
        }
        }
}
