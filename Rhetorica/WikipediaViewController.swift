//
//  WikipediaViewController.swift
//  Rhetorica
//
//  Created by Nick Podratz on 28.11.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit
import WebKit

class WikipediaViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if urlString != nil {
            var url = NSURL(string: urlString!)
            var request = NSURLRequest(URL:url!)
            self.webView.loadRequest(request)
        }
    }
    
    @IBAction func share(sender: UIBarButtonItem) {
        let activityViewController = UIActivityViewController(
            activityItems: [urlString as NSString!],
            applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        self.webView.scalesPageToFit = true;
        presentViewController(activityViewController, animated: true, completion: nil)
    }
}
