//
//  DetailViewController.swift
//  Cicero
//
//  Created by Nick Podratz on 15.09.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wikipediaCell: UITableViewCell!

    let diameter: CGFloat = 140

    var newFavouritesLabel: UILabel = UILabel()
    var newFavouritesView: UIView = UIView()
    
    var device: StylisticDevice? {
        didSet {
            self.configureView()
            titleLabel!.text = self.device?.title
            definitionLabel!.text = self.device?.definition
            exampleLabel!.text = self.device?.example
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        if self.device?.wikipedia == nil {
            wikipediaCell.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        configureNewFavoritesView()
    }
    
    func configureView() {
        // Check if device is selected
        if self.device == nil {
            self.device = DataManager.sharedInstance.selectedList.elements.first
        }
        // Set correct Favorite-Image
        if contains(DataManager.favourites.elements, self.device!) {
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "heart_1")
        }
        tableView.reloadData()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func configureNewFavoritesView() {

        // Configure newFavorites-View
        self.newFavouritesView.backgroundColor = UIColor.blackColor()
        self.newFavouritesView.layer.cornerRadius = 8 // circleDiameter/2
        self.newFavouritesView.alpha = 0.7
        self.newFavouritesView.clipsToBounds = true

        // Configure Label inside newFavorites-View
        self.newFavouritesLabel = UILabel(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        self.newFavouritesLabel.numberOfLines = 0
        self.newFavouritesLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.newFavouritesLabel.textAlignment = NSTextAlignment.Center
        self.newFavouritesLabel.textColor = UIColor.whiteColor()
        self.newFavouritesLabel.alpha = 1.0
        
        self.newFavouritesView.addSubview(newFavouritesLabel)
    }

    @IBAction func addToFavorites(sender: AnyObject) {
        // If it is a favourite
        if let indexOfDeviceInFavorites = find(DataManager.favourites.elements, self.device!){
            DataManager.favourites.elements.removeAtIndex(indexOfDeviceInFavorites)
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "heart_0")
            newFavouritesLabel.text = "von Favoriten\nentfernt"
        }else {
            DataManager.favourites.elements.append(self.device!)
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "heart_1")
            self.newFavouritesLabel.text = "zu Favoriten\nhinzugefügt"
        }
        
        // Semi-Transparent Subview
        self.newFavouritesView.frame = CGRectMake(
            (self.view.bounds.size.width - diameter) / 2,
            (self.view.bounds.size.height - diameter + 40) / 3,
            diameter,
            diameter
        )
        self.newFavouritesView.removeFromSuperview()
        self.newFavouritesView.alpha = 0.7
        self.view.superview!.addSubview(self.newFavouritesView)
        UIView.animateWithDuration(0.4, delay: 0.55, options: .CurveEaseOut, animations: {
            self.newFavouritesView.alpha = 0.0
        }, completion: nil)

        let masterViewController: AnyObject? = splitViewController?.viewControllers.first
        let tableController = masterViewController?.visibleViewController as! UITableViewController
        let tableView = tableController.tableView
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toWikipedia" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! WikipediaViewController
            controller.urlString = self.device!.wikipedia
            controller.navigationItem.title = self.device?.title
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true

        }
    }

}

