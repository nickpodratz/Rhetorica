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
    @IBOutlet weak var extentCell: UITableViewCell!
    @IBOutlet weak var scoreCell: UITableViewCell!
    @IBOutlet weak var wrongAnswersCell: UITableViewCell!
    
    var lineChart: LineChart!
    var questionSet: QuestionSet!
    var scores: [Int]!

    // MARK: - Properties

    weak var favorites: DeviceList!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        numberOfFalseAnswersLabel.text = ""
        
        if isUITestMode {
            self.scores = [2, 4, 4, 6, 3, 5, 7, 8, 6, 8]
        } else {
            let identifier = "\(questionSet.extent)_scores"
            
            let defaults = NSUserDefaults.standardUserDefaults()
            scores = (defaults.valueForKey(identifier) as? [Int]) ?? [Int]()
            scores.append(questionSet.correctAnsweredQuestions.count)
            let shortenedScores = Array(scores.suffix(15))
            defaults.setValue(shortenedScores, forKey: identifier)
            defaults.synchronize()
        }
        setupLineChart()

    }
    
    override func viewWillAppear(animated: Bool) {
        languageCell.detailTextLabel?.text = questionSet.language.localizedDescription
        extentCell.detailTextLabel?.text = questionSet.extent
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
    
    private func setupLineChart() {
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
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}