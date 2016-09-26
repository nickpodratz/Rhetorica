//
//  FeedbackSharingVC.swift
//  Rhetorica
//
//  Created by Nick Podratz on 26.11.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit
import Social

class FeedbackSharingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        setupNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rewindsToMasterViewController" {
            let defaults = UserDefaults.standard
            defaults.set(0, forKey: masterVCLoadingCounterKey)
            defaults.synchronize()
        }
    }
    
    fileprivate func setupNavigationBar() {
        let transparentWhiteImage = UIImage(color: UIColor(white: 1, alpha: 0))
        navigationController?.navigationBar.shadowImage = transparentWhiteImage
        navigationController?.navigationBar.setBackgroundImage(transparentWhiteImage, for: UIBarMetrics.default)
    }
    
    @IBAction func postToFacebookPressed(_ sender: UIButton) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            let controller = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            let coutryCode = NSLocalizedString("minCountryCode", comment: "")
            let url = URL(string: "https://itunes.apple.com/\(coutryCode)/app/rhetorica-stilmittel-einfach/id926449450?mt=8")!
            controller?.add(url)
            self.present(controller!, animated:true, completion: nil)
        }
        else {
            print("no Facebook account found on device")
        }
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
