//
//  QuizResultViewController.swift
//  Rhetorica
//
//  Created by Nick Podratz on 06.11.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit

class QuizResultsViewController: UITableViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var diagramView: UIView!
    @IBOutlet weak var numberOfFalseAnswersLabel: UILabel!
    
    @IBOutlet weak var languageCell: UITableViewCell!
    @IBOutlet weak var extendCell: UITableViewCell!
    @IBOutlet weak var scoreCell: UITableViewCell!
    @IBOutlet weak var wrongAnswersCell: UITableViewCell!
    
    var lineChart: LineChart!
    var questionSet: QuestionSet!
    var scores: [Int]!

    // MARK: - Properties

    weak var favorites: DeviceList!
    
    var numberOfCorrectAnswers = 0
    var numberOfQuestions = 0
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        numberOfFalseAnswersLabel.text = ""
        
        let identifier = "\(questionSet.extend)_scores"
        
        let defaults = NSUserDefaults.standardUserDefaults()
        scores = (defaults.valueForKey(identifier) as? [Int]) ?? [Int]()
        scores.append(questionSet.correctAnsweredQuestions.count)
        let shortenedScores = Array(scores.suffix(15))
        defaults.setValue(shortenedScores, forKey: identifier)
        defaults.synchronize()
        
        setupDiagram()
    }
    
    override func viewWillAppear(animated: Bool) {
        languageCell.detailTextLabel?.text = questionSet.language.localizedDescription
        extendCell.detailTextLabel?.text = questionSet.extend
        scoreCell.detailTextLabel?.text = "\(questionSet.correctAnsweredQuestions.count) / \(questionSet.numberOfQuestions)"
        numberOfFalseAnswersLabel.text = String(questionSet.wrongAnsweredQuestions.count)
        if questionSet.wrongAnsweredQuestions.isEmpty {
            wrongAnswersCell.accessoryType = .None
            wrongAnswersCell.userInteractionEnabled = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        lineChart.setNeedsDisplay()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "toWrongAnswers":
            let destinationController = segue.destinationViewController as! QuizWrongAnswersViewController
            destinationController.wrongAnsweredQuestions = questionSet.wrongAnsweredQuestions
            destinationController.favorites = favorites
        default: ()
        }
    }
    
    @IBAction func shareButtonPressed(sender: UIBarButtonItem) {
        let textToShare = "Ich habe gerade \(questionSet.correctAnsweredQuestions.count) von \(questionSet.numberOfQuestions) Fragen im Stilmittel-Quiz richtig beantwortet.\n"
        
        if let myWebsite = NSURL(string: "https://itunes.apple.com/de/app/id926449450?mt=8") {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.barButtonItem = sender
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    private func setupDiagram() {
        lineChart = LineChart()
        
        lineChart.colors = [UIColor.rhetoricaGreenColor(), UIColor.rhetoricaPurpleColor(), UIColor.rhetoricaRedColor()]
        lineChart.animation.enabled = false
        lineChart.animation.duration = 2
        
        lineChart.userInteractionEnabled = false
        lineChart.area = true
        
        lineChart.x.grid.visible = true
        lineChart.x.grid.count = 5
        lineChart.x.grid.color = UIColor.lightGrayColor()
        lineChart.x.axis.color = UIColor.lightGrayColor()
        lineChart.x.labels.visible = false
        
        lineChart.y.grid.visible = false
        lineChart.y.axis.color = UIColor.lightGrayColor()
        lineChart.y.labels.values = [0, 2, 4, 6, 8, 10].map{String($0)}
        
        lineChart.addLine(scores.map{CGFloat($0)})

        diagramView.addSubview(lineChart)
        lineChart.frame = diagramView.bounds
        
        lineChart.autoresizingMask = [ .FlexibleHeight, .FlexibleWidth ]

        if #available(iOS 9.0, *) {
//            let leadingConstraint = lineChart.leadingAnchor.constraintEqualToAnchor(diagramView.leadingAnchor)
//            let trailingConstraint = lineChart.trailingAnchor.constraintEqualToAnchor(diagramView.trailingAnchor)
//            let topSpacingConstraint = lineChart.topAnchor.constraintEqualToAnchor(diagramView.topAnchor)
//            let bottomSpacingConstraint = lineChart.bottomAnchor.constraintEqualToAnchor(diagramView.bottomAnchor)
            //            NSLayoutConstraint.activateConstraints([leadingConstraint, trailingConstraint, topSpacingConstraint, bottomSpacingConstraint])

//            let horizontalConstraint = lineChart.centerXAnchor.constraintEqualToAnchor(diagramView.centerXAnchor)
//            let vertivalConstraint = lineChart.centerYAnchor.constraintEqualToAnchor(diagramView.centerYAnchor)
//            let widthConstraint = lineChart.widthAnchor.constraintEqualToAnchor(nil, constant: self.view.frame.size.width)
//            let heightConstraint = lineChart.heightAnchor.constraintEqualToAnchor(nil, constant: 170)
//            NSLayoutConstraint.activateConstraints([horizontalConstraint, vertivalConstraint, widthConstraint, heightConstraint])
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}