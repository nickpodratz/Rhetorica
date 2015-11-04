//
//  MasterViewController.swift
//  Rhetorica
//
//  Created by Nick Podratz on 15.09.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices


class MasterViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noElementsLabel: UILabel!
    @IBOutlet weak var noEntriesView: UIView!
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    var searchController: UISearchController = UISearchController(searchResultsController: nil)
    var detailViewController: DetailViewController? {
        didSet {
            detailViewController?.device = self.selectedDeviceList.elements.first
        }
    }
    
    // MARK: Properties
    
    var selectedLanguage: Language! {
        didSet{
            // Update deviceLists…
            let allDevices = StylisticDevice.getDevicesFromPlistForLanguage(selectedLanguage)
            deviceLists = DeviceList.getAllDeviceLists(allDevices)
            indexStylisticDevicesIfPossible(allDevices)
            
            if let listTitle = DeviceList.getSelectedListTitle() {
                if let loadedList = self.deviceLists.filter({$0.title == listTitle}).first {
                    selectedDeviceList = loadedList
                }
            } else {
                selectedDeviceList = deviceLists.first!
            }
            detailViewController?.device = selectedDeviceList.elements.first
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
    var selectedDeviceList: DeviceList!
    var favorites: DeviceList? {
        return deviceLists.last
    }

    var searchResults = [StylisticDevice]()
    var originalSeparatorColor: UIColor!
    
    
    // MARK: Life Cycle
    
    override func awakeFromNib() {
        // before: UIDevice.currentDevice().userInterfaceIdiom == .Pad
        if traitCollection.horizontalSizeClass == .Regular && traitCollection.verticalSizeClass == .Regular {
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set language
        let languageIdentifier = Language.getSelectedLanguageIdentifier() ?? Language.getSystemLanguageIdentifier()
        selectedLanguage = Language(identifier: languageIdentifier) ?? .German
        
        tableView.dataSource = self
        tableView.delegate = self
        setupSearchController()
        
        originalSeparatorColor = tableView!.separatorColor
        navigationItem.title = selectedDeviceList.title
        
        animateNoEntriesLabel(selectedDeviceList.elements.isEmpty)
        
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
        searchController.searchBar.tintColor = UIColor.rhetoricaPurpleColor()
        searchController.view.layoutIfNeeded()
        tableView.tableHeaderView = searchController.searchBar
        
        NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: Selector("scrollTableViewToTop"), userInfo: nil, repeats: false)
    }
    
    @IBAction func cancelSearch(sender: AnyObject) {
        searchController.active = false
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
    
    
    // MARK: Private Functions
    
    private func animateNoEntriesLabel(noEntries: Bool) {
        
        // Set text of label
        switch selectedDeviceList.editable {
        case true:
            noElementsLabel.text = NSLocalizedString("ihre_lernliste_ist_leer", comment: "")
        default:
            noElementsLabel.text = NSLocalizedString("diese_liste_ist_leer", comment: "")
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
    
    private func indexStylisticDevicesIfPossible(devices: [StylisticDevice]) {
        if #available(iOS 9.0, *) {
            for device in devices {
                let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                attributeSet.title = device.title
                attributeSet.contentDescription = device.definition
                let item = CSSearchableItem(uniqueIdentifier: "\(device.title)", domainIdentifier: "np.rhetorica", attributeSet: attributeSet)
                CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item]) { (error: NSError?) -> Void in
                    if let error = error {
                        print("Indexing error: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            print("Could not index stylistic devices on device, as its OS is too old.")
        }
    }
}

// MARK: - MasterViewController: UITableViewDataSource, UITableViewDelegate
extension MasterViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active {
            animateNoEntriesLabel(searchResults.isEmpty)
        } else {
            animateNoEntriesLabel(selectedDeviceList.elements.isEmpty)
            if selectedDeviceList.enoughForCategories == true {
                return selectedDeviceList.sortedList.count
            }
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return searchResults.count
        }
        
        if selectedDeviceList.enoughForCategories {
            return selectedDeviceList.sortedList[selectedDeviceList.presentLetters[section]]?.count ?? 0
        } else {
            return selectedDeviceList.elements.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.textLabel?.text = device.title
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !searchController.active && selectedDeviceList.enoughForCategories == true {
            return (selectedDeviceList.sortedList[selectedDeviceList.presentLetters[section]] != nil) ? selectedDeviceList.presentLetters[section] : nil
        }
        return nil
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        // if magnifying glass
        if index == 0 {
            tableView.scrollRectToVisible(self.searchController.searchBar.frame, animated: false)
            return -1
        }
        
        return (selectedDeviceList.presentLetters.indexOf(title) ?? 0)
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var index = selectedDeviceList.presentLetters
        index.insert(UITableViewIndexSearch, atIndex: 0)
        
        return (selectedDeviceList.enoughForCategories && !searchController.active) ? index : nil
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
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
    
    
    // MARK: Delegate
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return selectedDeviceList.editable
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            selectedDeviceList.elements.removeAtIndex(indexPath.row)
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
    
}


// MARK: - MasterViewController: ListViewDelegate

extension MasterViewController: ListViewDelegate {
    // TODO: Dispatch
    func listView(didSelectListWithTag tag: Int) {
        selectedDeviceList = deviceLists[tag]
        DeviceList.setSelectedListTitle(selectedDeviceList.title)
        
        navigationItem.title = selectedDeviceList.title
        tableView.reloadData()
        scrollTableViewToTop()
    }
    
    func listView(didSelectLanguage language: Language) {
        if language != self.selectedLanguage {
            Language.setSelectedLanguage(language)
            self.selectedLanguage = language
            tableView.reloadData()
            scrollTableViewToTop()
            detailViewController?.favorites = self.deviceLists.last!
            detailViewController?.device = self.selectedDeviceList.elements.first
        }
    }
}


// MARK: - MasterViewController: UISearchResultsUpdating

extension MasterViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        definesPresentationContext = true
        
        if searchController.active {
            /// Searches for searchString in all properties of deviceList.
            searchResults = selectedDeviceList.elements.filter { device in
                return !device.searchableStrings.filter({ stringProperty in
                    return stringProperty.rangeOfString(searchString!, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil }).isEmpty
            }
            
            tapRecognizer.enabled = searchResults.isEmpty
            
            // update UI
            animateNoEntriesLabel(searchResults.isEmpty)
            setNavigationItemsEnabled(false)
        } else {
            // Called when Search is canceled, update UI
            animateNoEntriesLabel(selectedDeviceList.elements.isEmpty)
            setNavigationItemsEnabled(true)
            tapRecognizer.enabled = false
        }
        
        tableView.reloadData()
    }
}
