//
//  QuizViewController.swift
//  Rhetorica
//
//  Created by Nick Podratz on 05.11.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit
import AudioToolbox
import FBSDKCoreKit
import Bolts


class QuizViewController: UIViewController, UIActionSheetDelegate {

    
    // MARK: - Outlets

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet var buttons: [QuizButton]!
    
    @IBOutlet weak var toTopConstraint: NSLayoutConstraint!
    
    
    // MARK: - Properties
    
    var language: Language!
    weak var deviceList: DeviceList!
    weak var favorites: DeviceList!
    var questionSet: QuestionSet!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isUITestMode {
            // Setup a questionset with only one question
            let devicesForQuestion: [StylisticDevice] = {
                var newDevices = [StylisticDevice]()
                for deviceCount in 1...4 {
                    let newDevice = deviceList.elements[deviceCount * 15]
                    newDevices.append(newDevice)
                }
                return newDevices
            }()
            let question = Question(devices: devicesForQuestion, tagOfCorrectAnswer: 1)
            self.questionSet = QuestionSet(withQuestions: [question], language: language, extent: deviceList.title)
            
        } else {
            self.questionSet = QuestionSet(fromDeviceList: deviceList, language: language, numberOfQuestions: 10)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        setupForNewQuestion()
        FacebookLogger.quizModeDidStart(forDeviceList: deviceList, inLanguage: language)
    }
    
    override func viewDidLayoutSubviews() {
        centerContent()
    }
    
    @IBAction func quizButtonTouchedDown(sender: QuizButton) {
        sender.animateTouched()

        for button in buttons {
            button.userInteractionEnabled = false
        }
        sender.userInteractionEnabled = true
    }
    
    @IBAction func quizButtonTouchedUp(sender: QuizButton) {
        for button in buttons {
            button.userInteractionEnabled = true
        }
    }
    
    // MARK: - Transitioning

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "toQuizResults" {
            let destinationController = segue.destinationViewController as! QuizResultsViewController
            if isUITestMode {
                let questionSet = QuestionSet(fromDeviceList: deviceList, language: language, numberOfQuestions: 10)
                for (index, question) in questionSet.questions.enumerate() {
                    if index == 3||index == 6 {
                        question.answerWasCorrect = false
                    } else {
                        question.answerWasCorrect = true
                    }
                }
                destinationController.questionSet = questionSet
            } else {
                destinationController.questionSet = self.questionSet
                FacebookLogger.quizModeDidFinish(forDeviceList: deviceList, inLanguage: language, withScore: questionSet.correctAnsweredQuestions.count)
            }
            destinationController.favorites = favorites
        }
    }
    
    @IBAction func rewindsToQuizViewController(segue:UIStoryboardSegue) {
        self.questionSet = QuestionSet(fromDeviceList: deviceList, language: questionSet.language, numberOfQuestions: 10)
    }

    
    // MARK: - User Interaction

    /// Called when Button is pushed down
    @IBAction func fadeIn(sender: QuizButton) {
    }
    
    /// Called when Button is cancelled
    @IBAction func fadeOut(sender: QuizButton) {
        sender.animateUntouched()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        if questionSet.numberOfCurrentQuestion != 1 {
            let quitQuizTitle = NSLocalizedString("quitQuizTitle", comment: "The title of the alert appearing when you are about to quit the quiz.")
            let quitQuizMessage = NSLocalizedString("quitQuizMessage", comment: "The message of the alert appearing when you are about to quit the quiz.")
            let quitQuizButtonQuit = NSLocalizedString("quitQuizButtonQuit", comment: "The quit-button's title of the alert appearing when you are about to quit the quiz.")
            let quitQuizButtonCancel = NSLocalizedString("quitQuizButtonCancel", comment: "The cancel-button's title of the alert appearing when you are about to quit the quiz.")
            
            let alertController = UIAlertController(title: quitQuizTitle, message: quitQuizMessage, preferredStyle: .Alert)
            
            let proceedAction = UIAlertAction(title: quitQuizButtonQuit, style: UIAlertActionStyle.Destructive) { action in
                FacebookLogger.quizModeDidCancel(forDeviceList: self.deviceList, inLanguage: self.language, withScore: self.questionSet.correctAnsweredQuestions.count, atQuestion: self.questionSet.numberOfCurrentQuestion)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            alertController.addAction(proceedAction)
            
            let cancelAction = UIAlertAction(title: quitQuizButtonCancel, style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            FacebookLogger.quizModeDidCancel(forDeviceList: self.deviceList, inLanguage: self.language, withScore: self.questionSet.correctAnsweredQuestions.count, atQuestion: self.questionSet.numberOfCurrentQuestion)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    @IBAction func buttonKlicked(sender: QuizButton) {
        let answerWasCorrect = (sender.tag == questionSet.currentQuestion!.tagOfCorrectAnswer)
        let correctButton = buttons[questionSet.currentQuestion!.tagOfCorrectAnswer]

        questionSet.currentQuestion?.answerWasCorrect = answerWasCorrect

        for button in buttons {
            button.userInteractionEnabled = false
        }
        
        if answerWasCorrect {
            sender.animateIsCorrect() {
                sender.animateToNormal() {
                    self.setupForNewQuestion()
                    
                }
            }
        } else {
            sender.animateIsFalse() {
                sender.animateToNormal() {
                    correctButton.animateIsCorrect() {
                        correctButton.animateToNormal() {
                            self.setupForNewQuestion()
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - Private Functions
        
    private func setupForNewQuestion() {
        
        // Get current question and check if quiz ended.
        guard let question = questionSet.nextQuestion() else {
            print("Quiz did end")
            performSegueWithIdentifier("toQuizResults", sender: self)
            return
        }

        // Fade out
        if questionSet.numberOfCurrentQuestion > 1 {
            UIView.animateWithDuration(0.4, delay: 0.03, options: .CurveEaseOut,
                animations: {
                    self.scrollView.alpha = 0
                }, completion: nil
            )
        }

        // Configuring title of Navigation Bar
        let questionLocalized = NSLocalizedString("frage", comment: "")
        let ofLocalized = NSLocalizedString("von", comment: "")
        
        if isUITestMode {
            self.navigationItem.title = "\(questionLocalized) 7 \(ofLocalized) 10"
        } else {
            self.navigationItem.title = "\(questionLocalized) \(questionSet.numberOfCurrentQuestion) \(ofLocalized) \(questionSet.numberOfQuestions)"
        }
        
        // Configuring Buttons
        print(buttons)
        for (buttonIndex, button) in buttons.enumerate() {            
            button.setTitle(question.devices[buttonIndex].title, forState: UIControlState.Normal)
            button.tag = buttonIndex
        }
        
        // Configuring question-labels
        questionLabel.text = question.correctAnswer.definition
        exampleLabel.text = question.correctAnswer.examples.shuffled().first
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(0.24, delay: 0.43, options: .CurveEaseIn,
            animations: {
                self.scrollView.alpha = 1
            },
            completion: { _ in
                for button in self.buttons {
                    button.userInteractionEnabled = true
                }
            }
        )
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