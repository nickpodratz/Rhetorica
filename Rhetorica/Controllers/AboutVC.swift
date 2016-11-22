//
//  AboutViewController.swift
//
//  Created by Nick Podratz on 09.09.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

extension UITableView {
    func deselectAllRows(animated: Bool = true) {
        if let selectedIndexPaths = self.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                self.deselectRow(at: indexPath, animated: animated)
            }
        }
    }
}

extension String {
    func replace(_ target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}


class AboutViewController: UITableViewController, SKStoreProductViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    // MARK: - Outlets
    @IBOutlet weak var pictureDescriptionLabel: UILabel! {
        didSet{
            if let myAge = getMyAge() , pictureDescriptionLabel.text != nil {
                pictureDescriptionLabel.text = "\(myAge), \(pictureDescriptionLabel.text!)"
            }
        }
    }
    @IBOutlet weak var otherAppsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var otherAppsCollectionView: UICollectionView!
    @IBOutlet weak var otherAppsErrorLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var timer: Timer!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otherAppsCollectionView.delegate = self
        otherAppsCollectionView.dataSource = self
        storeProductController = SKStoreProductViewController()
        storeProductController.delegate = self
        
        imageView.layer.cornerRadius = imageView.bounds.size.width / 2
        imageView.layer.masksToBounds = true
        
