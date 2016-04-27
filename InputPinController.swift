//
//  InputPinController.swift
//  OnTheMapPhil
//
//  Created by Phillip Hughes on 02/04/2016.
//  Copyright © 2016 Phillip Hughes. All rights reserved.
//

import Foundation
import UIKit
import MapKit
class InputPinController: UIViewController {
    
    //Keyboard variable to make sure the keyboard remains hidden when not in use
    var keyboardHidden = true
    var tapRecognizer: UITapGestureRecognizer? = nil
    @IBOutlet weak var locationString: UITextField?          // The String location for geocoding
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet var findButton: UIButton!
    @IBAction func cancelButton(sender: AnyObject) {
        cancel()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Location Entry"
        indicator.hidden = true
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        subscribeToKeyboardNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        //self.removeKeyboardDismissRecognizer()
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
      self.addKeyboardDismissRecognizer()
    }
    
    // KEYBOARD KIXES
        
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
    
    //--------------KEYBOARD - subscibe to notifications-----------------------//
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    //Move the view frame up when the keyboard is called
    func keyboardWillShow(notification: NSNotification) {
        if(keyboardHidden ){
            view.frame.origin.y -= getKeyboardHeight(notification)
            keyboardHidden = false
        }
    }
    //Move the view frame down when the keyboard is dismissed
    func keyboardWillHide(notification: NSNotification) {
        if(!keyboardHidden){
            view.frame.origin.y += getKeyboardHeight(notification)
            keyboardHidden = true
        }
    }
    
    //After the enter is pressed at we dismiss the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.isEqual(locationString){
            unsubscribeFromKeyboardNotifications()
        }
        return true
    }
    
    
    
    //Pass the location string to the next page so that we can incorportate the link
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let _ = segue.identifier {
           let detailController = segue.destinationViewController as! ShareLinkWithPinController
           detailController.locationString = locationString!.text
            
       }
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
}
