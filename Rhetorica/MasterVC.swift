//
//  MasterViewController.swift
//  Rhetorica
//
//  Created by Nick Podratz on 15.09.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit


class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ListViewDelegate {

    
    // MARK: - Outlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noElementsLabel: UILabel!
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var noEntriesView: UIView!
    
    var searchController: UISearchController!
    var detailViewController: DetailViewController?
    
    // MARK: - Properties
    
    var searchResults = [StylisticDevice]()
    var originalSeparatorColor: UIColor!

    
    // MARK: - Life Cycle

    override func awakeFromNib() {
        // before: UIDevice.currentDevice().userInterfaceIdiom == .Pad
        if traitCollection.horizontalSizeClass == .Regular && traitCollection.verticalSizeClass == .Regular {
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.dataSource = self
        tableView.delegate = self
        setupSearchController()
        
        originalSeparatorColor = tableView!.separatorColor
        navigationItem.title = DataManager.sharedInstance.selectedList.title

        animateNoEntriesLabel(DataManager.sharedInstance.selectedList.elements.isEmpty)

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            if controllers.count > 1 {
                if let navigationController = controllers[1] as? UINavigationController {
                    self.detailViewController = navigationController.visibleViewController as? DetailViewController
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        definesPresentationContext = true

        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: "checkForFeedbackVC", userInfo: nil, repeats: false)
    }
    
    func checkForFeedbackVC() {
        // Feedback Views
        let defaults = NSUserDefaults.standardUserDefaults()
        var counter = defaults.integerForKey(masterVCLoadingCounterKey) ?? 0
        print(counter)
        if counter == 15 {
            performSegueWithIdentifier("toFeedback", sender: self)
        }
        defaults.setInteger(++counter, forKey: masterVCLoadingCounterKey)
        defaults.synchronize()
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.frame.size.width = self.view.bounds.size.width
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.backgroundColor = UIColor.whiteColor()
        searchController.searchBar.tintColor = UIColor.customPurpleColor()
        searchController.view.layoutIfNeeded()
        tableView.tableHeaderView = searchController.searchBar
        
        NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: Selector("scrollTableViewToTop"), userInfo: nil, repeats: false)
    }
    
    @IBAction func cancelSearch(sender: AnyObject) {
        searchController.active = false
    }
    
    // MARK: - Transitioning
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == nil { return }
        
        searchController.searchBar.resignFirstResponder()
        switch segue.identifier! {
        case "showDetail":
            definesPresentationContext = true
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                print(self.splitViewController)
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.device = {
                    if self.searchController.active {
                        return self.searchResults[indexPath.row]
                    } else {
                        if DataManager.sharedInstance.selectedList.enoughForCategories == true {
                            return DataManager.sharedInstance.selectedList.sortedList[DataManager.sharedInstance.selectedList.presentLetters[indexPath.section]]![indexPath.row]
                        } else {
                            return DataManager.sharedInstance.selectedList.elements[indexPath.row] as StylisticDevice
                        }
                    }
                }()
            }
            
        case "showQuiz":
            definesPresentationContext = true
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! QuizViewController
            controller.deviceList = DataManager.sharedInstance.selectedList
            
        case "showList":
            definesPresentationContext = false
            let destinationController = (segue.destinationViewController as! UINavigationController).topViewController as! ListViewController
            destinationController.delegate = self

        case "toFeedback":
            break
            
        default: print("Found unknown identifier: \(segue.identifier!)")
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "showQuiz" {
            if DataManager.sharedInstance.selectedList.elements.count < 4 {
                let alertController = UIAlertController(title: "Quiz nicht möglich", message: "Vergewissern Sie sich, dass die ausgewählte Liste mindestens vier Einträge beinhaltet.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Alles klar", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    @IBAction func rewindsToMasterViewController(segue:UIStoryboardSegue) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    
    // MARK: - Private Functions
    
    private func animateNoEntriesLabel(noEntries: Bool) {
        
        // Set text of label
        switch DataManager.sharedInstance.selectedList {
        case DataManager.favorites:
            noElementsLabel.text = "Ihre Lernliste ist leer"
        default:
            noElementsLabel.text = "Diese Liste ist leer"
        }
        
        UIView.animateWithDuration(0,
            animations: {
                // Fade Color of Separator Lines
                let newSeparatorColor = (noEntries == true) ? UIColor.whiteColor() : self.originalSeparatorColor
                self.tableView.separatorColor = newSeparatorColor
            },
            completion: { _ in
                if !self.searchController.active {
                    self.searchController.searchBar.hidden = noEntries
                    self.noEntriesView?.hidden = !noEntries
                    self.tableView.userInteractionEnabled = !noEntries
                } else {
                    self.searchController.searchBar.hidden = false
                }
            }
        )
    }
    
    private func setNavigationItemsEnabled(enable: Bool) {
        navigationItem.leftBarButtonItem?.enabled = enable
        navigationItem.rightBarButtonItem?.enabled = enable
    }

    /// Not private, as it needs to be usable via a selector.
    func scrollTableViewToTop() {
        let navigationBarOrigin = navigationController!.navigationBar.frame.origin.y // 20
        if UIApplication.sharedApplication().statusBarHidden {
            tableView.setContentOffset(CGPoint(x: 0, y: 12), animated: false)
        } else {
            tableView.setContentOffset(CGPoint(x: 0, y: -navigationBarOrigin), animated: false)
        }
    }
    
    // MARK: - Table View
    // MARK: Data Source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active {
            animateNoEntriesLabel(searchResults.isEmpty)
        } else {
            animateNoEntriesLabel(DataManager.sharedInstance.selectedList.elements.isEmpty)
            if DataManager.sharedInstance.selectedList.enoughForCategories == true {
                return DataManager.sharedInstance.selectedList.sortedList.count
            }
        }
        
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return searchResults.count
        }
        
        if DataManager.sharedInstance.selectedList.enoughForCategories {
            return DataManager.sharedInstance.selectedList.sortedList[DataManager.sharedInstance.selectedList.presentLetters[section]]?.count ?? 0
        } else {
            return DataManager.sharedInstance.selectedList.elements.count ?? 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
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
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.textLabel?.text = device.title
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !searchController.active && DataManager.sharedInstance.selectedList.enoughForCategories == true {
            return (DataManager.sharedInstance.selectedList.sortedList[DataManager.sharedInstance.selectedList.presentLetters[section]] != nil) ? DataManager.sharedInstance.selectedList.presentLetters[section] : nil
        }
        return nil
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        // if magnifying glass
        if index == 0 {
            tableView.scrollRectToVisible(self.searchController.searchBar.frame, animated: false)
            return -1
        }

        return (DataManager.sharedInstance.selectedList.presentLetters.indexOf(title) ?? 0)
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var index = DataManager.sharedInstance.selectedList.presentLetters
        if searchController != nil {
            index.insert(UITableViewIndexSearch, atIndex: 0)
        }

        return (DataManager.sharedInstance.selectedList.enoughForCategories && !searchController.active) ? index : nil
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .Default, title: "Löschen", handler: { (action, indexPath) in
            self.tableView.dataSource?.tableView?(
                self.tableView,
                commitEditingStyle: .Delete,
                forRowAtIndexPath: indexPath
            )
            
            return
        })
        
        deleteButton.backgroundColor = UIColor.customRedColor()
        
        return [deleteButton]
    }
    

    // MARK: Delegate

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return DataManager.sharedInstance.selectedList.editable
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            DataManager.sharedInstance.selectedList.elements.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)

