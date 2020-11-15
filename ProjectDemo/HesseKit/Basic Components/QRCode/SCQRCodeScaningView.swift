//
//  SCQRCodeScaningView.swift
//  SACO
//
//  Created by Hesse Huang on 2017/4/17.
//  Copyright © 2017年 Guangzhou Toodony Tech. Ltd. All rights reserved.
//

import UIKit
import AVFoundation

class SCQRCodeScaningView: UIView {
    
    private var preview: AVCaptureVideoPreviewLayer!

    init(session: AVCaptureSession) {
        super.init(frame: Screen.bounds)
        setup(session: session)
        backgroundColor = .lightGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let keyRect: CGRect = {
        let w = Screen.width * 240 / 375
        let x = (Screen.width - w) / 2
        let y = Screen.height * 188 / 667
        return CGRect(x: x, y: y, width: w, height: w)
    }()
    
    let descriptionLabel = UILabel()
    let scaningLine = CALayer()
    private(set) var scanningAnimation: CABasicAnimation?
    
    var rectOfInterest: CGRect {
        return CGRect(x: keyRect.origin.y / Screen.height, y: keyRect.origin.x / Screen.width, width: keyRect.height / Screen.height, height: keyRect.width / Screen.width)
    }
    
    
    private func setup(session: AVCaptureSession) {
        
        // 写四个半透明黑色layer
        
        let topLayer = CALayer()
        topLayer.frame = CGRect(x: 0, y: 0, width: Screen.width, height: keyRect.origin.y)
        
        let leftLayer = CALayer()
        leftLayer.frame = CGRect(x: 0, y: keyRect.origin.y, width: keyRect.origin.x, height: keyRect.height)
        
        let rightLayer = CALayer()
        rightLayer.frame = CGRect(x: keyRect.maxX, y: keyRect.origin.y, width: keyRect.origin.x, height: keyRect.height)
        
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: keyRect.maxY, width: Screen.width, height: Screen.height - keyRect.maxY)
        
        layer.addSublayer(topLayer)
        layer.addSublayer(leftLayer)
        layer.addSublayer(rightLayer)
        layer.addSublayer(bottomLayer)
        layer.sublayers?.forEach {
            $0.backgroundColor = UIColor(white: 0, alpha: 0.4).cgColor
        }

        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = layer.bounds
        preview.videoGravity = .resizeAspectFill
        layer.insertSublayer(preview, at: 0)
        
        let keyRectView = KeyRectView(frame: keyRect)
        keyRectView.isOpaque = false
        addSubview(keyRectView)
        
        
        scaningLine.frame = CGRect(x: 20, y: 20, width: keyRect.width - 20 * 2, height: 0.5)
        scaningLine.backgroundColor = UIColor.white.cgColor
        keyRectView.layer.addSublayer(scaningLine)
        
        resetAnimiation()
        
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = .white
        updateDescriptionLabelPosition()
        addSubview(descriptionLabel)
    }
    
    
    func updateDescriptionLabelPosition() {
        descriptionLabel.sizeToFit()
        descriptionLabel.center.x = center.x
        descriptionLabel.frame.origin.y = keyRect.maxY + 24
    }
    
    func resetAnimiation() {
        scaningLine.removeAnimation(forKey: "scaning")
        let scanningAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        scanningAnimation.fromValue = 0
        scanningAnimation.toValue = keyRect.height - 20 * 2
        scanningAnimation.duration = 1.75
        scanningAnimation.repeatCount = 100000
        scaningLine.add(scanningAnimation, forKey: "scaning")
        self.scanningAnimation = scanningAnimation
    }
    
}

private class KeyRectView: UIView {
    
    override func draw(_ rect: CGRect) {
        let c = UIGraphicsGetCurrentContext()!
        
        // 每个角的边长a
        let a: CGFloat = 12
        c.setLineWidth(2)
        c.setStrokeColor(UIColor.white.cgColor)
        
        let rect = rect.insetBy(dx: 1, dy: 1)
        c.addLines(between: [
            rect.topLeft.offseted(y: a),
            rect.topLeft,
            rect.topLeft.offseted(x: a)
            ])
        c.addLines(between: [
            rect.topRight.offseted(x: -a),
            rect.topRight,
            rect.topRight.offseted(y: a)
            ])
        c.addLines(between: [
            rect.bottomLeft.offseted(y: -a),
            rect.bottomLeft,
            rect.bottomLeft.offseted(x: a)
            ])
        c.addLines(between: [
            rect.bottomRight.offseted(x: -a),
            rect.bottomRight,
            rect.bottomRight.offseted(y: -a)
            ])
        
        c.strokePath()
    }

    
}
