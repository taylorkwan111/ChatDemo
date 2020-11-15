//
//  UIImageExtension.swift
//  inDinero
//
//  Created by KK Chen on 8/12/2016.
//  Copyright © 2016 inDinero. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in:         CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize: newSize)
        return resized
    }
    
    func scaledImage(width: CGFloat) -> UIImage {
        let sourceImage = self
        let oldWidth: CGFloat = sourceImage.size.width
        let scaleFactor: CGFloat = width / oldWidth
        let newHeight: CGFloat = sourceImage.size.height * scaleFactor
        let newWidth: CGFloat = oldWidth * scaleFactor
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight));
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    func resizedImageBase64EncodedString() -> String {
        var attachmentImage = self
        if self.size.width > 1000 {
            attachmentImage = attachmentImage.scaledImage(width: 1000)
        }
        let data: Data = attachmentImage.jpegData(compressionQuality: 0.5)!
        return data.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
    }
        
}

extension UIImage {
    static let loginCheckmark: UIImage? = {
        let size = CGSize(width: 26, height: 26)
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineCap(.round)
        context?.setLineWidth(2.0)
        context?.move(to: CGPoint(x: 0.25 * size.width, y: 0.55556 * size .height))
        context?.addLine(to: CGPoint(x: 0.416667 * size.width, y: 0.72222 * size.height))
        context?.addLine(to: CGPoint(x: 0.75 * size.width, y: 0.333333 * size.height))
        context?.strokePath()
        return UIGraphicsGetImageFromCurrentImageContext()
    }()
}
