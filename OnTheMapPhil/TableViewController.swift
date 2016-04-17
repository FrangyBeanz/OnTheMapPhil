//
//  TableViewController.swift
//  OnTheMapPhil
//
//  Created by Phillip Hughes on 03/04/2016.
//  Copyright © 2016 Phillip Hughes. All rights reserved.
//
import UIKit

class TableViewController: UITableViewController {
    
    @IBAction func RefreshButton(sender: UIBarButtonItem) {
        reload()
    }
    var count = 0 //Keeps track of the number of Students
    //Ensure that when Logout is clicked, the session is cleared and user is returned to login screen.
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
            }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    //check that there is still network connection when the view appears, and disable table editing
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.editing = false
        let networkReachability = Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus()
        if (networkStatus.rawValue == NotReachable.rawValue) {
            displayMessageBox("No Internet Connection. Please check your internet connection and try again.")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Count the number of students to determine rows
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = UdacityClient.sharedInstance().students {
            count = s.count
        }
        return count
    }
    
    //Populate the table with student info
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableViewCell", forIndexPath: indexPath)
        var student = Student(uniqueKey: "",firstName: "",lastName: "")
        if let s = UdacityClient.sharedInstance().students?[indexPath.row]{
            student = s
        }
        // Concat first and last name in the Cell
        cell.textLabel?.text = student.firstName + " " + student.lastName
        //Include a Pin Image in the Cell
        cell.imageView?.image = UIImage(named: "location-32")
        // Return the cell and decrease the count increment
        if (indexPath.row == UdacityClient.sharedInstance().students!.count - 1){
            getNextResults()
        }
        return cell
    }
    
    //handle row click to open browser window to the students link
    
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
            if let _ = errorString{
                self.displayMessageBox("Sorry, couldn't get student details")
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
    
   //Refresh the data from the API and reload the data
    func reload(){
        let networkReachability = Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus()
        if (networkStatus.rawValue == NotReachable.rawValue) { //error handle for internnet connection
            displayMessageBox("No Internet Connection. Please check your internet connection and try again.")
        }else{
            // Clean slate and get new results
            count = 0
            UdacityClient.sharedInstance().students = nil
            getNextResults()
        }
    }
    
    
    //Handle a new location in the Table View Controller
    func newLocation(){
        let networkReachability = Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus()
        if (networkStatus.rawValue == NotReachable.rawValue) {
            //Error handle for no network connection
            displayMessageBox("No Internet Connection. Please check your internet connection and try again.")
        }else{
            //if network connection con
                        dispatch_async(dispatch_get_main_queue()){
                            self.presentInputPinController()
                    }
        }
    }
    
    //Present the input pin view from the table
    func presentInputPinController(){
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("InputPinController") as! InputPinController
        let navController = UINavigationController(rootViewController: detailController) // Creating a navigation controller with detailController at the root of the navigation stack.
        self.navigationController!.presentViewController(navController, animated: true) {
            self.navigationController?.popViewControllerAnimated(true)
            return ()
        }
    }
    
    //Display message re-usable function
    func displayMessageBox(message:String){
        let alert = UIAlertController(title: "Oh no!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
}
