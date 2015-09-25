//
//  QuizViewController.swift
//  Rhetorica
//
//  Created by Nick Podratz on 05.11.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit
import AudioToolbox


class QuizViewController: UIViewController, UIActionSheetDelegate {

    
    // MARK: - Outlets

    @IBOutlet var questionView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    
    
    // MARK: - Properties

    weak var deviceList: DeviceList!
    var tagOfCorrectAnswer: Int!
    
    // Answer-logging
    var counterOfCorrectAnswers = 0
    var counterOfQuestions = 0
    
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        setupViewForNewRound()
    }
    
    
    // MARK: - Transitioning

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "showResult" {
            let controller = segue.destinationViewController as! QuizResultViewController
            controller.numberOfCorrectAnswers = self.counterOfCorrectAnswers
            controller.numberOfQuestions = self.counterOfQuestions
        }
    }

    
    // MARK: - User Interaction

    /// Called when Button is pushed down
    @IBAction func fadeIn(sender: UIButton) {
        UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            sender.backgroundColor = UIColor(red: 0.629, green: 0.206, blue: 0.625, alpha: 1.0)
        }, completion: nil)
    }
    
    /// Called when Button is cancelled
    @IBAction func fadeOut(sender: UIButton) {
        UIView.animateWithDuration(0.7, delay: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            sender.backgroundColor = UIColor.purpleColor()
            },completion: { _ in
                sleep(1)
                UIView.animateWithDuration(0.7, delay: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    sender.backgroundColor = UIColor.purpleColor()
            }, completion: nil)
        })

    }
    
    @IBAction func cancel(sender: AnyObject) {
        // let actionSheet = UIActionSheet(title: "Dieses Quiz wirklich beenden? Der Spielforschritt geht in diesem Fall verloren.", delegate: self, cancelButtonTitle: "abbrechen", destructiveButtonTitle: "Quiz beenden")
        dismissViewControllerAnimated(true, completion: nil)
        // actionSheet.actionSheetStyle = .Default
        // actionSheet.showInView(self.view)
    }
/*
    // MARK: UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        println(buttonIndex)
        switch buttonIndex {
        case  0: dismissViewControllerAnimated(true, completion: nil)
        default: break
        }
    }
*/

    @IBAction func buttonKlicked(sender: UIButton) {
        counterOfQuestions += 1
        for button in buttons {
            button.userInteractionEnabled = false
        }
        
        let correctButton: UIButton = buttons[tagOfCorrectAnswer]

        // Correct Answer
        if sender.tag == tagOfCorrectAnswer {
            UIView.animateWithDuration(0.16, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    sender.backgroundColor = UIColor.greenColor()
                },
                completion: { _ in
                    UIView.animateWithDuration(0.8, delay: 0.9, options: UIViewAnimationOptions.CurveEaseOut,
                        animations: {
                            sender.backgroundColor = UIColor.purpleColor()
                        },
                        completion: { _ in
                            self.counterOfCorrectAnswers++
                            self.setupViewForNewRound()
                        }
                    )
                }
            )
            
        // Wrong Answer
        } else {
            UIView.animateWithDuration(0.16, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn,
                animations: {
                    sender.backgroundColor = UIColor.redColor()
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                },
                completion: { _ in
                    UIView.animateWithDuration(0.55, delay: 0.8, options: UIViewAnimationOptions.CurveEaseOut,
                        animations: {
                            sender.backgroundColor = UIColor.purpleColor()
                            correctButton.backgroundColor = UIColor.greenColor()
                        },
                        completion: { _ in
                            UIView.animateWithDuration(0.8, delay: 1.52, options: UIViewAnimationOptions.CurveEaseOut,
                                animations: {
                                    correctButton.backgroundColor = UIColor.purpleColor()
                                },
                                completion: { _ in
                                    self.setupViewForNewRound()
                                }
                            )
                        }
                    )
                }
            )
        }
    }
    
    
    // MARK: - Private Functions
    
    /** - returns: a random Device from the 'devices' array. */
    private func getRandomDevice() -> StylisticDevice {
        let randomNumber = Int(arc4random_uniform(UInt32(deviceList.elements.count)))
        return deviceList[randomNumber]
    }
    
    private func setupViewForNewRound() {
        self.navigationItem.title = "\(counterOfCorrectAnswers) von \(counterOfQuestions) richtig"
        
        // Choosing four random devices
        var newDevices = [StylisticDevice]()
        
        for _ in buttons.indices {
            var newRandomDevice: StylisticDevice
            repeat {
                newRandomDevice = getRandomDevice()
            } while (newDevices.contains(newRandomDevice))
            
            newDevices.append(newRandomDevice)
        }
        
        // Appoint correct device
        self.tagOfCorrectAnswer = Int(arc4random_uniform(4))
        
        // Configuring the buttons
        for button in buttons {
            button.userInteractionEnabled = true
            button.backgroundColor = UIColor.purpleColor()
        }
        for (buttonIndex, button) in buttons.enumerate() {
            button.setTitle(newDevices[buttonIndex].title, forState: UIControlState.Normal)
            button.tag = buttonIndex
        }
        
        // Configuring the labels
        questionLabel.text = newDevices[tagOfCorrectAnswer].definition
        exampleLabel.text = newDevices[tagOfCorrectAnswer].examples.shuffled().first
    }
}


// MARK: - Button colors

private extension UIColor {
    private class func purpleColor() -> UIColor {
        return UIColor(red: 0.529, green: 0.106, blue: 0.525, alpha: 1.0)
    }
    
    private class func redColor() -> UIColor {
        return UIColor(red: 0.929, green: 0.106, blue: 0.525, alpha: 1.0)
    }
    
    private class func greenColor() -> UIColor {
        return UIColor(red: 0.508, green: 0.785, blue: 0.165, alpha: 1.0)
    }
}

