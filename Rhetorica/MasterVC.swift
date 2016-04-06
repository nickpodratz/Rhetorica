//
//  MasterViewController.swift
//  Rhetorica
//
//  Created by Nick Podratz on 15.09.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit

// , UIViewControllerPreviewing
class MasterViewController: UITableViewController, UISearchBarDelegate {
    
    // MARK: Outlets and Views
    
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    var noEntriesView: UIView!
    var searchController: UISearchController = UISearchController(searchResultsController: nil)
    var detailViewController: DetailViewController? {
        didSet {
            detailViewController?.device = nil
        }
    }
    
    // MARK: Properties
    
    var selectedLanguage: Language! {
        didSet{
            // Update deviceLists…
            let allDevices = StylisticDevice.getDevicesFromPlistForLanguage(selectedLanguage)
            deviceLists = DeviceList.getAllDeviceLists(allDevices, forLanguage: selectedLanguage)
            StylisticDevice.indexAllIfPossible(allDevices)
            
            if let listTitle = DeviceList.getSelectedListTitle() {
                if let loadedList = self.deviceLists.filter({$0.title == listTitle}).first {
                    selectedDeviceList = loadedList
                }
            } else {
                selectedDeviceList = deviceLists.first!
            }
            detailViewController?.device = nil
            tableView.reloadData()
        }
    }
    
    var deviceLists: [DeviceList] = [] {
        didSet{
            for list in deviceLists {
                list.elements.sortInPlace()
            }
        }
    }
    var selectedDeviceList: DeviceList! {
        didSet {
            navigationItem.title = selectedDeviceList.title
            tableView.reloadData()
            scrollToTop()
            showNoEntriesView(noEntries: selectedDeviceList.isEmpty)
        }
    }
    var favorites: DeviceList? {
        return deviceLists.last
    }
    
    var searchResults = [StylisticDevice]()
    var defaultSeparatorColor: UIColor!
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 9.0, *) {
            if( traitCollection.forceTouchCapability == .Available){
                registerForPreviewingWithDelegate(self, sourceView: view)
            }
        }
        
        // Set detailViewController property
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            if controllers.count > 1 {
                if let navigationController = controllers[1] as? UINavigationController {
                    self.detailViewController = navigationController.visibleViewController as? DetailViewController
                }
            }
        }
        
        defaultSeparatorColor = tableView!.separatorColor
        definesPresentationContext = true
        
        // Setup data
        let languageIdentifier = Language.getSelectedLanguageIdentifier() ?? Language.getSystemLanguageIdentifier()
        selectedLanguage = Language(identifier: languageIdentifier) ?? .German
        
        // Search Controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.frame.size.width = self.view.bounds.size.width
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.backgroundColor = UIColor.whiteColor()
        searchController.searchBar.tintColor = UIColor.rhetoricaPurpleColor()
        searchController.view.layoutIfNeeded()
        tableView.tableHeaderView = searchController.searchBar
        
        // No Entries View
        noEntriesView = UINib(nibName: "NoListView", bundle: nil).instantiateWithOwner(nil, options: nil).first as? UIView
        if noEntriesView != nil {
            noEntriesView.layer.zPosition = 1
            self.view.addSubview(noEntriesView)
            let searchBarOffset = self.searchController.searchBar.bounds.height + navigationController!.navigationBar.frame.origin.y
            noEntriesView.frame = CGRect(x: 0, y: -searchBarOffset, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
            noEntriesView.hidden = !selectedDeviceList.isEmpty
        }
        if !selectedDeviceList.isEmpty {
            tableView.setContentOffset(CGPoint(x: 0, y: searchController.searchBar.bounds.size.height), animated: true)
        }
        //        showNoEntriesView(noEntries: selectedDeviceList.isEmpty)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = false
        super.viewWillAppear(animated)
        tableView.deselectAllRows()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("called")
        let defaults = NSUserDefaults.standardUserDefaults()
        var counter = NSUserDefaults.standardUserDefaults().integerForKey(masterVCLoadingCounterKey) ?? 0
        
        switch counter {
        case 12: performSegueWithIdentifier("toFeedback", sender: self)
        case 20: performSegueWithIdentifier("toFeedbackLiking", sender: self)
        case 28: performSegueWithIdentifier("toFeedbackSharing", sender: self)
        default: ()
        }
        
        defaults.setInteger(++counter, forKey: masterVCLoadingCounterKey)
        defaults.synchronize()
    }
    
    
    // MARK: Transitioning
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == nil { return }
        
        searchController.searchBar.resignFirstResponder()
        switch segue.identifier! {
        case "showDetail":
            definesPresentationContext = true
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                self.detailViewController = controller
                controller.favorites = favorites
                controller.device = {
                    if self.searchController.active {
                        return self.searchResults[indexPath.row]
                    } else {
                        if selectedDeviceList.enoughForCategories == true {
                            return selectedDeviceList.sortedList[selectedDeviceList.presentLetters[indexPath.section]]![indexPath.row]
                        } else {
                            return selectedDeviceList.elements[indexPath.row] as StylisticDevice
                        }
                    }
                    }()
                controller.delegate = self
            }
        case "showQuiz":
            definesPresentationContext = true
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! QuizViewController
            controller.deviceList = selectedDeviceList
            controller.language = selectedLanguage
            controller.favorites = deviceLists.last!
            
        case "showList":
            definesPresentationContext = false
            let destinationController = (segue.destinationViewController as! UINavigationController).topViewController as! ListViewController
            destinationController.delegate = self
            destinationController.selectedLanguage = self.selectedLanguage
            destinationController.titleOfSelectedList = selectedDeviceList.title
            
        case "toFeedback":
            break
            
        default: print("Found unknown identifier: \(segue.identifier!)")
        }
    }
    
