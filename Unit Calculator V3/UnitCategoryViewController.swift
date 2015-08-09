//
//  UnitCategoryViewController.swift
//  Unit Calculator V3
//
//  Created by Ruslan Kolesnik on 1/9/15.
//  Copyright (c) 2015 Ruslan Kolesnik. All rights reserved.
//

import UIKit

class UnitCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    let categories = ["Area", "Energy", "Length", "Power", "Pressure", "Speed", "Temperature", "Time", "Volume", "Weight"]
    var selectedRow = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.shadowColor = UIColor.blackColor().CGColor
        self.view.layer.shadowOpacity = 7.5
        self.view.layer.shadowRadius = 10.0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        println("memory warning")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        self.selectedRow = indexPath.row
        return indexPath
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showUnits", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UnitCategory", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = self.categories[indexPath.row]
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.textAlignment = NSTextAlignment.Left
        cell.textLabel?.font = UIFont(name: "Simplifica", size: 30)
        var bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 0.2)
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationViewController = segue.destinationViewController as UnitsViewController
        destinationViewController.units = getUnitsList(self.categories[selectedRow])
    }
    
    

}
