//
//  MapViewController.swift
//  OnTheMapPhil
//
//  Created by Phillip Hughes on 29/03/2016.
//  Copyright © 2016 Phillip Hughes. All rights reserved.
//  Some code from this swift class has been leveraged from Udacity's "Pin Sample" App
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController,MKMapViewDelegate {
    
    var location: CLLocation!
    var DefaultLat = 51.9080387
    var DefaultLong = -2.0772528
    
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
    
    @IBAction func PinButton(sender: AnyObject) {
    }
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var LogoutButton: UIBarButtonItem!
    var annotations = [MKPointAnnotation]()
    var count = 0
    
    //MARK: Get Next Results
    //Whenever it is called it retrieves the next batch of 100 records with the help of global variable count
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
    
    //Get more results in a network considerate fashion
    func moreLocations(){
        getNextResults()
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
        
        LogoutButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "logout")
        
        // The "locations" array is an array of dictionary objects that are similar to the JSON
        // data that you can download from parse.
        
        //commenting out hard coded solution
  //     let locations = hardCodedLocationData()
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
   //     for dictionary in locations {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
  //          let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
  //          let long = CLLocationDegrees(dictionary["longitude"] as! Double)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
  //          let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
  //          let first = dictionary["firstName"] as! String
  //          let last = dictionary["lastName"] as! String
  //         let mediaURL = dictionary["mediaURL"] as! String
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
  //          let annotation = MKPointAnnotation()
    //        annotation.coordinate = coordinate
      //      annotation.title = "\(first) \(last)"
        //    annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
    //        annotations.append(annotation)
      //  }
        
        // When the array is complete, we add the annotations to the map.
    //    self.mapView.addAnnotations(annotations)
        
   // }
        
   
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
//    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        if control == view.rightCalloutAccessoryView {
  //          let app = UIApplication.sharedApplication()
    //        if let toOpen = view.annotation?.subtitle! {
      //          app.openURL(NSURL(string: toOpen)!)
        //    }
   //     }
    //}
    //    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    //
    //        if control == annotationView.rightCalloutAccessoryView {
    //            let app = UIApplication.sharedApplication()
    //            app.openURL(NSURL(string: annotationView.annotation.subtitle))
    //        }
    //    }
    
    // MARK: - Sample Data
    
    // Some sample data. This is a dictionary that is more or less similar to the
    // JSON data that you will download from Parse.
    
//    func hardCodedLocationData() -> [[String : AnyObject]] {
  //      return  [
    //        [
      //          "createdAt" : "2015-02-24T22:27:14.456Z",
        //        "firstName" : "Jessica",
          //      "lastName" : "Uelmen",
            //    "latitude" : 28.1461248,
              //  "longitude" : -82.75676799999999,
                //"mapString" : "Tarpon Springs, FL",
//                "mediaURL" : "www.linkedin.com/in/jessicauelmen/en",
  //              "objectId" : "kj18GEaWD8",
    //            "uniqueKey" : 872458750,
      //          "updatedAt" : "2015-03-09T22:07:09.593Z"
        //    ], [
          //      "createdAt" : "2015-02-24T22:35:30.639Z",
            //    "firstName" : "Gabrielle",
              //  "lastName" : "Miller-Messner",
        //        "latitude" : 35.1740471,
          //      "longitude" : -79.3922539,
            //    "mapString" : "Southern Pines, NC",
              //  "mediaURL" : "http://www.linkedin.com/pub/gabrielle-miller-messner/11/557/60/en",
                //"objectId" : "8ZEuHF5uX8",
//                "uniqueKey" : 2256298598,
  //              "updatedAt" : "2015-03-11T03:23:49.582Z"
    //        ], [
      //          "createdAt" : "2015-02-24T22:30:54.442Z",
        //        "firstName" : "Jason",
          //      "lastName" : "Schatz",
            //    "latitude" : 37.7617,
              //  "longitude" : -122.4216,
//                "mapString" : "18th and Valencia, San Francisco, CA",
  //              "mediaURL" : "http://en.wikipedia.org/wiki/Swift_%28programming_language%29",
    //            "objectId" : "hiz0vOTmrL",
      //          "uniqueKey" : 2362758535,
        //        "updatedAt" : "2015-03-10T17:20:31.828Z"
          //  ], [
            //    "createdAt" : "2015-03-11T02:48:18.321Z",
              //  "firstName" : "Jarrod",
                //"lastName" : "Parkes",
//                "latitude" : 34.73037,
  //              "longitude" : -86.58611000000001,
    //            "mapString" : "Huntsville, Alabama",
      //          "mediaURL" : "https://linkedin.com/in/jarrodparkes",
        //        "objectId" : "CDHfAy8sdp",
          //      "uniqueKey" : 996618664,
            //    "updatedAt" : "2015-03-13T03:37:58.389Z"
//            ]
  //      ]
        
        
        getNextResults()
        
    }
    
 
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
