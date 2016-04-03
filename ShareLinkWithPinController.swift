//
//  ShareLinkWithPin.swift
//  OnTheMapPhil
//
//  Created by Phillip Hughes on 03/04/2016.
//  Copyright © 2016 Phillip Hughes. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ShareLinkWithPinController: UIViewController {
    @IBAction func CancelButton(sender: UIBarButtonItem) {
        cancel()
    }
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var shareLink: UITextField!
    var tapRecognizer: UITapGestureRecognizer? = nil
    var placeMark: MKPlacemark? = nil
    var locationString: String? = nil
   
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        indicator.hidden = true
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        submitButton.backgroundColor = UIColor.whiteColor()
        submitButton.alpha = 0.8
        shareLink.text = "Enter a Link to Share Here"
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel")
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Browse", style: .Plain, target: self, action: "browse")
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        
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
        
        if let address = locationString{
            var geocoder = CLGeocoder()
            geoCodingStarted()
            geocoder.geocodeAddressString(address, completionHandler: { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                if let error = error {
                    var alert = UIAlertController(title: "", message: "Geocoding failed", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: self.cancel))
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
                        self.geoCodingStoped()
            })
        }
    }
    
    //MARK: BUtton Actions
    //Browse for a URL.
    func browse(){
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("ShareLinkWithPinController") as! ShareLinkWithPinController
        self.navigationController?.pushViewController(detailController, animated: true)
    }
    
    func cancel(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Cancel action from an Alert view
    func cancel(action:UIAlertAction! ){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Check for a valid URL
    func checkURL(str:String) -> Bool{
        if (str.characters.count < 7){
            return false
        }else{
            return str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(0), end: str.startIndex.advancedBy(7))) == "http://"
        }
    }
    
    //Submit the Location and link.
    @IBAction func submitAction(sender: UIButton) {
        var networkReachability = Reachability.reachabilityForInternetConnection()
        var networkStatus = networkReachability.currentReachabilityStatus()
        if (networkStatus.rawValue == NotReachable.rawValue) {// Before quering for an existing location check if there is an available internet connection
            displayMessageBox("No Network Connection")
        } else {
            if shareLink.text ==  "Enter a Link to Share Here" || !checkURL(shareLink.text!){
                displayMessageBox("You should enter a Valid URL")
            }else{
                if placeMark == nil{
                    displayMessageBox("We didn't find any location. Try Again")
                }else{
                    //Set the Account's next retrieved fields (First Name,Last Name was already retrieved from loging in)
                    UdacityClient.sharedInstance().account?.mapString = locationString
                    UdacityClient.sharedInstance().account?.mediaURL = shareLink.text
                    UdacityClient.sharedInstance().account?.latitude = placeMark!.coordinate.latitude
                    UdacityClient.sharedInstance().account?.longtitude = placeMark!.coordinate.longitude
                    
                    var objectID = UdacityClient.sharedInstance().account?.objectId //Get the objectId to update the record
                    if let oid = UdacityClient.sharedInstance().account?.objectId {
                        UdacityClient.sharedInstance().updateAccountLocation(UdacityClient.sharedInstance().account!){ result,error in
                            if error != nil{
                                dispatch_async(dispatch_get_main_queue(),{
                                    self.displayMessageBox("Could not update Location")
                                })
                            }else if let r = result {
                                if r {
                                    dispatch_async(dispatch_get_main_queue(),{
                                        var alert = UIAlertController(title: "", message: "Location updated", preferredStyle: UIAlertControllerStyle.Alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: self.cancel))
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    })
                                }else{
                                    dispatch_async(dispatch_get_main_queue(),{
                                        self.displayMessageBox("Could not save Location")
                                    })
                                }
                            }
                        }
                    }else{ //If the record was not present create a new record.
                        UdacityClient.sharedInstance().saveAccountLocation(UdacityClient.sharedInstance().account!){ result,error in
                            if error != nil{
                                dispatch_async(dispatch_get_main_queue(),{
                                    self.displayMessageBox("Could not save Location")
                                })
                            }else if let r = result {
                                if r {
                                    dispatch_async(dispatch_get_main_queue(),{
                                        var alert = UIAlertController(title: "", message: "Location Saved", preferredStyle: UIAlertControllerStyle.Alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: self.cancel))
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
        }
    }
    
    func geoCodingStarted(){
        indicator.startAnimating()
    }
    
    // Start showing Activity indicator and the black transparent image view
    func geoCodingStoped(){
        indicator.stopAnimating()
    }
    
    
    //Displays a basic alert box with the OK button and a message.
    func displayMessageBox(message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
