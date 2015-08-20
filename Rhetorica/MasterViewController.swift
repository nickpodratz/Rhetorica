//
//  MasterViewController.swift
//  Cicero
//
//  Created by Nick Podratz on 15.09.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

// TODO: When favorites appears, it is lagging

import UIKit

class MasterViewController: UITableViewController, UISearchBarDelegate, ListViewDelegate {

    var searchController: UISearchController!

    var searchResults = [StylisticDevice]()
    
    var detailViewController: DetailViewController?
    var noElementsLabel: UILabel!

    var originalSeparatorColor: UIColor!
    // ------------------------------------------------------------------------
    // MARK: - Initialisation
    // ------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeNoElementsSubview("Diese Liste ist leer.")
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.frame.size.width = self.view.bounds.size.width
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.whiteColor()
        searchController.searchBar.sizeToFit()
        searchController.searchResultsUpdater = self
        searchController.searchBar.backgroundColor = UIColor.whiteColor()
        searchController.searchBar.tintColor = UIColor.purpleColor()
//        navigationController?.navigationBar.shadowImage = UIImage()
        tableView.tableHeaderView = searchController.searchBar

        animateNoEntries(DataManager.sharedInstance.selectedList.elements.isEmpty, withTitle: "")

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }

        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = DataManager.sharedInstance.selectedList.title
        DataManager.sharedInstance.selectedList.elements.sort(<)
        tableView.reloadData()
    }
    
    func initializeNoElementsSubview(displayedText: String) {
        originalSeparatorColor = tableView!.separatorColor

        var widthOfView = (UIDevice.currentDevice().userInterfaceIdiom == .Pad) ? preferredContentSize.width : view.bounds.width
        var heightOfView = (UIDevice.currentDevice().userInterfaceIdiom == .Pad) ? preferredContentSize.height : view.bounds.height
        
        noElementsLabel = UILabel()
        noElementsLabel.frame = CGRect(x: 0, y: 0, width: widthOfView, height: heightOfView) // 222 looks good with tableView
        noElementsLabel.numberOfLines = 0
        noElementsLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        noElementsLabel.textColor = UIColor.darkGrayColor()
        noElementsLabel.shadowColor = UIColor.lightTextColor()
        noElementsLabel.textAlignment =  NSTextAlignment.Center
        noElementsLabel.text = displayedText
        view.insertSubview(noElementsLabel, belowSubview: self.tableView)
        
        // Not working!
        let xCenterConstraint = NSLayoutConstraint(item: noElementsLabel, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        self.view.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: noElementsLabel, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0)
        self.view.addConstraint(yCenterConstraint)
    }

    // ------------------------------------------------------------------------
    // MARK: - Transitioning
    // ------------------------------------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            definesPresentationContext = true
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                var device: StylisticDevice!
                
                if DataManager.sharedInstance.selectedList.enoughForCategories == true {
                    device = DataManager.sharedInstance.selectedList.sortedList[DataManager.sharedInstance.selectedList.presentLetters[indexPath.section]]![indexPath.row]
                } else{
                    device = DataManager.sharedInstance.selectedList.elements[indexPath.row] as StylisticDevice
                }
                
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.device = device
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        else if segue.identifier == "showQuiz" {
            definesPresentationContext = true
            if DataManager.sharedInstance.selectedList.elements.count >= 4 {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! QuizViewController
                controller.devices = DataManager.sharedInstance.selectedList.elements
            } else {
                let alertController = UIAlertController(title: "Quiz nicht möglich", message:
                    "Vergewissere dich, dass die ausgewählte Liste mindestens vier Elemente beinhaltet.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Alles klar", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        else if segue.identifier == "showLists" {
            definesPresentationContext = false
            let destinationController = (segue.destinationViewController as! UINavigationController).topViewController as! ListViewController
            destinationController.delegate = self
        }
    }
    
    // ------------------------------------------------------------------------
    // MARK: - Helper Functions
    // ------------------------------------------------------------------------
    
    private func animateNoEntries(noEntries: Bool, withTitle title: String = "Diese Liste ist leer.") {
        noElementsLabel?.hidden = !noEntries
        noElementsLabel.text = title
        if noEntries {
            // TODO: Not working
            UIView.animateWithDuration(0.3) {
                self.tableView.separatorColor = UIColor.whiteColor()
                //                tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
            }
        } else {
            UIView.animateWithDuration(0.3) {
                self.tableView.separatorColor = self.originalSeparatorColor
                //                tableView.backgroundColor = UIColor(white: 1, alpha: 1)
            }
        }
    }
    
    private func setNavigationItemsEnabled(enable: Bool) {
        navigationItem.leftBarButtonItem?.enabled = enable
        navigationItem.rightBarButtonItem?.enabled = enable
    }

    
    // ------------------------------------------------------------------------
    // MARK: - Table View
    // ------------------------------------------------------------------------

    // MARK: Data Source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active {
            animateNoEntries(searchResults.isEmpty, withTitle: "")
        } else {
            animateNoEntries(DataManager.sharedInstance.selectedList.elements.isEmpty)
            if DataManager.sharedInstance.selectedList.enoughForCategories == true {
                return DataManager.sharedInstance.selectedList.sortedList.count
            }
        }
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return searchResults.count
        }
        
        if DataManager.sharedInstance.selectedList.enoughForCategories {
            return DataManager.sharedInstance.selectedList.sortedList[DataManager.sharedInstance.selectedList.presentLetters[section]]?.count ?? 0
        }
        
        return DataManager.sharedInstance.selectedList.elements.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        var device: StylisticDevice!
        
        if searchController.active {
            device = searchResults[indexPath.row]
        } else {
            if (DataManager.sharedInstance.selectedList.enoughForCategories == true) {
                device = DataManager.sharedInstance.selectedList.sortedList[DataManager.sharedInstance.selectedList.presentLetters[indexPath.section]]![indexPath.row]
            } else {
                device = DataManager.sharedInstance.selectedList.elements[indexPath.row]
            }
        }
        
        cell.textLabel?.text = device.title
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !searchController.active && DataManager.sharedInstance.selectedList.enoughForCategories == true {
            return (DataManager.sharedInstance.selectedList.sortedList[DataManager.sharedInstance.selectedList.presentLetters[section]] != nil) ? DataManager.sharedInstance.selectedList.presentLetters[section] : nil
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        // if magnifying glass
        if index == 0 {
            tableView.scrollRectToVisible(self.searchController.searchBar.frame, animated: false)
            return -1
        }

        return (find(DataManager.sharedInstance.selectedList.presentLetters, title) ?? 0)
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        var index = DataManager.sharedInstance.selectedList.presentLetters
        if searchController != nil {
            index.insert(UITableViewIndexSearch, atIndex: 0)
        }
        
        UITableViewIndexSearch
        if searchController.active {
            return nil
        }
        return (DataManager.sharedInstance.selectedList.enoughForCategories == true) ? index : nil
    }

    // ------------------------------------------------------------------------
    // MARK: Delegate

    // Favorites
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return DataManager.sharedInstance.selectedList.editable
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            DataManager.sharedInstance.selectedList.elements.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    
    // ------------------------------------------------------------------------
    // MARK: - Table View
    // ------------------------------------------------------------------------

    // TODO: Dispatch
    func listView(didSelectListWithTag tag: Int) {
        DataManager.sharedInstance.selectedList = DataManager.sharedInstance.allDeviceLists[tag]
        NSUserDefaults.standardUserDefaults().setValue(DataManager.sharedInstance.selectedList.title, forKey: "Selected List")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.tableView.reloadData()
        
        // Scroll tableView to top.
        if !DataManager.sharedInstance.selectedList.elements.isEmpty {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        } else {
            tableView.setContentOffset(CGPointZero, animated: false)
        }
    }
}

extension MasterViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if !searchController.active {
            animateNoEntries(DataManager.sharedInstance.selectedList.elements.isEmpty, withTitle: "Diese Liste ist leer.")
            tableView.reloadData()
            setNavigationItemsEnabled(true)
            return
        }
        animateNoEntries(searchResults.isEmpty, withTitle: "")
        setNavigationItemsEnabled(false)
        let searchString = searchController.searchBar.text
        
        /// Finds stylistic devices from the selected list where the searchString is contained in any of its string-properties.
        searchResults = DataManager.sharedInstance.selectedList.elements.filter() { element in
            return !element.searchableStrings.filter({ searchableString in
                return searchableString.rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil }).isEmpty
        }

        tableView.reloadData()
//        searchController.searchResultsController?.view.alpha = searchResults.isEmpty ? 0 : 1
    }
}
