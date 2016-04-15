//
//  LoginViewController.swift
//  OnTheMapPhil
//
//  Created by Phillip Hughes on 23/03/2016.
//  Copyright © 2016 Phillip Hughes. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UINavigationControllerDelegate {


    @IBOutlet weak var CredsErrorMEssage: UILabel!
    @IBOutlet weak var EmailEntry: UITextField!
    @IBOutlet weak var PasswordEntry: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var LoginActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ConnectionErrorMessage: UILabel!
    var tapOutsideTextbox: UITapGestureRecognizer? = nil

    
    
        override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
            LoginActivityIndicator.hidden = true
            ConnectionErrorMessage.hidden = true
            CredsErrorMEssage.hidden = true
            tapOutsideTextbox = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
            tapOutsideTextbox?.numberOfTapsRequired = 1
            
           }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(animated: Bool) {
        
        //Dismiss the keyboard when the user taps outside the keyboard.
        self.addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.removeKeyboardDismissRecognizer()
    }
    
    // functions for keyboard recognizers
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapOutsideTextbox!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapOutsideTextbox!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    //When we click the login button
    @IBAction func LoginButton(sender: AnyObject) {
        self.LoginActivityIndicator.hidden = false
        
        //Hide error messages if they were already thee
        self.CredsErrorMEssage.hidden = true
        self.ConnectionErrorMessage.hidden = true
        
        self.indicator(true)
        self.view.endEditing(true)
        UdacityClient.sharedInstance().authenticateBasicLoginWithViewController(self) { (success, errorString) in
            if success {
                self.completeLogin()
            } else {
                self.CredsErrorMEssage.hidden = false
                self.LoginActivityIndicator.hidden = true
            }
        }
    }

    //Displays the loading indicator
    func indicator(animate:Bool){
        if(animate){

            LoginActivityIndicator.startAnimating()
        }else{
            LoginActivityIndicator.stopAnimating()
        }
    }
    
    
    func completeLogin(){ // prepares the display of the next view
        
        dispatch_async(dispatch_get_main_queue(), {
           let detailController =
               self.storyboard!.instantiateViewControllerWithIdentifier("AppTabBarController") as! UITabBarController
                self.presentViewController(detailController, animated: true) {
                self.navigationController?.popViewControllerAnimated(true)
                return ()
            }
        })
        indicator(false)
        LoginActivityIndicator.hidden = true
    }
    
    //Displays an error message if the connection failed
    func displayMessage(message:String){
        ConnectionErrorMessage.hidden = true
        LoginActivityIndicator.hidden = true
    }
}

