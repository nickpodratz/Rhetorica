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
                list.elements.sort()
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
        
        // Setup data
        let languageIdentifier = Language.getSelectedLanguageIdentifier() ?? Language.getSystemLanguageIdentifier()
        selectedLanguage = Language(identifier: languageIdentifier) ?? .german
        
        if #available(iOS 9.0, *) {
            if( traitCollection.forceTouchCapability == .available){
                registerForPreviewing(with: self, sourceView: view)
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
        searchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.backgroundColor = UIColor.white
        searchController.searchBar.tintColor = UIColor.rhetoricaPurpleColor()
        searchController.view.layoutIfNeeded()
        tableView.tableHeaderView = searchController.searchBar
        
        // No Entries View
        noEntriesView = UINib(nibName: "NoListView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? UIView
        if noEntriesView != nil {
            noEntriesView.layer.zPosition = 1
            self.view.addSubview(noEntriesView)
            layoutNoEntriesView()
            noEntriesView.isHidden = !selectedDeviceList.isEmpty
        }
        //        showNoEntriesView(noEntries: selectedDeviceList.isEmpty)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = false
        super.viewWillAppear(animated)
        tableView.deselectAllRows()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        let counter = UserDefaults.standard.integer(forKey: masterVCLoadingCounterKey)
        
        if !isUITestMode {
            switch counter {
            case 12: performSegue(withIdentifier: "toFeedback", sender: self)
            case 20: performSegue(withIdentifier: "toFeedbackLiking", sender: self)
            case 28: performSegue(withIdentifier: "toFeedbackSharing", sender: self)
            default: ()
            }
            
            let newCounter = counter + 1
            defaults.set(newCounter, forKey: masterVCLoadingCounterKey)
            defaults.synchronize()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        layoutNoEntriesView()
    }
    
    func layoutNoEntriesView() {
        let searchBarOffset = self.searchController.searchBar.bounds.height + navigationController!.navigationBar.frame.origin.y
        noEntriesView.frame = CGRect(x: 0, y: -searchBarOffset, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
        noEntriesView.isHidden = !selectedDeviceList.isEmpty
        if !selectedDeviceList.isEmpty {
            tableView.setContentOffset(CGPoint(x: 0, y: searchController.searchBar.bounds.size.height), animated: true)
        }
    }
    
    
    // MARK: Transitioning
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == nil { return }
        
        searchController.searchBar.resignFirstResponder()
        switch segue.identifier! {
        case "showDetail":
            definesPresentationContext = true
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                self.detailViewController = controller
                controller.favorites = favorites
                controller.device = {
                    if self.searchController.isActive {
                        return self.searchResults[(indexPath as NSIndexPath).row]
                    } else {
                        if selectedDeviceList.enoughForCategories == true {
                            return selectedDeviceList.sortedList[selectedDeviceList.presentLetters[(indexPath as NSIndexPath).section]]![(indexPath as NSIndexPath).row]
                        } else {
                            return selectedDeviceList.elements[(indexPath as NSIndexPath).row] as StylisticDevice
                        }
                    }
                }()
                controller.delegate = self
            }
        case "showQuiz":
            definesPresentationContext = true
            let controller = (segue.destination as! UINavigationController).topViewController as! QuizViewController
            controller.deviceList = selectedDeviceList
            controller.language = selectedLanguage
            controller.favorites = deviceLists.last!
            
        case "showList":
            definesPresentationContext = false
            let destinationController = (segue.destination as! UINavigationController).topViewController as! ListViewController
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showQuiz" {
            if selectedDeviceList.elements.count < 4 {
                let alertController = UIAlertController(title: NSLocalizedString("quiz_nicht_möglich", comment: ""), message: NSLocalizedString("quiz_alert_beschreibung", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("quiz_alert_alles_klar", comment: ""), style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    @IBAction func rewindsToMasterViewController(_ segue:UIStoryboardSegue) {
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
    
    // MARK: User Interaction
    
    @IBAction func cancelSearch(_ sender: AnyObject) {
        searchController.isActive = false
        self.tableView.separatorColor = self.defaultSeparatorColor
        if self.tableView.contentOffset.y > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .middle, animated: false)
        }
    }
    
    
    // MARK: Private Functions
    
    func scrollToTop() {
        if UIApplication.shared.isStatusBarHidden {
            tableView.setContentOffset(CGPoint(x: 0, y: 12), animated: false)
        } else {
            let navigationBarOrigin = navigationController!.navigationBar.frame.origin.y
            tableView.setContentOffset(CGPoint(x: 0, y: -navigationBarOrigin), animated: false)
        }
    }
    
    fileprivate func showNoEntriesView(noEntries: Bool) {
        if self.searchController.isActive || !noEntries {
            self.tableView.separatorColor = self.defaultSeparatorColor
            self.noEntriesView?.isHidden = true
            self.tableView.isUserInteractionEnabled = true
        } else {
            self.tableView.separatorColor = UIColor.white
            let searchBarOffset = navigationController!.navigationBar.frame.origin.y + searchController.searchBar.bounds.height
            tableView.setContentOffset(CGPoint(x: 0, y: -searchBarOffset), animated: false)
            self.noEntriesView?.isHidden = false
            self.tableView.isUserInteractionEnabled = false
        }
    }
    
    fileprivate func setNavigationItemsEnabled(_ enable: Bool) {
        navigationItem.leftBarButtonItem?.isEnabled = enable
        navigationItem.rightBarButtonItem?.isEnabled = enable
    }
}


extension MasterViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView?.indexPathForRow(at: location) else { return nil }
        guard let cell = tableView?.cellForRow(at: indexPath) else { return nil }
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? DetailViewController else { return nil }
        if #available(iOS 9.0, *) {
            previewingContext.sourceRect = cell.frame
        }
        detailVC.device = {
            if self.searchController.isActive {
                return self.searchResults[(indexPath as NSIndexPath).row]
            } else {
                if selectedDeviceList.enoughForCategories == true {
                    return selectedDeviceList.sortedList[selectedDeviceList.presentLetters[(indexPath as NSIndexPath).section]]![(indexPath as NSIndexPath).row]
                } else {
                    return selectedDeviceList.elements[(indexPath as NSIndexPath).row] as StylisticDevice
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
    override func numberOfSections(in tableView: UITableView) -> Int {
        if selectedDeviceList.enoughForCategories == true && !self.searchController.isActive {
            return selectedDeviceList.sortedList.count
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return searchResults.count
        }
        
        if selectedDeviceList.enoughForCategories {
            return selectedDeviceList.sortedList[selectedDeviceList.presentLetters[section]]?.count ?? 0
        } else {
            return selectedDeviceList.elements.count 
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var device: StylisticDevice!
        
        if searchController.isActive {
            device = searchResults[(indexPath as NSIndexPath).row]
        } else {
            if (selectedDeviceList.enoughForCategories == true) {
                device = selectedDeviceList.sortedList[selectedDeviceList.presentLetters[(indexPath as NSIndexPath).section]]![(indexPath as NSIndexPath).row]
            } else {
                device = selectedDeviceList.elements[(indexPath as NSIndexPath).row]
            }
        }
        
        cell.textLabel?.text = device.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !searchController.isActive && selectedDeviceList != nil && selectedDeviceList.enoughForCategories == true {
            return (selectedDeviceList.sortedList[selectedDeviceList.presentLetters[section]] != nil) ? selectedDeviceList.presentLetters[section] : nil
        }
        return nil
    }
    
}


// MARK: - MasterViewController: UITableViewDataSource (Section Index)

extension MasterViewController {
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        // if magnifying glass
        if index == 0 {
            tableView.scrollRectToVisible(self.searchController.searchBar.frame, animated: false)
            return -1
        }
        
        return (selectedDeviceList.presentLetters.index(of: title) ?? 0)
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var index = selectedDeviceList.presentLetters
        index.insert(UITableViewIndexSearch, at: 0)
        
        return (selectedDeviceList.enoughForCategories && !searchController.isActive) ? index : nil
    }
}


// MARK: - MasterViewController: UITableViewDelgate (Deleting)

extension MasterViewController {
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: NSLocalizedString("löschen", comment: ""), handler: { (action, indexPath) in
            self.tableView.dataSource?.tableView?(
                self.tableView,
                commit: .delete,
                forRowAt: indexPath
            )
            return
        })
        
        deleteButton.backgroundColor = UIColor.rhetoricaRedColor()
        return [deleteButton]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return selectedDeviceList.editable
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            if selectedDeviceList.enoughForCategories {
                selectedDeviceList.elements.remove(at: (indexPath as NSIndexPath).row)
                tableView.reloadData()
            } else {
                selectedDeviceList.elements.remove(at: (indexPath as NSIndexPath).row)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
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
            showNoEntriesView(noEntries: selectedDeviceList.elements.isEmpty)
        }
    }
}

// MARK: - MasterViewController: UISearchResultsUpdating

extension MasterViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        definesPresentationContext = true
        
        if searchController.isActive {
            /// Searches for searchString in all properties of deviceList.
            let searchString = searchController.searchBar.text
            searchResults = selectedDeviceList.elements.filter { device in
                return !device.searchableStrings.filter({ stringProperty in
                    return stringProperty.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive) != nil }).isEmpty
            }
            
            tapRecognizer.isEnabled = searchResults.isEmpty
            // update UI
            self.tableView.separatorColor = searchResults.isEmpty ? UIColor.white : defaultSeparatorColor
            setNavigationItemsEnabled(false)
        } else {
            // Called when Search is canceled, update UI
            self.tableView.separatorColor = defaultSeparatorColor
            showNoEntriesView(noEntries: selectedDeviceList.elements.isEmpty)
            setNavigationItemsEnabled(true)
            tapRecognizer.isEnabled = false
        }
        
        tableView.reloadData()
    }
}

// MARK: - MasterViewController: UISearchResultsUpdating

extension MasterViewController {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cancelSearch(searchBar)
    }
}
