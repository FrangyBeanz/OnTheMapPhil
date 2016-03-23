//
//  LoginViewController.swift
//  OnTheMapPhil
//
//  Created by Phillip Hughes on 23/03/2016.
//  Copyright © 2016 Phillip Hughes. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UINavigationControllerDelegate {


    @IBOutlet weak var EmailEntry: UITextField!
    @IBOutlet weak var PasswordEntry: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var LoginActivityIndicator: UIActivityIndicatorView!
    var tapOutsideTextbox: UITapGestureRecognizer? = nil
    
        override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
            
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
}

