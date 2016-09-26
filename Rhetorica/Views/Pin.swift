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
    
    fileprivate func layoutPin() {
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
    
    fileprivate func drawPinInRect(_ rect: CGRect) {
        let width = rect.size.width
        let height = rect.size.height
        
        //// pin Drawing
        move(to: CGPoint(x: width * (11.33/24), y: height * (8.14/24)))
        addCurve(to: CGPoint(x: width * (4.74/24), y: height * (9.73/24)), controlPoint1: CGPoint(x: width * (6.56/24), y: height * (7.23/24)), controlPoint2: CGPoint(x: width * (4.74/24), y: height * (9.73/24)))
        addLine(to: CGPoint(x: width * (14.29/24), y: height * (19.29/24)))
        addCurve(to: CGPoint(x: width * (15.88/24), y: height * (12.46/24)), controlPoint1: CGPoint(x: width * (14.29/24), y: height * (19.29/24)), controlPoint2: CGPoint(x: width * (16.79/24), y: height * (17.24/24)))
        addCurve(to: CGPoint(x: width * (22.03/24), y: height * (8.14/24)), controlPoint1: CGPoint(x: width * (20.89/24), y: height * (8.94/24)), controlPoint2: CGPoint(x: width * (22.03/24), y: height * (8.14/24)))
        addLine(to: CGPoint(x: width * (15.88/24), y: height * (2/24)))
        addCurve(to: CGPoint(x: width * (11.33/24), y: height * (8.14/24)), controlPoint1: CGPoint(x: width * (15.88/24), y: height * (2/24)), controlPoint2: CGPoint(x: width * (14.52/24), y: height * (3.48/24)))
        close()
        lineJoinStyle = .round
        
        //// needle Drawing
        move(to: CGPoint(x: width * (2.01/24), y: height * (22.02/24)))
        addCurve(to: CGPoint(x: width * (8.19/24), y: height * (13.82/24)), controlPoint1: CGPoint(x: width * (1.78/24), y: height * (21.8/24)), controlPoint2: CGPoint(x: width * (8.19/24), y: height * (13.82/24)))
        addLine(to: CGPoint(x: width * (10.18/24), y: height * (15.81/24)))
        addCurve(to: CGPoint(x: width * (2.01/24), y: height * (22.02/24)), controlPoint1: CGPoint(x: width * (10.18/24), y: height * (15.81/24)), controlPoint2: CGPoint(x: width * (2.23/24), y: height * (22.24/24)))
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
    
    fileprivate func drawPinCrossInRect(_ rect: CGRect) {
        let width = rect.size.width
        let height = rect.size.height
        
        //// crossStroke Drawing
        move(to: CGPoint(x: width * (2.01/24), y: height * (2.01/24)))
        addLine(to: CGPoint(x: width * (22.02/24), y: height * (22.02/24)))
    }
}

class PinLayer: CAShapeLayer {
    
    var color: UIColor = UIColor.black {
        didSet {
            strokeColor = color.cgColor
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
    
    fileprivate func setupLayer() {
        path = PinPath(rect: bounds).cgPath
        strokeColor = color.cgColor
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
        animation1.fromValue = self.value(forKey: "position")
        animation1.toValue = NSValue(cgPoint: fromPoint)
        self.position = fromPoint
        self.add(animation1, forKey: "position")
        
        let animation2 = CABasicAnimation(keyPath: "position")
        animation2.duration = 0.4
        animation2.fromValue = self.value(forKey: "position")
        animation2.toValue = NSValue(cgPoint: toPoint)
        self.position = toPoint
        self.add(animation2, forKey: "position")
    }
}

class PinCrossLayer: CAShapeLayer {
        
    var color: UIColor = UIColor.black {
        didSet {
            strokeColor = color.cgColor
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
    
    fileprivate func setupLayer() {
//        backgroundColor = UIColor.blackColor().CGColor
        
        let pinCrossPath = PinCrossPath(rect: bounds)
//        outerPath.usesEvenOddFillRule = true
//        outerPath.appendPath(pinCrossPath.bezierPathByReversingPath())
        path = pinCrossPath.cgPath
        lineJoin = kCALineJoinRound
        lineCap = kCALineCapRound
        strokeColor = color.cgColor
        lineWidth = 3
        fillRule = kCAFillRuleEvenOdd
    }
    
    func animateCrossOut() {
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 0.3
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 1
        self.add(pathAnimation, forKey: "strokeEnd")
    }
    
}
