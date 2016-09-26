//
//  FeedbackNegativeViewController.swift
//  Rhetorica
//
//  Created by Nick Podratz on 04.10.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit
import MessageUI

class FeedbackNegativeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        FacebookLogger.feedbackDidReceiveUserResponse(false)
    }

    @IBAction func pressedComposeMail(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            composeMail()
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("mail_kann_nicht_erstellt_werden", comment: ""), message: NSLocalizedString("mail_alert_beschreibung", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - Mail Compose View Controller Delegate
extension FeedbackNegativeViewController: MFMailComposeViewControllerDelegate {
    
    func composeMail(_ completion: (() -> Void)? = nil) {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        let deviceModel = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setToRecipients(["nick.podratz.support@icloud.com"])
        picker.setSubject("\(appName) App Feedback")
        picker.setMessageBody("\n\n\n\n\n\n\n------------------------------------\nSome details about my device:\n– \(deviceModel) with iOS \(systemVersion)\n– \(appName), version \(appVersion)", isHTML: false)
        
        present(picker, animated: true, completion: completion)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            if result == MFMailComposeResult.sent {
                self.performSegue(withIdentifier: "toThankYouViewController", sender: self)
            }
        }
    }
    
}
