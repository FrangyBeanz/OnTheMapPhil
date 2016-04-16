//
//  TableViewController.swift
//  OnTheMapPhil
//
//  Created by Phillip Hughes on 03/04/2016.
//  Copyright © 2016 Phillip Hughes. All rights reserved.
//
import UIKit

class TableViewController: UITableViewController {
    
    var pinButton = UIBarButtonItem()// THe button that will update/save Student's location and other data
    @IBAction func LogoutButton(sender: UIBarButtonItem) {
        let udacitySession = UdacityClient()
        udacitySession.sessionID = "nil"
        UdacityClient.sharedInstance().account = nil
        UdacityClient.sharedInstance().students = nil
        self.navigationController?.dismissViewControllerAnimated(false, completion: nil)
        let LogoutAction =
        self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
        self.presentViewController(LogoutAction, animated: true)
            {
                self.navigationController?.popViewControllerAnimated(true)
                return ()
        }
    }
    var reloadButton = UIBarButtonItem()
    var count = 0 //Keeps track of the number of Students
    var update = false // Indicates whether the update/save location button will update or create a new entry to in the student's API
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view Related
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = UdacityClient.sharedInstance().students {
            count = s.count
        }
        
        return count
    }
    
    //populates the table view. (First Names and Last Names)
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    
    //handle row click to take to student link
    
    override func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        let request = NSURLRequest(URL: NSURL(string: UdacityClient.sharedInstance().students![indexPath.row].mediaURL!)!)
        UIApplication.sharedApplication().openURL(request.URL!)
    }
    
    override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false}
    
    
    //can show less results in the table so only getting 20 at a time vs 100
    func getNextResults(){
        UdacityClient.sharedInstance().getStudentLocations(limit: 20,skip: count){result, errorString in
            if let er = errorString{
                self.displayMessageBox("Couldn't get Student Details")
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    if (result != nil) {
                        if (result!.count > 0 ){
                            self.tableView.reloadData()
                        }
                    }
                    return
                })
            }
        }
    }
    
    //MARK: Button Actions
    
    //Reload all data
    func reload(){
        let networkReachability = Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus()
        if (networkStatus.rawValue == NotReachable.rawValue) {// Before reloading check if there is an available internet connection
            displayMessageBox("No Network Connection")
        }else{
            // If the reload was pressed all the data will be reloaded and the array of student's should be nullified
            count = 0
            UdacityClient.sharedInstance().students = nil
            getNextResults()
        }
    }
    
    
    //The action of the first new location button(top left)
    func newLocation(){
        let networkReachability = Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus()
        if (networkStatus.rawValue == NotReachable.rawValue) {// Before quering for an existing location check if there is an available internet connection
            displayMessageBox("No Network Connection")
        }else{
            UdacityClient.sharedInstance().queryStudentLocation(UdacityClient.sharedInstance().account!.uniqueKey){ result,errorString in
                if let er = errorString {
                    self.displayMessageBox("Couldn't query for Student Location")
                }else{
                    if result != nil{//THen it is an update
                        dispatch_async(dispatch_get_main_queue()){
                            
                            let alert = UIAlertController(title: "", message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default, handler: self.overwrite))
                            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                            self.navigationController!.presentViewController(alert, animated: true){
                                return ()
                            }
                        }
                    }else{//Not an update. New record will be created(update variable remains false)
                        dispatch_async(dispatch_get_main_queue()){
                            self.presentEnterLocationViewController()
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Other
    
    //if it is an overwrite set the apropriate variable to signify the update and present the next view.
    func overwrite(alert: UIAlertAction!){
        self.update = true //Mark for overwrite(update)
        self.presentEnterLocationViewController()
    }
    
    
    //presents the Enter Location View
    func presentEnterLocationViewController(){
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("InputPinController") as! InputPinController
        let navController = UINavigationController(rootViewController: detailController) // Creating a navigation controller with detailController at the root of the navigation stack.
        self.navigationController!.presentViewController(navController, animated: true) {
            self.navigationController?.popViewControllerAnimated(true)
            return ()
        }
    }
    
    //Displays a basic alert box with the OK button and a message.
    func displayMessageBox(message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
}
