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
    var favorites: DeviceList!
    var selectedCell: PinnableDeviceCell?
    
    @IBAction func addAllDevicesPressed(_ sender: AnyObject) {
        for (index, question) in wrongAnsweredQuestions.enumerated() {
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! PinnableDeviceCell
            cell.isFavorite = true
            if !favorites.elements.contains(question.correctAnswer) {
                favorites.elements.append(question.correctAnswer)
            }
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "toDetails":
            let destinationController = segue.destination as! DetailViewController
            destinationController.delegate = self
            if let indexPaths = tableView.indexPathsForSelectedRows {
                print("to details")
                destinationController.favorites = self.favorites
                let device = wrongAnsweredQuestions[(indexPaths.first! as NSIndexPath).row].correctAnswer
                destinationController.device = device
            }
        default: ()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setAddAllEnabled()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.selectedCell = nil
        setAddAllEnabled()
    }
        
    fileprivate func setAddAllEnabled() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false

        let devices = wrongAnsweredQuestions.map{$0.correctAnswer}
        for device in devices {
            if !favorites.elements.contains(device) {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    
    // MARK: Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wrongAnsweredQuestions.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PinnableDeviceCell", for: indexPath) as! PinnableDeviceCell
        cell.device = wrongAnsweredQuestions[(indexPath as NSIndexPath).row].correctAnswer
        cell.tag = (indexPath as NSIndexPath).row
        cell.isFavorite = favorites.elements.contains(wrongAnsweredQuestions[(indexPath as NSIndexPath).row].correctAnswer)
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedCell = tableView.cellForRow(at: indexPath) as! PinnableDeviceCell?
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("falsche_antworten", comment: "")
    }
    
    func detailViewControllerDelegate(deviceNowIsFavorite isFavorite: Bool) {
        setAddAllEnabled()
        
        selectedCell?.isFavorite = isFavorite
    }

    func pinnableDeviceCellDelegate(didPressPinButtonOfCellWithTag tag: Int) -> Bool {
        let device = wrongAnsweredQuestions[tag].correctAnswer
        
        let index = favorites.index(ofAccessibilityElement: device)
        if index == NSNotFound {
            // Added to favorites
            favorites.elements.append(device)
            setAddAllEnabled()
            return true
        } else {
            // Removed from favorites
            favorites.elements.remove(at: index)
            setAddAllEnabled()
            return false
        }
    }
}