            if let split = self.splitViewController {
                let controllers = split.viewControllers
                if controllers.count > 1 {
                    if let navigationController = controllers[1] as? UINavigationController {
                        self.detailViewController = navigationController.visibleViewController as? DetailViewController
                    }
                }
            }

            detailViewController?.configureView() // For some reason not enough for updating the detailsVC
        }
    }
    
    
    // MARK: - ListView

    // TODO: Dispatch
    func listView(didSelectListWithTag tag: Int) {
        DataManager.sharedInstance.selectedList = DataManager.sharedInstance.allDeviceLists[tag]
        NSUserDefaults.standardUserDefaults().setValue(DataManager.sharedInstance.selectedList.title, forKey: "Selected List")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        navigationItem.title = DataManager.sharedInstance.selectedList.title
        tableView.reloadData()
        scrollTableViewToTop()
    }
}


// MARK: - UISearchResultsUpdating

extension MasterViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        definesPresentationContext = true

        if searchController.active {
            /// Searches for searchString in all properties of deviceList.
            searchResults = DataManager.sharedInstance.selectedList.elements.filter() { device in
                return !device.searchableStrings.filter({ stringProperty in
                    return stringProperty.rangeOfString(searchString!, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil }).isEmpty
            }
            
            tapRecognizer.enabled = searchResults.isEmpty
            
            // update UI
            animateNoEntriesLabel(searchResults.isEmpty)
            setNavigationItemsEnabled(false)
        } else {
            // Called when Search is canceled, update UI
            animateNoEntriesLabel(DataManager.sharedInstance.selectedList.elements.isEmpty)
            setNavigationItemsEnabled(true)
            tapRecognizer.enabled = false
        }
        
        tableView.reloadData()
    }
}
