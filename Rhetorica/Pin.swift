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
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    
    */
    
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
        moveToPoint(CGPointMake(width * (42/91), height * (29/91)))
        addCurveToPoint(CGPointMake(width * (13/91), height * (36/91)), controlPoint1: CGPointMake(width * (21/91), height * (25/91)), controlPoint2: CGPointMake(width * (13/91), height * (36/91)))
        addLineToPoint(CGPointMake(width * (55/91), height * (78/91)))
        addCurveToPoint(CGPointMake(width * (62/91), height * (48/91)), controlPoint1: CGPointMake(width * (55/91), height * (78/91)), controlPoint2: CGPointMake(width * (66/91), height * (69/91)))
        addCurveToPoint(CGPointMake(width * (89/91), height * (29/91)), controlPoint1: CGPointMake(width * (84/91), height * (32.5/91)), controlPoint2: CGPointMake(width * (89/91), height * (29/91)))
        addLineToPoint(CGPointMake(width * (62/91), height * (2/91)))
        addCurveToPoint(CGPointMake(width * (42/91), height * (29/91)), controlPoint1: CGPointMake(width * (62/91), height * (2/91)), controlPoint2: CGPointMake(width * (56/91), height * (8.5/91)))
        closePath()

        
        //// needle Drawing
        moveToPoint(CGPointMake(width * (1/91), height * (90/91)))
        addCurveToPoint(CGPointMake(width * (29/91), height * (53/91)), controlPoint1: CGPointMake(0, height * (89/91)), controlPoint2: CGPointMake(width * (29/91), height * (53/91)))
        addLineToPoint(CGPointMake(width * (38/91), height * (62/91)))
        addCurveToPoint(CGPointMake(width * (1/91), height * (90/91)), controlPoint1: CGPointMake(width * (38/91), height * (62/91)), controlPoint2: CGPointMake(width * (2/91), height * (91/91)))
        closePath()
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
        
        //// crossStrokeShadow Drawing
        moveToPoint(CGPointMake(width * 20/91, height * 8/91))
        addLineToPoint(CGPointMake(width * 83/91, height * 71/91))
        
        //// crossStroke Drawing
        moveToPoint(CGPointMake(width * 20/91, height * 8/91))
        addLineToPoint(CGPointMake(width * 83/91, height * 71/91))
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
        strokeColor = UIColor.blackColor().CGColor
        fillColor = nil
        lineWidth = 3
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
        strokeColor = color.CGColor
        lineWidth = 6
        fillRule = kCAFillRuleEvenOdd
    }
    
    func animateCrossOut() {
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 0.5
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 1
        self.addAnimation(pathAnimation, forKey: "strokeEnd")
    }
    
}