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
        self.init(color: color, size: CGSizeMake(1, 1))
    }
    
    convenience init?(color: UIColor, size: CGSize) {
        let rect = CGRect(origin: CGPointZero, size: size)
        
        UIGraphicsBeginImageContext(size);
        //        let path = UIBezierPath(rect: rect)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.init(CGImage: image.CGImage!)
    }
    
    static func transparentWhiteImage() -> UIImage? {
        return UIImage(color: (UIColor(white: 1, alpha: 0)))
    }
    
    static func transparentLightGreyImage() -> UIImage? {
        return UIImage(color: (UIColor(white: 0.33, alpha: 0)))
    }
    
    func averageColor() -> UIColor {
        
        let rgba = UnsafeMutablePointer<CUnsignedChar>.alloc(4)
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context: CGContextRef = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, info.rawValue)!
        
        CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage)
        
        if rgba[3] > 0 {
            
            let alpha: CGFloat = CGFloat(rgba[3]) / 255.0
            let multiplier: CGFloat = alpha / 255.0
            
            return UIColor(red: CGFloat(rgba[0]) * multiplier, green: CGFloat(rgba[1]) * multiplier, blue: CGFloat(rgba[2]) * multiplier, alpha: alpha)
            
        } else {
            
            return UIColor(red: CGFloat(rgba[0]) / 255.0, green: CGFloat(rgba[1]) / 255.0, blue: CGFloat(rgba[2]) / 255.0, alpha: CGFloat(rgba[3]) / 255.0)
        }
    }
    
    func getScaleToFillSize(sizeConst: CGFloat) -> CGSize {
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
    
    typealias resizedImage = (resizedImage:UIImage)->()
    public func resize(size:CGSize, completionHandler: (resizedImage: UIImage) -> Void) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            let newSize:CGSize = size
            let rect = CGRectMake(0, 0, newSize.width, newSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.drawInRect(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(resizedImage: newImage)
            })
        })
    }
}
