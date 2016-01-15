//
//  TableViewController.swift
//  WBPullToRefresh
//
//  Created by caowenbo on 16/1/13.
//  Copyright © 2016年 曹文博. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var count = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weak var wealSelf = self
        self.tableView.refreshBlock { () -> Void in
            wealSelf?.count++
        }
    
    }
    

    @IBAction func endRefreshing(sender: AnyObject) {
        tableView.reloadData()
        tableView.endRefresh()
    }
 
    
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = "测试数据\(count - indexPath.row)"
        return cell
    }
    
    
}
