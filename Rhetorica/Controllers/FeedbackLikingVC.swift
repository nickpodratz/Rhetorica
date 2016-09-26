//
//  FeedbackLikingVC.swift
//  Rhetorica
//
//  Created by Nick Podratz on 26.11.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit

class FeedbackLikingViewController: UIViewController {
    
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
    
    @IBAction func showFacebookPagePressed(_ sender: UIButton) {
        if let url = URL(string: "fb://profile/1515153398777652/") {
            UIApplication.shared.openURL(url)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
