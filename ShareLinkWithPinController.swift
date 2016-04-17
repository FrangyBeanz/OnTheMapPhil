//
//  ShareLinkWithPin.swift
//  OnTheMapPhil
//
//  Created by Phillip Hughes on 03/04/2016.
//  Copyright © 2016 Phillip Hughes. All rights reserved.
//  Valid URL Check assistance from Stack Overflow: http://stackoverflow.com/questions/32229697/check-if-valid-url-webview-swift
//  Geolocation assistance from rshankar: http://rshankar.com/get-your-current-address-in-swift/


import Foundation
import UIKit
import MapKit

class ShareLinkWithPinController: UIViewController {
    static var errors: [NSError] = []
    @IBAction func CancelButton(sender: UIBarButtonItem) {
        cancel()
    }
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var shareLink: UITextField!
    var tapRecognizer: UITapGestureRecognizer? = nil
    var placeMark: MKPlacemark? = nil
    var locationString: String?
    var navController: UINavigationController?
    var window: UIWindow?
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        indicator.hidden = true
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.removeKeyboardDismissRecognizer()
    }
    
    
    // MARK: - Keyboard Fixes
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    //Action to dismiss the keyboard when a tap was performed outside the text view
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.addKeyboardDismissRecognizer()
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        if let sl = applicationDelegate.shareLink{
            shareLink.text = sl
        }
        
        //The geocoding
        self.indicator.hidden = false
        self.indicator.startAnimating()
        if let address = locationString{
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address, completionHandler: { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                if let _ = error {
                    let alert = UIAlertController(title: "", message: "Sorry, we can't find that location. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Go Back", style: UIAlertActionStyle.Default, handler: self.geocodeFailAlert))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    if let placemark = placemarks?[0] {
                        self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                        self.placeMark = MKPlacemark(placemark: placemark)
                        //Center the map
                        let p = MKPlacemark(placemark: placemark)
                        let span = MKCoordinateSpanMake(5, 5)
                        let region = MKCoordinateRegion(center: p.location!.coordinate, span: span)
                        self.mapView.setRegion(region, animated: true)
                        self.indicator.startAnimating()
                    }
                }
                self.indicator.stopAnimating()
                self.indicator.hidden = true
            })
        }
    }
    
    //Browse for a URL.
    func browse(){
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("ShareLinkWithPinController") as! ShareLinkWithPinController
        self.navigationController?.pushViewController(detailController, animated: true)
    }
    
    
    //Return to the Map screen on cancel click
    func cancel(){
        let MapController =
        self.storyboard!.instantiateViewControllerWithIdentifier("AppTabBarController")
        self.presentViewController(MapController, animated: true) {
            self.navigationController?.popViewControllerAnimated(true)
            return ()
        }
    }
    
    // Cancel action from an Alert view
    func geocodeFailAlert(action:UIAlertAction! )
            {
                let MapController =
                self.storyboard!.instantiateViewControllerWithIdentifier("InputPinControllerNav")
                self.presentViewController(MapController, animated: true) {
                    self.navigationController?.popViewControllerAnimated(true)
                    return ()
                }
    }
    
   
    // Cancel action from an Alert view
    func Back2Map(action:UIAlertAction! ){
        //since this is an error message, the user is sent to the previous screen
        let MapController =
        self.storyboard!.instantiateViewControllerWithIdentifier("AppTabBarController")
        self.presentViewController(MapController, animated: true) {
            self.navigationController?.popViewControllerAnimated(true)
            return ()
        }
    }
    
    //Before submitting a link, check to see if it can be opened
    func checkURL (str:String) -> Bool{
        var canOpen = false
        if let url = NSURL(string: str) {
            //canOpenURL will return a bool value
            canOpen = UIApplication.sharedApplication().canOpenURL(url)
    }
        return canOpen
    }
    
    
    //Submit the Location and link.
    @IBAction func submitAction(sender: UIButton) {
        let networkReachability = Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus()
        if (networkStatus.rawValue == NotReachable.rawValue) {// Before quering for an existing location check if there is an available internet connection
            displayMessageBox("No Internet Connection")
        } else {
            if shareLink.text ==  "Enter your link here!" || !checkURL(shareLink.text!){
                displayMessageBox("Please enter a valid URL")
            }else{
                if placeMark == nil{
                    displayMessageBox("Can't find that location... please try again")
                }else{
                    //Set the Account's next retrieved fields (First Name,Last Name was already retrieved from loging in)
                    UdacityClient.sharedInstance().account?.mapString = locationString
                    UdacityClient.sharedInstance().account?.mediaURL = shareLink.text
                    UdacityClient.sharedInstance().account?.latitude = placeMark!.coordinate.latitude
                    UdacityClient.sharedInstance().account?.longtitude = placeMark!.coordinate.longitude
                    }
                       UdacityClient.sharedInstance().saveAccountLocation(UdacityClient.sharedInstance().account!){ result,error in
                            if error != nil{
                                dispatch_async(dispatch_get_main_queue(),{
                                    self.displayMessageBox("Could not save Location")
                                })
                            }else if let r = result {
                                if r {
                                    dispatch_async(dispatch_get_main_queue(),{
                                        let alert = UIAlertController(title: "Yeah!", message: "Location Saved Successfully!", preferredStyle: UIAlertControllerStyle.Alert)
                                        alert.addAction(UIAlertAction(title: "Show me on the map!", style: UIAlertActionStyle.Default, handler: self.Back2Map))
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    })
                                }else{
                                    dispatch_async(dispatch_get_main_queue(),{
                                        self.displayMessageBox("Could not save Location")
                                    })
                                }
                    }
                }
            }
        }
    }
    
    //Displays a basic alert box for errors
    func displayMessageBox(message:String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil) )
        self.presentViewController(alert, animated: true, completion: nil)
    
     }
    
}
