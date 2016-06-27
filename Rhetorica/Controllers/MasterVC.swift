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
    var searchController = UISearchController(searchResultsController: nil)
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
                } else {
                    selectedDeviceList = deviceLists.first!
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
        
        // Setup data
        let languageIdentifier = Language.getSelectedLanguageIdentifier() ?? Language.getSystemLanguageIdentifier()
        selectedLanguage = Language(identifier: languageIdentifier) ?? .German
        
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
        
        // Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.frame.size.width = self.view.bounds.size.width
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.backgroundColor = UIColor.whiteColor()
        searchController.searchBar.tintColor = UIColor.rhetoricaPurpleColor()
        searchController.view.layoutIfNeeded()
        tableView.tableHeaderView = searchController.searchBar
        
//        // Hide searchBar initially
//        let searchBarHeight = searchController.searchBar.bounds.size.height
//        tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = false
        super.viewWillAppear(animated)
        tableView.deselectAllRows()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let counter = NSUserDefaults.standardUserDefaults().integerForKey(masterVCLoadingCounterKey) ?? 0
        
        if !isUITestMode {
            switch counter {
            case 12: performSegueWithIdentifier("toFeedback", sender: self)
            case 20: performSegueWithIdentifier("toFeedbackLiking", sender: self)
            case 28: performSegueWithIdentifier("toFeedbackSharing", sender: self)
            default: ()
            }
            
            let newCounter = counter + 1
            defaults.setInteger(newCounter, forKey: masterVCLoadingCounterKey)
            defaults.synchronize()
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({_ in
            if self.selectedDeviceList.isEmpty {
                self.scrollToTop()
                let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                let navHeight = self.navigationController?.navigationBar.bounds.size.height ?? 0
                cell?.bounds.size.height = self.tableView.bounds.size.height - navHeight
                self.tableView.reloadData()
            }
            }, completion: { _ in
        })
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
                        } else if indexPath.row < selectedDeviceList.elements.count {
                            return selectedDeviceList.elements[indexPath.row] as StylisticDevice
                        } else {
                            return nil
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
        if self.tableView.contentOffset.y > 0 {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Middle, animated: false)
        }
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
                } else if indexPath.row < selectedDeviceList.elements.count {
                    return selectedDeviceList.elements[indexPath.row] as StylisticDevice
                } else {
                    return nil
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
        self.tableView.userInteractionEnabled = true
        self.tableView.showsVerticalScrollIndicator = true
        
        if searchController.active {
            return searchResults.count
        }
        
        // For NoEntriesCell
        guard !selectedDeviceList.isEmpty else {
            self.tableView.userInteractionEnabled = false
            self.tableView.showsVerticalScrollIndicator = false
            return 1
        }
        
        if selectedDeviceList.enoughForCategories {
            return selectedDeviceList.sortedList[selectedDeviceList.presentLetters[section]]?.count ?? 0
        } else {
            return selectedDeviceList.elements.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // For NoEntriesCell
        guard !selectedDeviceList.isEmpty else {
            let cell = tableView.dequeueReusableCellWithIdentifier("NoEntriesCell", forIndexPath: indexPath)
            return cell
        }
        
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
        if !searchController.active && selectedDeviceList != nil && selectedDeviceList.enoughForCategories == true {
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
        
        return (!selectedDeviceList.isEmpty && selectedDeviceList.enoughForCategories && !searchController.active) ? index : nil
    }
}


// MARK: - MasterViewController: UITableViewDelgate (Deleting)

extension MasterViewController {
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .Default, title: NSLocalizedString("löschen", comment: ""), handler: { (action, indexPath) in
            self.tableView?.beginUpdates()
            self.tableView(
                self.tableView,
                commitEditingStyle: .Delete,
                forRowAtIndexPath: indexPath
            )
            if self.selectedDeviceList.isEmpty {
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            return
        })
        
        deleteButton.backgroundColor = UIColor.rhetoricaRedColor()
        return [deleteButton]
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // For NoEntriesCell
        guard !selectedDeviceList.isEmpty else {
            scrollToTop()
            let searchBarOffset = (self.searchController.searchBar.bounds.size.height ?? 0)
            return (tableView.bounds.size.height - searchBarOffset)
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return (selectedDeviceList.editable && !selectedDeviceList.isEmpty)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if selectedDeviceList.enoughForCategories {
                selectedDeviceList.elements.removeAtIndex(indexPath.row)
                tableView.reloadData()
            } else if indexPath.row < selectedDeviceList.elements.count {
                selectedDeviceList.elements.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
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
        FacebookLogger.currentDeviceListDidChange(selectedDeviceList, andLangugage: self.selectedLanguage)
    }
    
    func listView(didSelectLanguage language: Language) {
        if language != self.selectedLanguage {
            Language.setSelectedLanguage(language)
            self.selectedLanguage = language
            detailViewController?.favorites = self.deviceLists.last!
            FacebookLogger.currentDeviceListDidChange(selectedDeviceList, andLangugage: self.selectedLanguage)
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
            setNavigationItemsEnabled(true)
            tapRecognizer.enabled = false
        }
        
        tableView.reloadData()
    }
}

// MARK: - MasterViewController: UISearchResultsUpdating

extension MasterViewController {
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.cancelSearch(searchBar)
    }
}
