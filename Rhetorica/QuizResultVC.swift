//
//  QuizResultViewController.swift
//  Rhetorica
//
//  Created by Nick Podratz on 06.11.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit

class QuizResultViewController: UIViewController {
    
    
    // MARK: - Outlets

    @IBOutlet weak var answersRoundSubview: UIView!
    @IBOutlet weak var answersRoundCorrect: UILabel!
    @IBOutlet weak var answersRoundAll: UILabel!
    
    
    // MARK: - Properties

    var numberOfCorrectAnswers = 0
    var numberOfQuestions = 0
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        answersRoundCorrect.text = ""
        answersRoundAll.text = ""
    }
    
    override func viewDidAppear(animated: Bool) {        
        self.answersRoundSubview.bounds = CGRect(x: 0, y: 0, width: 0, height: 36)
        UIView.animateWithDuration(0.4, delay: 0.0, options: [], animations: {
            self.answersRoundSubview.bounds = CGRect(x: 0, y: 0, width: 300, height: 36)
            self.answersRoundSubview.backgroundColor = UIColor.customGreenColor()
            }, completion: { _ in
                if self.numberOfCorrectAnswers > 0 {
                    self.answersRoundCorrect.text = String(self.numberOfCorrectAnswers)
                }
                self.answersRoundAll.text = String(self.numberOfQuestions)
            }
        )
    }
    
    
    // MARK: - User Interaction

    @IBAction func finished(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
        navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}