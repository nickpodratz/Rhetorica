//
//  DetailViewController.swift
//  Cicero
//
//  Created by Nick Podratz on 15.09.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    
    // TODO: Memory leak in init
    
    // MARK: - Outlets
    
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wikipediaCell: UITableViewCell!
    
    
    // MARK: - Properties
    
    var favoritesLabel: UILabel!
    
    weak var device: StylisticDevice? {
        didSet {
            self.configureView()
        }
    }
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        // Update size of cells
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        tableView.layoutIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        wikipediaCell.setSelected(false, animated: true)
        configureView()
    }
    
    
    // MARK: - User Interaction
    
    @IBAction func addToFavorites(sender: AnyObject) {
        if let indexOfDeviceInFavorites = DataManager.favorites.elements.indexOf(self.device!){
            // Deleting...
            DataManager.favorites.elements.removeAtIndex(indexOfDeviceInFavorites)
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "heart_0")
            showFavoritesLabel(addedStylisticDevice: false)
        }else {
            // Adding...
            DataManager.favorites.elements.append(self.device!)
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "heart_1")
            showFavoritesLabel(addedStylisticDevice: true)
        }
        
        if let navigationController = self.splitViewController?.viewControllers.first as? UINavigationController,
            masterController = navigationController.childViewControllers.first as? MasterViewController {
                masterController.tableView.reloadData()
        }
    }
    
    
    // MARK: - Transitioning

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toWikipedia" {
            let controller = segue.destinationViewController as! WikipediaViewController
            controller.urlString = self.device?.wikipedia
            controller.navigationItem.title = self.device?.title
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true

        }
    }

    
    // MARK: - Helper Functions
    
    func configureView() {
        guard let device = self.device else {
            self.device = DataManager.sharedInstance.selectedList.elements.first
            configureView()
            return
        }
        
        // Fill tableview with data
        titleLabel?.text = device.title
        definitionLabel?.text = device.definition
        exampleLabel?.text = device.example
        wikipediaCell?.hidden = (device.wikipedia == nil)
        
        tableView.reloadData()
        // Set correct Favorite-Image
        let deviceIsFavorite = DataManager.favorites.elements.contains(self.device!)
        navigationItem.rightBarButtonItem?.image = deviceIsFavorite ? UIImage(named: "heart_1") : UIImage(named: "heart_0")
    }

    private func showFavoritesLabel(addedStylisticDevice added: Bool) {
        let isPresenting = (favoritesLabel != nil)
        let diameter: CGFloat = 140
        let text = added ? "zu Favoriten\nhinzugefügt" : "von Favoriten\nentfernt"
        
        if isPresenting {
            favoritesLabel.removeFromSuperview()
        }
        
        favoritesLabel = UILabel()
        favoritesLabel.text = text
        favoritesLabel.layer.backgroundColor = UIColor(white: 0, alpha: 0.7).CGColor
        favoritesLabel.numberOfLines = 0
        favoritesLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        favoritesLabel.textAlignment = NSTextAlignment.Center
        favoritesLabel.textColor = UIColor.whiteColor()
        favoritesLabel.layer.cornerRadius = 8
        favoritesLabel.frame = CGRect(
            x: (self.view.bounds.size.width - diameter) / 2,
            y: (self.view.bounds.size.height - diameter + 40) / 3,
            width: diameter,
            height: diameter
        )
        
        self.view.superview!.addSubview(favoritesLabel)
        
        UIView.animateWithDuration(0.4, delay: 0.55, options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.favoritesLabel.alpha = 0.0
            },
            completion: { finished in
                if finished {
                    self.favoritesLabel.removeFromSuperview()
                    self.favoritesLabel = nil
                }
            }
        )
    }
        
    /* Copying Dialogue
    
    // MARK: - Table View Delegate
    
    override func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
        if action == Selector("copy:") {
            println("copy")
        }
    }
    
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject) -> Bool {
        return action == Selector("copy:")
    }

    */
}

