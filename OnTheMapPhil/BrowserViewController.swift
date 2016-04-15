//
//  BrowserViewController.swift
//  OnTheMapPhil
//
//  Created by Phillip Hughes on 15/04/2016.
//  Copyright © 2016 Phillip Hughes. All rights reserved.
//

import Foundation
import UIKit

class BrowserViewController: UIViewController {
    @IBOutlet var webView: UIWebView!
    
    var url:NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let u = url{
            let req = NSURLRequest(URL:u)
            self.webView!.loadRequest(req)
        }
    }
}
