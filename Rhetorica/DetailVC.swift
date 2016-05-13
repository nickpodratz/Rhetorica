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
    var noDeviceView: UIView?
    
    // MARK: - Properties
    
    var favoritesLabel: UILabel!
    var hudView: CustomHUDBaseView?
    weak var favorites: DeviceList! {
        didSet {
            self.configureView()
        }
    }
    
    var device: StylisticDevice? {
        didSet {
            self.configureView()
        }
    }
    var delegate: DetailViewControllerDelegate?

    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        // Update size of cells
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        noDeviceView = UINib(nibName: "NoDeviceView", bundle: nil).instantiateWithOwner(nil, options: nil).first as? UIView
        if noDeviceView != nil {
            noDeviceView!.layer.zPosition = 1
            noDeviceView!.autoresizesSubviews = false
            noDeviceView!.hidden = (self.device != nil)
            self.tableView.userInteractionEnabled = (self.device != nil)
            self.tableView.addSubview(noDeviceView!)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        wikipediaCell.setSelected(false, animated: true)
        configureView()

    }
    
    override func viewDidAppear(animated: Bool) {
        noDeviceView!.hidden = (self.device != nil)
    }
    
    func layoutNoDeviceView() {
        guard let noDeviceView = noDeviceView else { return }
        noDeviceView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
        noDeviceView.hidden = device != nil
    }

    
    // MARK: Setup
    
    @available(iOS 9.0, *)
    override func previewActionItems() -> [UIPreviewActionItem] {
        guard let device = self.device else { print("no device"); return [] }
        guard favorites != nil else { print("no favorites"); return [] }
        
        let action: UIPreviewAction
        if favorites.contains(device) {
            action = UIPreviewAction(title: NSLocalizedString("remove_from_favorites", comment: ""), style: .Destructive) { (action, viewController) in
                self.addToFavorites(self)
            }
        } else {
            action = UIPreviewAction(title: "Zu Lernliste hinzufügen", style: .Default) { (action, viewController) -> Void in
                self.addToFavorites(self)
            }
        }
        
        return [action]
    }
    
    // MARK: - User Interaction
    
    @IBAction func addToFavorites(sender: AnyObject) {
        guard let favorites = favorites, let device = device else { return }
        if let indexOfDeviceInFavorites = favorites.elements.indexOf(device){
            // Deleting...
            favorites.elements.removeAtIndex(indexOfDeviceInFavorites)
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "pin")
            showFavoritesLabel(addedStylisticDevice: false)
            delegate?.detailViewControllerDelegate(deviceNowIsFavorite: false)
        }else {
            // Adding...
            favorites.elements.append(self.device!)
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "pin_filled")
            showFavoritesLabel(addedStylisticDevice: true)
            delegate?.detailViewControllerDelegate(deviceNowIsFavorite: true)
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
        default: return UITableViewAutomaticDimension
        }
    }
    
    // MARK: - Helper Functions
    
    func configureView() {
        self.navigationItem.rightBarButtonItem?.enabled = (device != nil)
        noDeviceView?.hidden = (self.device != nil)
        self.tableView.userInteractionEnabled = (self.device != nil)
        noDeviceView!.frame = self.view.bounds

        // Fill tableview with data
        titleLabel?.text = self.device?.title
        definitionLabel?.text = self.device?.definition
        exampleLabel?.text = self.device?.examples.joinWithSeparator("\n")
        oppositeLabel?.text = self.device?.opposite
        synonymLabel?.text = self.device?.synonym
        
        tableView.reloadData()
        
        // Set correct Favorite-Image
        let deviceIsFavorite: Bool
        if let favorites = favorites {
            if device != nil {
                deviceIsFavorite = favorites.elements.contains(device!)
            } else {
                deviceIsFavorite = false
            }
        } else {
            deviceIsFavorite = false
        }
        navigationItem.rightBarButtonItem?.image = deviceIsFavorite ? UIImage(named: "pin_filled") : UIImage(named: "pin")
    }
    

    private func showFavoritesLabel(addedStylisticDevice added: Bool) {
        if added {
            hudView = CustomHUDBaseView(subtitle: NSLocalizedString("hinzugefügt", comment: ""), image: nil)
                        
            PKHUD.sharedHUD.contentView = hudView!
            PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
            PKHUD.sharedHUD.dimsBackground = false
            PKHUD.sharedHUD.show()
            PKHUD.sharedHUD.hide(afterDelay: 1)
            
            hudView!.animateAdded()
        } else {
            hudView = CustomHUDBaseView(subtitle: NSLocalizedString("entfernt", comment: ""), image: nil)
            
            PKHUD.sharedHUD.contentView = hudView!
            PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
            PKHUD.sharedHUD.dimsBackground = false
            PKHUD.sharedHUD.show()
            PKHUD.sharedHUD.hide(afterDelay: 1)
            
            hudView!.animateRemoved()
        }
    }
        
    
    // MARK: - Table View Delegate
    
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableView.cellForRowAtIndexPath(indexPath) == wikipediaCell
    }

    override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return action == #selector(NSObject.copy(_:))
        
    }

    override func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
        if action == #selector(NSObject.copy(_:)) {
            UIPasteboard.generalPasteboard().string = device?.wikipedia
        }
    }

}