//    func previewingContext(previewingContext: UIViewControllerPreviewing,viewControllerForLocation location: CGPoint) -> UIViewController? method:
//    
//    // Obtain the index path and the cell that was pressed.
//    guard let indexPath = tableView.indexPathForRowAtPoint(location),
//    cell = tableView.cellForRowAtIndexPath(indexPath) else { return nil }
//    
//    // Create a destination view controller and set its properties.
//    guard let destinationViewController = storyboard?.instantiateViewControllerWithIdentifier("DestinationViewController") as? DestinationViewController else { return nil }
//    let object = fetchedResultController.objectAtIndexPath(indexPath)
//    destinationViewController.detailItem = object
//    
//    destinationViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
//    
//    previewingContext.sourceRect = cell.frame
//    
//    return destinationViewController
//}
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "showQuiz" {
            if selectedDeviceList.elements.count < 4 {
                let alertController = UIAlertController(title: NSLocalizedString("quiz_nicht_möglich", comment: ""), message: NSLocalizedString("quiz_alert_beschreibung", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("quiz_alert_alles_klar", comment: ""), style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    @IBAction func rewindsToMasterViewController(segue:UIStoryboardSegue) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    
    // MARK: User Interaction
    
    @IBAction func cancelSearch(sender: AnyObject) {
        searchController.active = false
        self.tableView.separatorColor = self.defaultSeparatorColor
    }
    
    
    // MARK: Private Functions
    
    func scrollToTop() {
        if UIApplication.sharedApplication().statusBarHidden {
            tableView.setContentOffset(CGPoint(x: 0, y: 12), animated: false)
        } else {
            let navigationBarOrigin = navigationController!.navigationBar.frame.origin.y
            tableView.setContentOffset(CGPoint(x: 0, y: -navigationBarOrigin), animated: false)
        }
    }
    
    private func showNoEntriesView(noEntries noEntries: Bool) {
        if self.searchController.active || !noEntries {
            self.tableView.separatorColor = self.defaultSeparatorColor
            self.noEntriesView?.hidden = true
            self.tableView.userInteractionEnabled = true
        } else {
            self.tableView.separatorColor = UIColor.whiteColor()
            let searchBarOffset = navigationController!.navigationBar.frame.origin.y + searchController.searchBar.bounds.height
            tableView.setContentOffset(CGPoint(x: 0, y: -searchBarOffset), animated: false)
            self.noEntriesView?.hidden = false
            self.tableView.userInteractionEnabled = false
        }
    }
    
    private func setNavigationItemsEnabled(enable: Bool) {
        navigationItem.leftBarButtonItem?.enabled = enable
        navigationItem.rightBarButtonItem?.enabled = enable
    }
}


extension MasterViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView?.indexPathForRowAtPoint(location) else { return nil }
        guard let cell = tableView?.cellForRowAtIndexPath(indexPath) else { return nil }
        guard let detailVC = storyboard?.instantiateViewControllerWithIdentifier("DetailVC") as? DetailViewController else { return nil }
        if #available(iOS 9.0, *) {
            previewingContext.sourceRect = cell.frame
        }
        detailVC.device = {
            if self.searchController.active {
                return self.searchResults[indexPath.row]
            } else {
                if selectedDeviceList.enoughForCategories == true {
                    return selectedDeviceList.sortedList[selectedDeviceList.presentLetters[indexPath.section]]![indexPath.row]
                } else {
                    return selectedDeviceList.elements[indexPath.row] as StylisticDevice
                }
            }
            }()
        detailVC.favorites = self.favorites
        detailVC.delegate = self
        return detailVC
    }
}


