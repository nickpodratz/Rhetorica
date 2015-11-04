//
//  QuizButton.swift
//  Rhetorica
//
//  Created by Nick Podratz on 30.10.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit
import AudioToolbox

@IBDesignable
class QuizButton: RoundedButton {
    
    
    // MARK: Colors
    @IBInspectable var color: UIColor = UIColor.rhetoricaGreyColor() {
        didSet{
            self.backgroundColor = color
        }
    }
    @IBInspectable var colorSelected: UIColor = UIColor.rhetoricaPurpleColor()
    @IBInspectable var colorCorrect: UIColor = UIColor.rhetoricaGreenColor()
    @IBInspectable var colorFalse: UIColor = UIColor.rhetoricaRedColor()
    
    
    // MARK: Animations
    
    func animateTouched(completionHandler: (() -> ())? = nil) {
        UIView.animateWithDuration(0.05, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.backgroundColor = self.colorSelected
            }, completion: { _ in
                completionHandler?()
        })
        
    }
    
    func animateUntouched(completionHandler: (() -> ())? = nil) {
        UIView.animateWithDuration(0.35, delay: 0.22, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.backgroundColor = self.color
            },completion: { _ in
        })
        
    }
    
    func animateToNormal(completionHandler: (() -> ())? = nil) {
        UIView.animateWithDuration(0.8, delay: 0.9, options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.backgroundColor = self.color
            },
            completion: { _ in
                completionHandler?()
            }
        )
    }
    
    func animateIsCorrect(completionHandler: (() -> ())? = nil) {
        UIView.animateWithDuration(0.16, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.backgroundColor = self.colorCorrect
            },
            completion: { _ in
                completionHandler?()
            }
        )
    }
    
    func animateIsFalse(completionHandler: (() -> ())? = nil) {
        UIView.animateWithDuration(0.16, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn,
            animations: {
                self.backgroundColor = self.colorFalse
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            },completion: { _ in
                completionHandler?()
        })
    }

}