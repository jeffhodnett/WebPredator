//
//  ViewController.swift
//  WebPredator
//
//  Created by Jeff Hodnett on 5/5/15.
//  Copyright (c) 2015 Jeff Hodnett. All rights reserved.
//

import UIKit

class ViewController: JHWebPredatorViewController {
    
    var exampleName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load example file
        if let example = self.exampleName {
            if let url = NSBundle.mainBundle().URLForResource(example, withExtension: "html") {
                let request = NSURLRequest(URL: url)
                self.webView.loadRequest(request)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
