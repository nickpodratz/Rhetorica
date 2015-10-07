//
//  DetailViewController.swift
//  Cicero
//
//  Created by Nick Podratz on 15.09.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit
import PKHUD


class DetailViewController: UITableViewController {
    
    // TODO: Memory leak in init
    
    // MARK: - Outlets
    
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synonymLabel: UILabel!
    @IBOutlet weak var oppositeLabel: UILabel!
    
    @IBOutlet weak var synonymCell: UITableViewCell!
    @IBOutlet weak var wikipediaCell: UITableViewCell!
    @IBOutlet weak var oppositeCell: UITableViewCell!
    
    
    // MARK: - Properties
    
    var favoritesLabel: UILabel!
    var hudView: PKHUDSubtitleView?
    
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
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "pin")
            showFavoritesLabel(addedStylisticDevice: false)
        }else {
            // Adding...
            DataManager.favorites.elements.append(self.device!)
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "pin_filled")
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

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        synonymCell.hidden = (device?.synonym == nil)
        wikipediaCell.hidden = (device?.wikipedia == nil)
        oppositeCell.hidden = (device?.opposite == nil)

        switch indexPath.row {
        case synonymCell.tag where device?.synonym == nil: return 0
        case wikipediaCell.tag where device?.wikipedia == nil: return 0
        case oppositeCell.tag where device?.opposite == nil: return 0
        default: return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
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
        exampleLabel?.text = device.examples.joinWithSeparator("\n")
        oppositeLabel?.text = device.opposite
        synonymLabel?.text = device.synonym
        
        tableView.reloadData()
        // Set correct Favorite-Image
        let deviceIsFavorite = DataManager.favorites.elements.contains(self.device!)
        navigationItem.rightBarButtonItem?.image = deviceIsFavorite ? UIImage(named: "pin_filled") : UIImage(named: "pin")
    }
    

    private func showFavoritesLabel(addedStylisticDevice added: Bool) {
        if added {
            let pinLayer = PinLayer()
            hudView = PKHUDSubtitleView(subtitle: "Hinzugefügt", image: nil)
            hudView!.layer.addSublayer(pinLayer)
            PKHUD.sharedHUD.contentView = hudView!
            PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
            PKHUD.sharedHUD.dimsBackground = false
            PKHUD.sharedHUD.show()
            PKHUD.sharedHUD.hide(afterDelay: 1)
            pinLayer.frame = CGRect(
                x: hudView!.bounds.width/3,
                y: hudView!.bounds.height/4,
                width: hudView!.bounds.width/3,
                height: hudView!.bounds.height/3
            )
            pinLayer.animateHoverIn()
        } else {
            let pinLayer = PinLayer()
            let crossLayer = PinCrossLayer()
            hudView = PKHUDSubtitleView(subtitle: "Entfernt", image: nil)
            hudView!.layer.addSublayer(pinLayer)
            hudView!.layer.addSublayer(crossLayer)
//            view.layer.mask = crossLayer
            PKHUD.sharedHUD.contentView = hudView!
            PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
            PKHUD.sharedHUD.dimsBackground = false
            PKHUD.sharedHUD.show()
            PKHUD.sharedHUD.hide(afterDelay: 1)
            pinLayer.frame = CGRect(
                x: hudView!.bounds.width/3,
                y: hudView!.bounds.height/4,
                width: hudView!.bounds.width/3,
                height: hudView!.bounds.height/3
            )
            crossLayer.frame = CGRect(
                x: hudView!.bounds.width/3,
                y: hudView!.bounds.height/4,
                width: hudView!.bounds.width/3,
                height: hudView!.bounds.height/3
            )
            crossLayer.animateCrossOut()
        }
    }
        
    
    // MARK: - Table View Delegate
    
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableView.cellForRowAtIndexPath(indexPath) == wikipediaCell
    }

    override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return action == Selector("copy:")
        
    }

    override func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
        if action == Selector("copy:") {
            UIPasteboard.generalPasteboard().string = device?.wikipedia
        }
    }

}

