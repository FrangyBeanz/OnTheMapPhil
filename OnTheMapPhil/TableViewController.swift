//
//  TableViewController.swift
//  OnTheMapPhil
//
//  Created by Phillip Hughes on 03/04/2016.
//  Copyright © 2016 Phillip Hughes. All rights reserved.
//
import Foundation
import MapKit
import UIKit

class TableViewController: UIViewController
{
    
//    @IBOutlet var tableOfStudents: UITableView!
    
  /**
    var pinButton = UIBarButtonItem()// THe button that will update/save Student's location and other data
    var logoutButton = UIBarButtonItem()
    var reloadButton = UIBarButtonItem()
        @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.editing = false
        let networkReachability = Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus()
        if (networkStatus.rawValue == NotReachable.rawValue) {
            displayMessageBox("No Network Connection")
        }
    }
    */
//    override func didReceiveMemoryWarning() {
  //      super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
  //  }
    
   // override func viewDidAppear(animated: Bool) {
    //    self.tableView.reloadData()
   // }
    
    // MARK: - Table view Related
    /*
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = UdacityClient.sharedInstance().students {
            count = s.count
        }
        
        return count
    }
    /**
    
    //populates the table view. (First Names and Last Names)
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableViewCell", forIndexPath: indexPath)
        
        var student = Student(uniqueKey: "a",firstName: "a",lastName: "a")//Dummy struct. It will be updated next
        
        if let s = UdacityClient.sharedInstance().students?[indexPath.row]{
            student = s
        }
        cell.textLabel?.text = student.firstName + " " + student.lastName
        cell.imageView?.image = UIImage(named: "mappin_18x18")
        // Configure the cell...
        if (indexPath.row == UdacityClient.sharedInstance().students!.count - 1){
            getNextResults()
        }
        
        return cell
    }
    
    //didUnhighlightRowAtIndexPath works better than didSelectRowAtIndexPath because didSelectRowAtIndexPath didn't worked as expected.
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        //        Uncomment the following 3 lines if you want the browser to be embedded in the application
        
        //        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController")! as! WebViewController
        //        detailController.url = NSURL(string: UdacityClient.sharedInstance().students![indexPath.row].mediaURL!)
        //        self.navigationController?.pushViewController(detailController, animated: true)
        
        let request = NSURLRequest(URL: NSURL(string: UdacityClient.sharedInstance().students![indexPath.row].mediaURL!)!)
        UIApplication.sharedApplication().openURL(request.URL!)
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false}
    
   
   
    //MARK: Other
    
    //if it is an overwrite set the apropriate variable to signify the update and present the next view.
    func overwrite(alert: UIAlertAction!){
        self.update = true //Mark for overwrite(update)
        self.presentEnterLocationViewController()
    }
    
    
    //presents the Enter Location View
    func presentEnterLocationViewController(){
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("EnterLocationViewController") as! InputPinController
        let navController = UINavigationController(rootViewController: detailController) // Creating a navigation controller with detailController at the root of the navigation stack.
        self.navigationController!.presentViewController(navController, animated: true) {
            self.navigationController?.popViewControllerAnimated(true)
            return ()
        }
    }
*/ */
    
}
