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
            if device != nil {
                self.configureView()
                titleLabel!.text = self.device?.title
                definitionLabel!.text = self.device?.definition
                exampleLabel!.text = self.device?.example
            }
        }
    }
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        if self.device?.wikipedia == nil {
            wikipediaCell.hidden = true
        }
    }
    
    func configureView() {
        // Check if device is selected
        if self.device == nil {
            self.device = DataManager.sharedInstance.selectedList.elements.first
        }
        // Set correct Favorite-Image
        if contains(DataManager.favorites.elements, self.device!) {
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "heart_1")
        }
        tableView.reloadData()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    // MARK: - User Interaction
    
    @IBAction func addToFavorites(sender: AnyObject) {
        // If it is a favourite
        if let indexOfDeviceInFavorites = find(DataManager.favorites.elements, self.device!){
            DataManager.favorites.elements.removeAtIndex(indexOfDeviceInFavorites)
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "heart_0")
            showFavoritesLabel(addedStylisticDevice: false)
        }else {
            DataManager.favorites.elements.append(self.device!)
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "heart_1")
            showFavoritesLabel(addedStylisticDevice: true)
        }
        
        // TODO: Not working. visible... is navigationController
        let masterViewController: AnyObject? = splitViewController?.viewControllers.first
        let tableController = masterViewController?.visibleViewController as! UITableViewController
        let tableView = tableController.tableView
        tableView.reloadData()
    }
    
    
    // MARK: - Transitioning

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toWikipedia" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! WikipediaViewController
            controller.urlString = self.device!.wikipedia
            controller.navigationItem.title = self.device?.title
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true

        }
    }

    // MARK: - Private Functions
    
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
}

