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
        self.questionSet = QuestionSet(fromDeviceList: deviceList, language: language, numberOfQuestions: 10)
    }
    
    override func viewWillAppear(animated: Bool) {
        setupForNewQuestion()
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
            destinationController.questionSet = self.questionSet
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
            let alertController = UIAlertController(title: "Quiz beenden?", message: "Wenn du nun das Quiz abbrichst, geht dein bisheriger Spielstand verloren.", preferredStyle: .Alert)
            
            let proceedAction = UIAlertAction(title: "Beenden", style: UIAlertActionStyle.Destructive) { action in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            alertController.addAction(proceedAction)
            
            let cancelAction = UIAlertAction(title: "Fortfahren", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
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
        self.navigationItem.title = "\(questionLocalized) \(questionSet.numberOfCurrentQuestion) \(ofLocalized) \(questionSet.numberOfQuestions)"
        
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