// MARK: - MasterViewController: UITableViewDataSource
extension MasterViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if selectedDeviceList.enoughForCategories == true && !self.searchController.active {
            return selectedDeviceList.sortedList.count
        }
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return searchResults.count
        }
        
        if selectedDeviceList.enoughForCategories {
            return selectedDeviceList.sortedList[selectedDeviceList.presentLetters[section]]?.count ?? 0
        } else {
            return selectedDeviceList.elements.count ?? 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        var device: StylisticDevice!
        
        if searchController.active {
            device = searchResults[indexPath.row]
        } else {
            if (selectedDeviceList.enoughForCategories == true) {
                device = selectedDeviceList.sortedList[selectedDeviceList.presentLetters[indexPath.section]]![indexPath.row]
            } else {
                device = selectedDeviceList.elements[indexPath.row]
            }
        }
        
        cell.textLabel?.text = device.title
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !searchController.active && selectedDeviceList.enoughForCategories == true {
            return (selectedDeviceList.sortedList[selectedDeviceList.presentLetters[section]] != nil) ? selectedDeviceList.presentLetters[section] : nil
        }
        return nil
    }
    
}


// MARK: - MasterViewController: UITableViewDataSource (Section Index)

extension MasterViewController {
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        // if magnifying glass
        if index == 0 {
            tableView.scrollRectToVisible(self.searchController.searchBar.frame, animated: false)
            return -1
        }
        
        return (selectedDeviceList.presentLetters.indexOf(title) ?? 0)
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var index = selectedDeviceList.presentLetters
        index.insert(UITableViewIndexSearch, atIndex: 0)
        
        return (selectedDeviceList.enoughForCategories && !searchController.active) ? index : nil
    }
}


// MARK: - MasterViewController: UITableViewDelgate (Deleting)

extension MasterViewController {
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .Default, title: NSLocalizedString("löschen", comment: ""), handler: { (action, indexPath) in
            self.tableView.dataSource?.tableView?(
                self.tableView,
                commitEditingStyle: .Delete,
                forRowAtIndexPath: indexPath
            )
            return
        })
        
        deleteButton.backgroundColor = UIColor.rhetoricaRedColor()
        return [deleteButton]
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return selectedDeviceList.editable
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            selectedDeviceList.elements.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            showNoEntriesView(noEntries: selectedDeviceList.isEmpty)
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
}


// MARK: - MasterViewController: ListViewDelegate

extension MasterViewController: ListViewDelegate {
    // TODO: Dispatch
    func listView(didSelectListWithTag tag: Int) {
        selectedDeviceList = deviceLists[tag]
        DeviceList.setSelectedListTitle(selectedDeviceList.title)
    }
    
    func listView(didSelectLanguage language: Language) {
        if language != self.selectedLanguage {
            Language.setSelectedLanguage(language)
            self.selectedLanguage = language
            detailViewController?.favorites = self.deviceLists.last!
        }
    }
}

extension MasterViewController: DetailViewControllerDelegate {
    func detailViewControllerDelegate(deviceNowIsFavorite isFavorite: Bool) {
        if selectedDeviceList == deviceLists.last {
            tableView.reloadData()
            if selectedDeviceList.elements.isEmpty {
                scrollToTop()
            }
            showNoEntriesView(noEntries: selectedDeviceList.elements.isEmpty)
        }
    }
}

// MARK: - MasterViewController: UISearchResultsUpdating

extension MasterViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        definesPresentationContext = true
        
        if searchController.active {
            /// Searches for searchString in all properties of deviceList.
            let searchString = searchController.searchBar.text
            searchResults = selectedDeviceList.elements.filter { device in
                return !device.searchableStrings.filter({ stringProperty in
                    return stringProperty.rangeOfString(searchString!, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil }).isEmpty
            }
            
            tapRecognizer.enabled = searchResults.isEmpty
            // update UI
            self.tableView.separatorColor = searchResults.isEmpty ? UIColor.whiteColor() : defaultSeparatorColor
            setNavigationItemsEnabled(false)
        } else {
            // Called when Search is canceled, update UI
            self.tableView.separatorColor = defaultSeparatorColor
            showNoEntriesView(noEntries: selectedDeviceList.elements.isEmpty)
            setNavigationItemsEnabled(true)
            tapRecognizer.enabled = false
        }
        
        tableView.reloadData()
    }
}
