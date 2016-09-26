//
//  WikipediaViewController.swift
//  Rhetorica
//
//  Created by Nick Podratz on 28.11.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit
import WebKit

class WikipediaViewController: UIViewController, UIWebViewDelegate {

    
    // MARK: - Outlets
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noConnectionLabel: UILabel!

    
    // MARK: - Properties
    
    var urlString: String?
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup webView
        webView.delegate = self
        
        // Setup activityIndicator
        activityIndicator.hidesWhenStopped = true
        noConnectionLabel.isHidden = true

        // Start request
        if urlString != nil { // Add this here?: [unowned self] in
            let url = URL(string: urlString!)
            let request = URLRequest(url:url!)
            webView.loadRequest(request)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // MARK: - WebView Delegate
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        webView.isHidden = true
        activityIndicator.startAnimating()
        noConnectionLabel.isHidden = true
        navigationItem.rightBarButtonItem?.isEnabled = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.isHidden = false
        activityIndicator.stopAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        webView.isHidden = true
        activityIndicator.stopAnimating()
        noConnectionLabel.isHidden = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
