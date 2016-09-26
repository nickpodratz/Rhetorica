//
//  FeedbackPositiveViewController.swift
//  Rhetorica
//
//  Created by Nick Podratz on 04.10.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit

class FeedbackPositiveViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        FacebookLogger.feedbackDidReceiveUserResponse(true)
    }
    
    @IBAction func pressedOpenAppStore(_ sender: UIButton) {
        openInAppStore()
        FacebookLogger.appStoreDidOpenFromFeedback()
        Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(FeedbackPositiveViewController.toThankYouViewController), userInfo: nil, repeats: false)
    }
    
    func toThankYouViewController() {
        performSegue(withIdentifier: "toThankYouViewController", sender: self)
    }
    
    fileprivate func openInAppStore() {
        if let iOSAppStoreURL = URL(string: "itms-apps://itunes.apple.com/de/app/id\(appId)") {
            UIApplication.shared.openURL(iOSAppStoreURL)
            FacebookLogger.likeFBPagePressedFromFeedback()
        }
    }

}