        // Update size of cells
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(AboutViewController.getOtherApps), userInfo: nil, repeats: true)
        
        FacebookLogger.aboutPageOpened()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.deselectAllRows()
    }
    
    
    // MARK: - Store Kit
    
    var storeProductController: SKStoreProductViewController!
    
    var otherApps: [(icon: UIImage, title: String, trackId: Int)]? {
        didSet{
            if otherApps != nil {
                otherAppsCollectionView.reloadData()
                otherAppsErrorLabel.isHidden = (otherApps != nil)
            }
        }
    }
    
    func getOtherApps() {
        var returnData:[(icon: UIImage, title: String, trackId: Int)] = []
        
        // Define second thread
        let mainPatch = DispatchQueue.main
        let userInitiatedPatch = DispatchQueue.global(qos: .userInitiated)
        
        userInitiatedPatch.async {
            // Fetch my other apps in a asynchronously
            
            let countryCode = NSLocalizedString("majCountryCode", comment: "")
            guard let url = URL(string: "https://itunes.apple.com/search?term=Nick+Podratz&media=software&country=\(countryCode)") else { print("Can't create URL."); return }
            URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
                
                do {
                    
                    guard let data = data else {
                        mainPatch.async {
                            self.otherAppsActivityIndicator.stopAnimating()
                            self.otherAppsErrorLabel.text = NSLocalizedString("NO_INTERNET_CONNECTION", comment: "No internet connection")
                            self.otherAppsErrorLabel.isHidden = false
                        }
                        return
                    }
                    guard
                        let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary,
                        let results = json["results"] as? [NSDictionary] , !results.isEmpty else {
                            self.otherAppsErrorLabel.text = NSLocalizedString("NO_DATA_FOUND", comment: "No data found")
                            self.otherAppsErrorLabel.isHidden = false
                            return
                    }
                    
                    // Prevent current app from being displayed in where clause
                    let localBundleId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as? String
                    let scaleFactor = Int(UIScreen.main.scale)
                    for result in results where result["bundleId"] as? String != localBundleId {
                        if let
                            trackId = result["trackId"] as? Int,
                            let appName = result["trackName"] as? String,
                            let iconURLString = result["artworkUrl60"] as? String,
                            let iconURL = URL(string: iconURLString.replace("60x60bb", withString: "\(60*scaleFactor)x\(60*scaleFactor)bb")),
                            let iconData = try? Data(contentsOf: iconURL),
                            let icon = UIImage(data: iconData) {
                                returnData.append(icon: icon, title: appName, trackId: trackId)
                        }
                    }
                    mainPatch.async {
                        // On success
                        self.timer.invalidate()
                        self.otherApps = returnData.isEmpty ? nil : returnData
                        self.otherAppsActivityIndicator.stopAnimating()
                    }
                } catch let error as NSError {
                    mainPatch.async {
                        print(error)
                        self.otherAppsActivityIndicator.stopAnimating()
                        self.otherAppsErrorLabel.isHidden = false
                    }
                }
                }) .resume()
        }
    }
    
    func openAppStorePagewithIdentifier(_ identifier: Int) {
        self.otherAppsCollectionView.isUserInteractionEnabled = false
        
        let productInfoDict = [SKStoreProductParameterITunesItemIdentifier: [identifier]]
        storeProductController.loadProduct(withParameters: productInfoDict) { result, error in
            if let error = error {
                print(error)
            }
        }
        self.navigationController?.present(self.storeProductController, animated: true) {
            self.otherAppsCollectionView.isUserInteractionEnabled = true
        }
    }
    
    fileprivate func openInAppStore() {
        let countryCode = NSLocalizedString("minCountryCode", comment: "")
        if let iOSAppStoreURL = URL(string: "itms-apps://itunes.apple.com/\(countryCode)/app/id\(appId)") {
            UIApplication.shared.openURL(iOSAppStoreURL)
        }
        tableView.deselectAllRows()
    }
    
    
    // MARK: - SKStoreProductViewControllerDelegate
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        self.dismiss(animated: true) {
            self.storeProductController = SKStoreProductViewController()
            self.storeProductController.delegate = self
        }
    }
    
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) {
        case (0, 1):
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let visitWebsiteLocalized = NSLocalizedString("VISIT_MY_WEBSITE", comment: "")
            alertController.addAction(UIAlertAction(title: visitWebsiteLocalized, style: UIAlertActionStyle.default, handler: { action in
                FacebookLogger.myWebsiteVisitedFromAboutPage()
                if let url = URL(string: "http://www.podratz.de") {
                    UIApplication.shared.openURL(url)
                }
                tableView.deselectAllRows()
            }))
            let showTwitterPageLocalized = NSLocalizedString("VISIT_TWITTER_PAGE", comment: "")
            alertController.addAction(UIAlertAction(title: showTwitterPageLocalized, style: UIAlertActionStyle.default, handler: { action in
                FacebookLogger.twitterPageDidOpenFromAboutPage()
                if let url = URL(string: "https://twitter.com/nickpodratz") {
                    UIApplication.shared.openURL(url)
                }
                tableView.deselectAllRows()
            }))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: UIAlertActionStyle.cancel, handler: { action in
                tableView.deselectAllRows()
            }))
            self.present(alertController, animated: true, completion: nil)
        case (1, 0):
            openInAppStore()
            tableView.deselectAllRows()
        case (1, 1):
            if MFMailComposeViewController.canSendMail() {
                self.composeMail()
                tableView.deselectAllRows()
            } else {
                let alertController = UIAlertController(title: NSLocalizedString("CAN_NOT_SEND_MAIL", comment: "Can't send mail"), message: NSLocalizedString("HINT_ON_MAIL_PREFERENCES", comment: "Make sure, that the information about your mail account in the system preferences are valid."), preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                    tableView.deselectAllRows()
                }))
                self.present(alertController, animated: true, completion: nil)
            }
        default: return
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    // MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OtherAppsCell", for: indexPath) as! OtherAppsCell
        let entry = otherApps![(indexPath as NSIndexPath).row] as (icon: UIImage, title: String, trackId: Int)
        cell.delegate = self
        cell.button.setBackgroundImage(entry.icon, for: UIControlState())
        cell.label.text = entry.title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return otherApps?.count ?? 0
    }
    
    
    // MARK: - Helper Functions
    
    fileprivate func getMyAge() -> Int? {
        func yearsFrom(_ date:Date) -> Int{
            return (Calendar.current as NSCalendar).components(NSCalendar.Unit.year, from: date, to: Date(), options: .matchFirst).year!
        }
        
        if let myBirthday = (Calendar.current as NSCalendar).date(era: 1, year: 1997, month: 2, day: 24, hour: 6, minute: 0, second: 0, nanosecond: 0) {
            return yearsFrom(myBirthday)
        }
        
        return nil
    }
    
}

// MARK: - Other Apps Cell Delegate
extension AboutViewController: OtherAppsCellDelegate {
    func otherAppsCell(pressedButton button: UIButton, inCell cell: UICollectionViewCell) {
        guard let indexPath = otherAppsCollectionView.indexPath(for: cell) else { return }
        guard let otherApps = otherApps else { return }
        FacebookLogger.detailsDidShowUpForApp(otherApps[(indexPath as NSIndexPath).row].title)
        openAppStorePagewithIdentifier(otherApps[(indexPath as NSIndexPath).row].trackId)
    }
}

// MARK: - Mail Compose View Controller Delegate
extension AboutViewController: MFMailComposeViewControllerDelegate {
    
    func composeMail() {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let deviceModel = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setToRecipients(["nick.podratz.support@icloud.com"])
        picker.setSubject("\(appName) App Feedback")
        picker.setMessageBody("\n\n\n\n\n\n\n-------------------------\nSome details about my device:\n– \(deviceModel) with iOS \(systemVersion)\n– \(appName), version \(appVersion)", isHTML: false)
        
        present(picker, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
}
