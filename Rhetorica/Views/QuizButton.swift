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
    @IBInspectable var color: UIColor = UIColor.rhetoricaPurpleColor() {
        didSet{
            self.backgroundColor = color
        }
    }
    @IBInspectable var colorSelected: UIColor = UIColor.rhetoricaPurpleColor()
    @IBInspectable var colorCorrect: UIColor = UIColor.rhetoricaGreenColor()
    @IBInspectable var colorFalse: UIColor = UIColor.rhetoricaRedColor()
    
    
    // MARK: Animations
    
    func animateTouched(_ completionHandler: (() -> ())? = nil) {
        UIView.animate(withDuration: 0.05, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.backgroundColor = self.colorSelected
            }, completion: { _ in
                completionHandler?()
        })
        
    }
    
    func animateUntouched(_ completionHandler: (() -> ())? = nil) {
        UIView.animate(withDuration: 0.35, delay: 0.22, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.backgroundColor = self.color
            },completion: { _ in
        })
        
    }
    
    func animateToNormal(_ completionHandler: (() -> ())? = nil) {
        UIView.animate(withDuration: 0.8, delay: 0.9, options: UIViewAnimationOptions.curveEaseOut,
            animations: {
                self.backgroundColor = self.color
            },
            completion: { _ in
                completionHandler?()
            }
        )
    }
    
    func animateIsCorrect(_ completionHandler: (() -> ())? = nil) {
        UIView.animate(withDuration: 0.16, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut,
            animations: {
                self.backgroundColor = self.colorCorrect
            },
            completion: { _ in
                completionHandler?()
            }
        )
    }
    
    func animateIsFalse(_ completionHandler: (() -> ())? = nil) {
        UIView.animate(withDuration: 0.16, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn,
            animations: {
                self.backgroundColor = self.colorFalse
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            },completion: { _ in
                completionHandler?()
        })
    }

}
