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
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    @IBOutlet weak var locationString: UITextField?          // The String location for geocoding
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBAction func CancelButton(sender: UIBarButtonItem) {
        cancel()
    }
    @IBOutlet var findButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   
        indicator.hidden = true
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.removeKeyboardDismissRecognizer()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.addKeyboardDismissRecognizer()
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
    //MARK: -
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let _ = segue.identifier {
           let detailController = segue.destinationViewController as! ShareLinkWithPinController
           detailController.locationString = locationString!.text
            print(locationString)
       }
    }
    
    //Cancel button function to return to previous screen
    func cancel(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

