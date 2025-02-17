//
//  Extensions.swift
//  Rhetorica
//
//  Created by Nick Podratz on 11.07.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import UIKit

extension UIImage {
    
    convenience init?(color: UIColor) {
        self.init(color: color, size: CGSize(width: 1, height: 1))
    }
    
    convenience init?(color: UIColor, size: CGSize) {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        UIGraphicsBeginImageContext(size);
        //        let path = UIBezierPath(rect: rect)
        
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.init(cgImage: image!.cgImage!)
    }
    
    static func transparentWhiteImage() -> UIImage? {
        return UIImage(color: (UIColor(white: 1, alpha: 0)))
    }
    
    static func transparentLightGreyImage() -> UIImage? {
        return UIImage(color: (UIColor(white: 0.33, alpha: 0)))
    }
    
    func averageColor() -> UIColor {
        
        let rgba = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context: CGContext = CGContext(data: rgba, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: info.rawValue)!
        
        context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        if rgba[3] > 0 {
            
            let alpha: CGFloat = CGFloat(rgba[3]) / 255.0
            let multiplier: CGFloat = alpha / 255.0
            
            return UIColor(red: CGFloat(rgba[0]) * multiplier, green: CGFloat(rgba[1]) * multiplier, blue: CGFloat(rgba[2]) * multiplier, alpha: alpha)
            
        } else {
            
            return UIColor(red: CGFloat(rgba[0]) / 255.0, green: CGFloat(rgba[1]) / 255.0, blue: CGFloat(rgba[2]) / 255.0, alpha: CGFloat(rgba[3]) / 255.0)
        }
    }
    
    func getScaleToFillSize(_ sizeConst: CGFloat) -> CGSize {
        var newSize: CGSize!
        if self.size.width > self.size.height {
            newSize = CGSize(
                width: self.size.width / (self.size.height / sizeConst) * 2,
                height: sizeConst * 2
            )
        } else {
            newSize = CGSize(
                width: sizeConst * 2,
                height: self.size.height / (self.size.width / sizeConst) * 2
            )
        }
        return newSize
    }
    
    typealias resizedImage = (_ resizedImage:UIImage)->()
    public func resize(_ size:CGSize, completionHandler: @escaping (_ resizedImage: UIImage) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
            let newSize:CGSize = size
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            DispatchQueue.main.async(execute: { () -> Void in
                completionHandler(newImage!)
            })
        })
    }
}
