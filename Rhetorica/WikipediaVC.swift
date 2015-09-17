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
    @IBOutlet weak var shareButton: UIBarButtonItem!
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
        noConnectionLabel.hidden = true

        // Start request
        if urlString != nil { // Add this here?: [unowned self] in
            let url = NSURL(string: urlString!)
            let request = NSURLRequest(URL:url!)
            webView.loadRequest(request)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        webView.loadHTMLString("<html></html>", baseURL: nil)
        webView.stopLoading()
        webView.delegate = nil
        webView.removeFromSuperview()
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        super.viewWillDisappear(animated)
    }
    
    
    // MARK: - User Interaction

    @IBAction func share(sender: UIBarButtonItem) {
        let activityViewController = UIActivityViewController(
            activityItems: [urlString as NSString!],
            applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        self.webView.scalesPageToFit = true;
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    
    // MARK: - WebView Delegate
    
    func webViewDidStartLoad(webView: UIWebView) {
        webView.hidden = true
        activityIndicator.startAnimating()
        noConnectionLabel.hidden = true
        navigationItem.rightBarButtonItem?.enabled = false
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.hidden = false
        activityIndicator.stopAnimating()
        navigationItem.rightBarButtonItem?.enabled = true
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        webView.hidden = true
        activityIndicator.stopAnimating()
        noConnectionLabel.hidden = false
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
