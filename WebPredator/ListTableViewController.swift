//
//  ListTableViewController.swift
//  WebPredator
//
//  Created by Jeff Hodnett on 5/5/15.
//  Copyright (c) 2015 Jeff Hodnett. All rights reserved.
//

import Foundation
import UIKit

class ListTableViewController: UITableViewController {
    
    struct ListItem {
        var title: String
        var file: String
    }
    
    var objects: [ListItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup data
        self.objects.append(ListItem(title: "Example 1 string", file: "example-1-color"))
        self.objects.append(ListItem(title: "Example 1 hex", file: "example-1-hex"))
        self.objects.append(ListItem(title: "Example 2 hex", file: "example-2-hex"))
        self.objects.append(ListItem(title: "Example 2 rgb", file: "example-2-rgb"))
        self.objects.append(ListItem(title: "Example 3 hex", file: "example-3-hex"))
        self.objects.append(ListItem(title: "Example 3 rgb", file: "example-3-rgb"))
        self.objects.append(ListItem(title: "Example 3 multi css", file: "example-3-multi-css"))
    }
    
    // MARK: <UITableViewDataSource>
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        
        let item = self.objects[indexPath.row]
        cell.textLabel?.text = item.title
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow() {
            let vc: ViewController = segue.destinationViewController as! ViewController
            let item = self.objects[indexPath.row]
            vc.exampleName = item.file
            vc.title = item.title
        }
    }
}
    