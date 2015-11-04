//
//  QuizWrongAnswersViewController.swift
//  Rhetorica
//
//  Created by Nick Podratz on 30.10.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate {
    func detailViewControllerDelegate(deviceNowIsFavorite isFavorite: Bool)
}

class QuizWrongAnswersViewController: UITableViewController, PinnableDeviceCellDelegate, DetailViewControllerDelegate {
    
    var wrongAnsweredQuestions: [Question]!
    weak var favorites: DeviceList!
    var selectedCell: PinnableDeviceCell?
    
    @IBAction func addAllDevicesPressed(sender: AnyObject) {
        for (index, question) in wrongAnsweredQuestions.enumerate() {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! PinnableDeviceCell
            cell.isFavorite = true
            if !favorites.elements.contains(question.correctAnswer) {
                favorites.elements.append(question.correctAnswer)
            }
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "toDetails":
            let destinationController = segue.destinationViewController as! DetailViewController
            destinationController.delegate = self
            if let indexPaths = tableView.indexPathsForSelectedRows {
                print("to details")
                destinationController.favorites = self.favorites
                let device = wrongAnsweredQuestions[indexPaths.first!.row].correctAnswer
                destinationController.device = device
            }
        default: ()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        setAddAllEnabled()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.selectedCell = nil
        setAddAllEnabled()
    }
        
    private func setAddAllEnabled() {
        self.navigationItem.rightBarButtonItem?.enabled = false

        let devices = wrongAnsweredQuestions.map{$0.correctAnswer}
        for device in devices {
            if !favorites.elements.contains(device) {
                self.navigationItem.rightBarButtonItem?.enabled = true
            }
        }
    }
    
    
    // MARK: Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wrongAnsweredQuestions.count ?? 0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PinnableDeviceCell", forIndexPath: indexPath) as! PinnableDeviceCell
        cell.device = wrongAnsweredQuestions[indexPath.row].correctAnswer
        cell.tag = indexPath.row
        cell.isFavorite = favorites.elements.contains(wrongAnsweredQuestions[indexPath.row].correctAnswer)
        cell.delegate = self
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! PinnableDeviceCell?
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Falsche Antworten"
    }
    
    func detailViewControllerDelegate(deviceNowIsFavorite isFavorite: Bool) {
        setAddAllEnabled()
        
        selectedCell?.isFavorite = isFavorite
    }

    func pinnableDeviceCellDelegate(didPressPinButtonOfCellWithTag tag: Int) -> Bool {
        let device = wrongAnsweredQuestions[tag].correctAnswer
        
        if let index = favorites.indexOf(device) {
            // Removed from favorites
            favorites.elements.removeAtIndex(index)
            setAddAllEnabled()
            return false
        } else {
            // Added to favorites
            favorites.elements.append(device)
            setAddAllEnabled()
            return true
        }
    }
}
