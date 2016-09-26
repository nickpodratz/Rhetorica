//
//  UIImage+Resize.swift
//  Binarify
//
//  Created by Nick Podratz on 27.10.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(_ newSize: CGSize) -> UIImage {
        let image = self
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(newSize, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext() // !!!
        return scaledImage!
    }
}
