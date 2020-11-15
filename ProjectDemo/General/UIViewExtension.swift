//
//  UIViewExtension.swift
//  inDinero
//
//  Created by KK Chen on 31/12/2016.
//  Copyright © 2016 inDinero. All rights reserved.
//

import UIKit
import Kingfisher

extension UIView {
    
    func animate(toAlpha alpha: CGFloat) {
        UIView.animate(withDuration: 0.3) { 
            self.alpha = alpha
        }
    }
    
    func setThemeShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 4
    }
    
}

public extension Data {

    static func dataFromJSONFile(_ fileName: String) -> Data? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
                return data
            } catch let error as NSError {
                print(error.localizedDescription)
                return nil
            }
        } else {
            return nil
        }
    }
}
extension Array {

    func item(before index: Int) -> Element? {
        if index < 1 {
            return nil
        }

        if index > count {
            return nil
        }

        return self[index - 1]
    }

    func item(after index: Int) -> Element? {
        if index < -1 {
            return nil
        }

        if index <= count - 2 {
            return self[index + 1]
        }

        return nil
    }
}

extension UIImageView {

    func setImage(with resource: URL?, placeholder: UIImage? = nil) {
        let optionInfo: KingfisherOptionsInfo = [
            .transition(.fade(0.25)),
            .cacheOriginalImage
        ]

        kf.setImage(with: resource, placeholder: placeholder, options: optionInfo)
    }
}

extension UIBezierPath {

    public convenience init(roundedRect rect: CGRect,
                            topLeftRadius: CGFloat?,
                            topRightRadius: CGFloat?,
                            bottomLeftRadius: CGFloat?,
                            bottomRightRadius: CGFloat?) {
        self.init()

        assert(((bottomLeftRadius ?? 0) + (bottomRightRadius ?? 0)) <= rect.size.width)
        assert(((topLeftRadius ?? 0) + (topRightRadius ?? 0)) <= rect.size.width)
        assert(((topLeftRadius ?? 0) + (bottomLeftRadius ?? 0)) <= rect.size.height)
        assert(((topRightRadius ?? 0) + (bottomRightRadius ?? 0)) <= rect.size.height)

        // corner centers
        let tl = CGPoint(x: rect.minX + (topLeftRadius ?? 0), y: rect.minY + (topLeftRadius ?? 0))
        let tr = CGPoint(x: rect.maxX - (topRightRadius ?? 0), y: rect.minY + (topRightRadius ?? 0))
        let bl = CGPoint(x: rect.minX + (bottomLeftRadius ?? 0), y: rect.maxY - (bottomLeftRadius ?? 0))
        let br = CGPoint(x: rect.maxX - (bottomRightRadius ?? 0), y: rect.maxY - (bottomRightRadius ?? 0))

        //let topMidpoint = CGPoint(rect.midX, rect.minY)
        let topMidpoint = CGPoint(x: rect.midX, y: rect.minY)

        makeClockwiseShape: do {
            self.move(to: topMidpoint)

            if let topRightRadius = topRightRadius {
                self.addLine(to: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY))
                self.addArc(withCenter: tr, radius: topRightRadius, startAngle: -CGFloat.pi * 0.5, endAngle: 0, clockwise: true)
            }
            else {
                self.addLine(to: tr)
            }

            if let bottomRightRadius = bottomRightRadius {
                self.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRightRadius))
                self.addArc(withCenter: br, radius: bottomRightRadius, startAngle: 0, endAngle: CGFloat.pi * 0.5, clockwise: true)
            }
            else {
                self.addLine(to: br)
            }

            if let bottomLeftRadius = bottomLeftRadius {
                self.addLine(to: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY))
                self.addArc(withCenter: bl, radius: bottomLeftRadius, startAngle: CGFloat.pi * 0.5, endAngle: CGFloat.pi, clockwise: true)
            }
            else {
                self.addLine(to: bl)
            }

            if let topLeftRadius = topLeftRadius {
                self.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeftRadius))
                self.addArc(withCenter: tl, radius: topLeftRadius, startAngle: CGFloat.pi, endAngle: -CGFloat.pi * 0.5, clockwise: true)
            }
            else {
                self.addLine(to: tl)
            }

            self.close()
        }
    }
}

