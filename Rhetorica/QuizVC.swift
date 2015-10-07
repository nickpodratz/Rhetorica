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

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet var buttons: [UIButton]! {
        didSet{
            self.defaultButtonColor = buttons.first!.backgroundColor
        }
    }
    @IBOutlet weak var toTopConstraint: NSLayoutConstraint!
    
    
    // MARK: - Properties

    var defaultButtonColor: UIColor!
    weak var deviceList: DeviceList!
    var tagOfCorrectAnswer: Int!
    
    // Answer-logging
    var counterOfCorrectAnswers = 0
    var counterOfQuestions = 0
    
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        setupViewForNewRound()
    }
    
    override func viewDidLayoutSubviews() {
        centerContent()
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
            sender.backgroundColor = UIColor(red:0.53, green:0.21, blue:0.39, alpha:0.9)
        }, completion: nil)
    }
    
    /// Called when Button is cancelled
    @IBAction func fadeOut(sender: UIButton) {
        UIView.animateWithDuration(0.7, delay: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            sender.backgroundColor = self.defaultButtonColor
            },completion: { _ in
                sleep(1)
                UIView.animateWithDuration(0.7, delay: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    sender.backgroundColor = self.defaultButtonColor
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
                    sender.backgroundColor = UIColor.customGreenColor()
                },
                completion: { _ in
                    UIView.animateWithDuration(0.8, delay: 0.9, options: UIViewAnimationOptions.CurveEaseOut,
                        animations: {
                            sender.backgroundColor = self.defaultButtonColor
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
                    sender.backgroundColor = UIColor.customRedColor()
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                },
                completion: { _ in
                    UIView.animateWithDuration(0.55, delay: 0.8, options: UIViewAnimationOptions.CurveEaseOut,
                        animations: {
                            sender.backgroundColor = self.defaultButtonColor
                            correctButton.backgroundColor = UIColor.customGreenColor()
                        },
                        completion: { _ in
                            UIView.animateWithDuration(0.8, delay: 1.52, options: UIViewAnimationOptions.CurveEaseOut,
                                animations: {
                                    correctButton.backgroundColor = self.defaultButtonColor
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
            button.backgroundColor = defaultButtonColor
        }
        for (buttonIndex, button) in buttons.enumerate() {
            button.setTitle(newDevices[buttonIndex].title, forState: UIControlState.Normal)
            button.tag = buttonIndex
        }
        
        // Configuring the labels
        questionLabel.text = newDevices[tagOfCorrectAnswer].definition
        exampleLabel.text = newDevices[tagOfCorrectAnswer].examples.shuffled().first
        self.view.layoutIfNeeded()
    }
    
    private func centerContent() {
        let heightOfContents = exampleLabel.frame.origin.y + exampleLabel.frame.size.height - definitionLabel.frame.origin.y
        if ((scrollView.frame.height - heightOfContents) / 2) > 30 {
            self.toTopConstraint.constant = (scrollView.frame.height - heightOfContents)/2
        } else {
            self.toTopConstraint.constant = 20
        }
    }
}


// MARK: - Button colors

public extension UIColor {
    class func customRedColor() -> UIColor {
        return UIColor(red:0.79, green:0.25, blue:0.25, alpha:1)
    }
    
    class func customGreenColor() -> UIColor {
        return UIColor(red:0.67, green:0.72, blue:0.14, alpha:1)
    }

    class func customPurpleColor() -> UIColor {
        return UIColor(red:0.53, green:0.21, blue:0.39, alpha:1)
    }
}

