//
//  MapViewController.swift
//  OnTheMapPhil
//
//  Created by Phillip Hughes on 29/03/2016.
//  Copyright © 2016 Phillip Hughes. All rights reserved.
//  Some code from this swift class has been leveraged from Udacity's "Pin Sample" App
//  Refresh button assistance from this thread on Stack Overflow: http://stackoverflow.com/questions/33187177/map-button-refresh-location
//  Pin Colour assistance from http://stackoverflow.com/questions/32815367/change-color-pin-ios-9-mapkit 
//  Icons used are from Icon 8's Free iOS icons package: https://icons8.com/
//  Udacity API Reference https://docs.google.com/document/d/1MECZgeASBDYrbBg7RlRu9zBBLGd3_kfzsN-0FtURqn0/pub?embedded=true#h.e1bka73gla8u


import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController,MKMapViewDelegate {
    
    var location: CLLocation!
    var DefaultLat = 51.9080387
    var DefaultLong = -2.0772528
    var update = false
    @IBOutlet var mapView: MKMapView!
    var annotations = [MKPointAnnotation]()
    var count = 0
    
    @IBAction func PinButton(sender: UIBarButtonItem) {
    }
    
    //Refresh button to reset the view to the default and refresh the pins
    @IBAction func RefreshButton(sender: AnyObject) {
        let location = CLLocationCoordinate2D(
            latitude: DefaultLat,
            longitude: DefaultLong
            )
        let span = MKCoordinateSpanMake(80, 80)
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
        self.reload()
    }
    
    //when we click the logout button, invalidate the sessions and return to the login screen
    @IBAction func LogoutButton(sender: UIBarButtonItem) {
        let udacitySession = UdacityClient()
        udacitySession.sessionID = "nil"
        UdacityClient.sharedInstance().account = nil
        UdacityClient.sharedInstance().students = nil

                let LogoutAction =
                self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                self.presentViewController(LogoutAction, animated: true)
                    {
                        self.navigationController?.popViewControllerAnimated(true)
                        return ()
                }
        
    }
    
    //Retrieve the next set of records in batches of 100
        func getNextResults(){
        UdacityClient.sharedInstance().getStudentLocations(limit: 100,skip: count){result, errorString in
            if let _ = errorString {
                self.displayMessageBox("Could not download results")
            } else{
                dispatch_async(dispatch_get_main_queue(), {
                    if (result != nil) {
                        self.count += result!.count
                        self.addAnnotations(result!)
                   }
                    return
                })
            }
        }
    }
    
    
    //Displays a basic alert box with the OK button and a message.
    func displayMessageBox(message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Adding annotations from a Students array of Structs
    func addAnnotations(let students:[Student]){
        for s in students{
            let location = CLLocationCoordinate2D(
                latitude: s.latitude!,
                longitude: s.longtitude!
            )
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = s.firstName + " " + s.lastName
            annotation.subtitle = s.mediaURL
            self.annotations += [annotation]
            self.mapView.addAnnotation(annotation)
        }
    }
    

    //Reload all data
    func reload(){
        let networkReachability = Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus()
        if (networkStatus.rawValue == NotReachable.rawValue) {
            displayMessageBox("No Network Connection")
        }else{
            // If the reload was pressed all the data will be reloaded and the array of student's should be nullified
            count = 0
            self.mapView.removeAnnotations(annotations) //Also remove all the annotations.
            annotations = []
            UdacityClient.sharedInstance().students = nil
            getNextResults()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        getNextResults()
        
    }
    
    //Before opening a link, check to see if it can be opened
    func checkURL (str:String) -> Bool{
        var canOpen = false
        if let url = NSURL(string: str) {
            //canOpenURL will return a bool value
            canOpen = UIApplication.sharedApplication().canOpenURL(url)
        }
        return canOpen
    }
    //Function to include the information icon on the annotation view, and open it in the web browser. 
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView && checkURL(annotationView.annotation!.subtitle!!) //Check the URL from the student record is good before attempting to open it
            {
            let request = NSURLRequest(URL: NSURL(string: annotationView.annotation!.subtitle!!)!)
            UIApplication.sharedApplication().openURL(request.URL!)
            
        }else{
            displayMessageBox("Bad URL")
        }
    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinTintColor = UIColor.orangeColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //BUGFIX Ensure that we clear all previous pins when the view re-appears!
        count = 0
        self.mapView.removeAnnotations(annotations) //Also remove all the annotations.
        annotations = []
        UdacityClient.sharedInstance().students = nil
        let networkReachability = Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus()
        if (networkStatus.rawValue == NotReachable.rawValue) {
            displayMessageBox("No Network Connection")
        }else{
            if let _ = UdacityClient.sharedInstance().students{
                self.mapView.removeAnnotations(annotations) //Also remove all the annotations.
                annotations = []
                self.addAnnotations(UdacityClient.sharedInstance().students!)

            }
        }

    }
    
}
