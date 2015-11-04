//
//  QuizButton.swift
//  Rhetorica
//
//  Created by Nick Podratz on 30.10.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit
import AudioToolbox

class QuizButton: RoundedButton {}


// MARK: - QuizButton + Animations

extension QuizButton {
    
    func animateTouched(completionHandler: (() -> ())? = nil) {
        UIView.animateWithDuration(0.05, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.backgroundColor = QuizButton.purpleSelectedColor()
            }, completion: { _ in
                completionHandler?()
        })
        
    }

    func animateUntouched(completionHandler: (() -> ())? = nil) {
        UIView.animateWithDuration(0.35, delay: 0.22, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.backgroundColor = QuizButton.purpleColor()
            },completion: { _ in
        })
        
    }

    func animateToNormal(completionHandler: (() -> ())? = nil) {
        UIView.animateWithDuration(0.8, delay: 0.9, options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.backgroundColor = QuizButton.purpleColor()
            },
            completion: { _ in
                completionHandler?()
            }
        )
    }

    func animateIsCorrect(completionHandler: (() -> ())? = nil) {
        UIView.animateWithDuration(0.16, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.backgroundColor = QuizButton.greenColor()
            },
            completion: { _ in
                completionHandler?()
            }
        )
    }

    func animateIsFalse(completionHandler: (() -> ())? = nil) {
        UIView.animateWithDuration(0.16, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn,
            animations: {
                self.backgroundColor = QuizButton.redColor()
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            },completion: { _ in
                completionHandler?()
        })
    }
}



// MARK: - QuizButton + Colors

extension QuizButton {
    class func redColor() -> UIColor {
        return UIColor(red:193/256, green:53/256, blue:53/256, alpha:1)
    }
    
    class func greenColor() -> UIColor {
//        return UIColor(red:196/256, green:182/256, blue:51/256, alpha:1)
//        return UIColor(red:188/256, green:162/256, blue:23/256, alpha:1)
//        return UIColor(red:188/256, green:163/256, blue:23/256, alpha:1)
        return UIColor(red:171/256, green:184/256, blue:36/256, alpha:1)
    }
    
    class func purpleColor() -> UIColor {
//        return UIColor(red:145/256, green:43/256, blue:92/256, alpha:1)
        return UIColor(red:135/256, green:53/256, blue:100/256, alpha:1)
    }
    
    class func purpleSelectedColor() -> UIColor {
        return UIColor(red:145/256, green:43/256, blue:92/256, alpha:0.9)
    }
    
}

