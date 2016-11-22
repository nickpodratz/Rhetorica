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
        
        noDeviceView = UINib(nibName: "NoDeviceView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? UIView
        if noDeviceView != nil {
            noDeviceView!.layer.zPosition = 1
            noDeviceView!.autoresizesSubviews = true
            noDeviceView!.isHidden = (self.device != nil)
            self.tableView.isUserInteractionEnabled = (self.device != nil)
            self.tableView.addSubview(noDeviceView!)
            layoutNoDeviceView()
        }
        if let device = self.device {
            FacebookLogger.detailsForDeviceDidOpen(device)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        wikipediaCell.setSelected(false, animated: true)
        configureView()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        noDeviceView!.isHidden = (self.device != nil)
    }
    
    func layoutNoDeviceView() {
        guard let noDeviceView = noDeviceView else { return }
        let navigationOffset = self.navigationController?.navigationBar.bounds.height ?? 0
        print("navigationOffset: \(navigationOffset)")
        noDeviceView.bounds = CGRect(x: 0, y: -navigationOffset, width: self.tableView.bounds.width, height: self.tableView.bounds.height - navigationOffset)
        noDeviceView.isHidden = device != nil
    }

    
    // MARK: Setup
    
    @available(iOS 9.0, *)
    override var previewActionItems : [UIPreviewActionItem] {
        guard let device = self.device else { print("no device"); return [] }
        guard favorites != nil else { print("no favorites"); return [] }
        
        let action: UIPreviewAction
        if favorites.contains(device) {
            action = UIPreviewAction(title: NSLocalizedString("remove_from_favorites", comment: ""), style: .destructive) { [weak self] (action, viewController) in
                self?.addToFavorites()
            }
        } else {
            action = UIPreviewAction(title: "Zu Lernliste hinzufügen", style: .default) { [weak self] (action, viewController) -> Void in
                self?.addToFavorites()
            }
        }
        
        return [action]
    }
    
    // MARK: - User Interaction
    
    @IBAction func addToFavorites() {
        guard let favorites = favorites, let device = device else { return }
        if let indexOfDeviceInFavorites = favorites.elements.index(of: device){
            // Deleting...
            favorites.elements.remove(at: indexOfDeviceInFavorites)
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
            let masterController = navigationController.childViewControllers.first as? MasterViewController {
                masterController.tableView.reloadData()
        }
    }
    
    
    // MARK: - Transitioning

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWikipedia" {
            let controller = segue.destination as! WikipediaViewController
            controller.urlString = self.device?.wikipedia
            controller.navigationItem.title = self.device?.title
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            if let device = self.device {
                FacebookLogger.wikipediaForDeviceDidOpen(device)
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        synonymCell.isHidden = (device?.synonym == nil)
        wikipediaCell.isHidden = (device?.wikipedia == nil)
        oppositeCell.isHidden = (device?.opposite == nil)

        switch (indexPath as NSIndexPath).row {
        case synonymCell.tag where device?.synonym == nil: return 0
        case wikipediaCell.tag where device?.wikipedia == nil: return 0
        case oppositeCell.tag where device?.opposite == nil: return 0
        default: return UITableViewAutomaticDimension
        }
    }
    
    // MARK: - Helper Functions
    
    func configureView() {
        self.navigationItem.rightBarButtonItem?.isEnabled = (device != nil)
        noDeviceView?.isHidden = (self.device != nil)
        self.tableView.isUserInteractionEnabled = (self.device != nil)
        noDeviceView!.frame = self.view.bounds

        // Fill tableview with data
        titleLabel?.text = self.device?.title
        definitionLabel?.text = self.device?.definition
        exampleLabel?.text = self.device?.examples.joined(separator: "\n")
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
    

    fileprivate func showFavoritesLabel(addedStylisticDevice added: Bool) {
        if added {
            hudView = CustomHUDBaseView(image: nil, subtitle: NSLocalizedString("hinzugefügt", comment: ""))
                        
            PKHUD.sharedHUD.contentView = hudView!
            PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
            PKHUD.sharedHUD.dimsBackground = false
            PKHUD.sharedHUD.show()
            PKHUD.sharedHUD.hide(afterDelay: 1)
            
            hudView!.animateAdded()
        } else {
            hudView = CustomHUDBaseView(image: nil, subtitle: NSLocalizedString("entfernt", comment: ""))
            
            PKHUD.sharedHUD.contentView = hudView!
            PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
            PKHUD.sharedHUD.dimsBackground = false
            PKHUD.sharedHUD.show()
            PKHUD.sharedHUD.hide(afterDelay: 1)
            
            hudView!.animateRemoved()
        }
    }
        
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return tableView.cellForRow(at: indexPath) == wikipediaCell
    }

    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
        
    }

    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any!) {
        if action == #selector(copy(_:)) {
            UIPasteboard.general.string = device?.wikipedia
        }
    }

}

