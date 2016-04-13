//
//  Pin.swift
//  Pods
//
//  Created by Nick Podratz on 29.09.15.
//
//

import Foundation

//
//  CheckmarkView.swift
//  Binarify
//
//  Created by Nick Podratz on 17.09.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
@IBDesignable
class PinView: UIVisualEffectView {
    
    @IBOutlet var label: UILabel!
    var pinLayer: PinLayer!
    
    @IBInspectable var cornerRadius: CGFloat = 10 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = cornerRadius > 0
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutPin()
    }
    
    private func layoutPin() {
        pinLayer = PinLayer()
        pinLayer.frame = CGRect(
            x: self.bounds.width/4,
            y: self.bounds.height/4,
            width: self.bounds.width/2,
            height: self.bounds.height/3
        )
        self.layer.addSublayer(pinLayer)
    }
    
}


class PinPath: UIBezierPath {
    
    /// Draw a UIBezierPath in the specified rectangle.
    init(rect: CGRect) {
        super.init()
        drawPinInRect(rect)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func drawPinInRect(rect: CGRect) {
        let width = rect.size.width
        let height = rect.size.height
        
        //// pin Drawing
        moveToPoint(CGPointMake(width * (11.33/24), height * (8.14/24)))
        addCurveToPoint(CGPointMake(width * (4.74/24), height * (9.73/24)), controlPoint1: CGPointMake(width * (6.56/24), height * (7.23/24)), controlPoint2: CGPointMake(width * (4.74/24), height * (9.73/24)))
        addLineToPoint(CGPointMake(width * (14.29/24), height * (19.29/24)))
        addCurveToPoint(CGPointMake(width * (15.88/24), height * (12.46/24)), controlPoint1: CGPointMake(width * (14.29/24), height * (19.29/24)), controlPoint2: CGPointMake(width * (16.79/24), height * (17.24/24)))
        addCurveToPoint(CGPointMake(width * (22.03/24), height * (8.14/24)), controlPoint1: CGPointMake(width * (20.89/24), height * (8.94/24)), controlPoint2: CGPointMake(width * (22.03/24), height * (8.14/24)))
        addLineToPoint(CGPointMake(width * (15.88/24), height * (2/24)))
        addCurveToPoint(CGPointMake(width * (11.33/24), height * (8.14/24)), controlPoint1: CGPointMake(width * (15.88/24), height * (2/24)), controlPoint2: CGPointMake(width * (14.52/24), height * (3.48/24)))
        closePath()
        lineJoinStyle = .Round
        
        //// needle Drawing
        moveToPoint(CGPointMake(width * (2.01/24), height * (22.02/24)))
        addCurveToPoint(CGPointMake(width * (8.19/24), height * (13.82/24)), controlPoint1: CGPointMake(width * (1.78/24), height * (21.8/24)), controlPoint2: CGPointMake(width * (8.19/24), height * (13.82/24)))
        addLineToPoint(CGPointMake(width * (10.18/24), height * (15.81/24)))
        addCurveToPoint(CGPointMake(width * (2.01/24), height * (22.02/24)), controlPoint1: CGPointMake(width * (10.18/24), height * (15.81/24)), controlPoint2: CGPointMake(width * (2.23/24), height * (22.24/24)))
    }
}

class PinCrossPath: UIBezierPath {
    
    /// Draw a UIBezierPath in the specified rectangle.
    init(rect: CGRect) {
        super.init()
        drawPinCrossInRect(rect)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func drawPinCrossInRect(rect: CGRect) {
        let width = rect.size.width
        let height = rect.size.height
        
        //// crossStroke Drawing
        moveToPoint(CGPointMake(width * (2.01/24), height * (2.01/24)))
        addLineToPoint(CGPointMake(width * (22.02/24), height * (22.02/24)))
    }
}

class PinLayer: CAShapeLayer {
    
    var color: UIColor = UIColor.blackColor() {
        didSet {
            strokeColor = color.CGColor
        }
    }
    
    override var frame: CGRect {
        didSet{
            super.frame = frame
            setupLayer()
        }
    }
    
    override var bounds: CGRect {
        didSet{
            super.bounds = bounds
            setupLayer()
        }
    }
    
    private func setupLayer() {
        path = PinPath(rect: bounds).CGPath
        strokeColor = color.CGColor
        fillColor = nil
        lineWidth = 2
        lineJoin = kCALineJoinRound
        lineCap = kCALineCapRound
    }
    
    func animateHoverIn() {
        let fromPoint = CGPoint(x: self.frame.origin.x + 160, y: self.frame.origin.x - 160)
        let toPoint = CGPoint(x: self.frame.origin.x + self.frame.size.width/2, y: self.frame.origin.y + self.frame.size.height/2)

        let animation1 = CABasicAnimation(keyPath: "position")
        animation1.duration = 0
        animation1.fromValue = self.valueForKey("position")
        animation1.toValue = NSValue(CGPoint: fromPoint)
        self.position = fromPoint
        self.addAnimation(animation1, forKey: "position")
        
        let animation2 = CABasicAnimation(keyPath: "position")
        animation2.duration = 0.4
        animation2.fromValue = self.valueForKey("position")
        animation2.toValue = NSValue(CGPoint: toPoint)
        self.position = toPoint
        self.addAnimation(animation2, forKey: "position")
    }
}

class PinCrossLayer: CAShapeLayer {
        
    var color: UIColor = UIColor.blackColor() {
        didSet {
            strokeColor = color.CGColor
        }
    }
    
    override var frame: CGRect {
        didSet{
            super.frame = frame
            setupLayer()
        }
    }
    
    override var bounds: CGRect {
        didSet{
            super.bounds = bounds
            setupLayer()
        }
    }
    
    private func setupLayer() {
//        backgroundColor = UIColor.blackColor().CGColor
        
        let pinCrossPath = PinCrossPath(rect: bounds)
//        outerPath.usesEvenOddFillRule = true
//        outerPath.appendPath(pinCrossPath.bezierPathByReversingPath())
        path = pinCrossPath.CGPath
        lineJoin = kCALineJoinRound
        lineCap = kCALineCapRound
        strokeColor = color.CGColor
        lineWidth = 3
        fillRule = kCAFillRuleEvenOdd
    }
    
    func animateCrossOut() {
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 0.3
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 1
        self.addAnimation(pathAnimation, forKey: "strokeEnd")
    }
    
}