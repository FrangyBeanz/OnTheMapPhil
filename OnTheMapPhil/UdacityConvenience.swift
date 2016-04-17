//
//  UdacityConvenience.swift
//  OnTheMapPhil
//
//  Created by Phillip Hughes on 23/03/2016.
//  Copyright © 2016 Phillip Hughes. All rights reserved.
//  Used parts of spirosrap's GitHub Repo as an example to help with JSON : https://github.com/spirosrap/On-The-Map/blob/master/On%20The%20Map/UdacityConvenience.swift
//

import UIKit
import Foundation

extension UdacityClient {
    
    
//LOGIN
    //Login authentication handler
    func authenticateLogin(vc: LoginViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let networkReachability = Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus()
        
        if(vc.EmailEntry.text != nil && vc.PasswordEntry != nil){
            if(networkStatus.rawValue != NotReachable.rawValue){// Before quering fοr an existing location check if there is an available internet connection
                vc.indicator(true)
                self.getSessionID( vc.EmailEntry.text! , password: vc.PasswordEntry.text!) { result, errorString in
                    if (result != nil) {
                        self.getPublicUserData(self.uniqueKey!)  { account,errorString in
                            if account != nil{
                                completionHandler(success: true, errorString: nil)
                            }
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            vc.indicator(false)
                            completionHandler(success: false, errorString: "Wrong Username/Password")
                        })
                    }
                }
            }else{
                vc.indicator(false)
                completionHandler(success: false, errorString: "No Internet Connection")
            }
        }
    }
    
//GET SESSION ID
    //Gets the Session ID from Udacity API required for Login.
    func getSessionID(username: String,password: String, completionHandler: (result: String?, error: NSError?) -> Void) {
        
        //1. Specify parameters, method (if has {key}), and HTTP body (if POST)
        let mutableMethod : String = Methods.AuthenticationSessionNew
        let udacityBody: [String:AnyObject] = [UdacityClient.JSONBody.Username: username, UdacityClient.JSONBody.Password : password ]
        let jsonBody : [String:AnyObject] = [ UdacityClient.JSONBody.Udacity: udacityBody ]
        
        //2. Make the request
        _ = taskForPOSTMethod(mutableMethod,parse:false, parameters: nil , jsonBody: jsonBody) { JSONResult, error in
            
            //3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Session)?.valueForKey(UdacityClient.JSONResponseKeys.Id) as? String {
                    self.sessionID = results // Setting the session ID
                    if let key = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Account)?.valueForKey(UdacityClient.JSONResponseKeys.Key) as? String{
                        self.uniqueKey = key
                    }
                    completionHandler(result: results, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "postToSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToSession"]))
                }
            }
        }
        
    }
    
//GET PUBLIC USER LOCATIONS
    //Get the public User location data. It doesn't require a session id or any other key.
    func getPublicUserData(uniqueKey: String,completionHandler: (result: Student?, error: String?) -> Void) {
       //1. Specify parameters, method (if has {key}), and HTTP body (if POST)
        let parameters:[String:AnyObject] = [String:AnyObject]()
        let method = Methods.UserData + uniqueKey
       //2. Make the request
        taskForGETMethod(method,parse: false, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let _ = error{
                completionHandler(result: nil, error: "Failed to get User Data")
            } else {
                if let lastname = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.User)?.valueForKey(UdacityClient.JSONResponseKeys.Last_Name) as? String {
                    if let firstname = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.User)?.valueForKey(UdacityClient.JSONResponseKeys.First_Name) as? String {
                        if let uniqueKey = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.User)?.valueForKey(UdacityClient.JSONResponseKeys.Key) as? String {
                            self.account = Student(uniqueKey: uniqueKey, firstName: firstname, lastName: lastname)
                            completionHandler(result: self.account , error: nil)
                        }
                    }
                } else {
                    completionHandler(result: nil, error: "Failed to retrieve User Data")
                }
            }
        }
    }

//GET STUDENT LOCATIONS
    //Get the student locations.
    func getStudentLocations(let limit limit:Int, let skip:Int,completionHandler: (result: [Student]?, error: String?) -> Void){
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters:[String:AnyObject] = [String:AnyObject]()
        parameters["limit"] = limit
        parameters["skip"] = skip
        parameters["order"] = "-updatedAt"
        let method = Methods.StudentLocations + UdacityClient.escapedParameters(parameters)
       //2. Make the request
        taskForGETMethod(method,parse: true, parameters: nil) { JSONResult, error in
            
            //3. Send the desired value(s) to completion handler
            if let _ = error{
                completionHandler(result: nil, error: "Failed to get User Data")
            } else {
                if let results = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Results) as? [[String : AnyObject]] {
                    let students = Student.studentsFromResults(results)
                    
                    if let _ = self.students{
                        self.students! += students
                    }else{
                        self.students = students
                    }
                    
                    completionHandler(result: students , error: nil)
                } else {
                    completionHandler(result: nil, error: "Failed to retrieve User Data")
                }
            }
        }
    }

//POST NEW
    //Post a new Student-Location record.
    func saveAccountLocation(account:Student,completionHandler: (result: Bool?, error: NSError?) -> Void) {
        let method = Methods.StudentLocations
        
        let jsonBody: [String:AnyObject] = [ UdacityClient.JSONBody.uniqueKey: account.uniqueKey,UdacityClient.JSONBody.firstName:account.firstName,UdacityClient.JSONBody.lastName:account.lastName,UdacityClient.JSONBody.mapString:account.mapString!,UdacityClient.JSONBody.mediaURL:account.mediaURL!,UdacityClient.JSONBody.latitude:account.latitude!,UdacityClient.JSONBody.longitude:account.longtitude! ]
        
        //2. Make the request
        _ = taskForPOSTMethod(method, parse: true,parameters: nil , jsonBody: jsonBody) { JSONResult, error in
            
          //3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let _ = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.ObjectID) as? String {
                    completionHandler(result: true, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "saveAccountLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse saveAccountLocation"]))
                }
            }
        }
    }
}
