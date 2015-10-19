//
//  TwitterAuthViewController.swift
//  LMGaugeView-Fire
//
//  Created by deast on 8/17/15.
//  Copyright (c) 2015 davideast. All rights reserved.
//

import Foundation
import UIKit

@objc protocol TwitterAuthProtocol {
  func twitterLogin(error: NSError!, authData: FAuthData!)
  optional func twitterLogin(error: NSError!)
}

class TwitterAuthViewController: UIViewController, TwitterAuthProtocol {
  
  var ref: Firebase!
  var apiKey: String!
  var delegate: TwitterAuthProtocol!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    delegate = self
    readFromPlist()
  }
  
  private func readFromPlist() {
    var myDict: NSDictionary?
    if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist") {
      myDict = NSDictionary(contentsOfFile: path)
    }
    if let dict = myDict {
      let firebaseName = dict.objectForKey("FirebaseName") as! String
      let twitterApiKey = dict.objectForKey("TwitterApiKey") as! String
      ref = Firebase(url: "https://\(firebaseName).firebaseio.com/")
      apiKey = twitterApiKey
    }
  }
  
  func login() {
    
    assert(ref != nil, "The property ref is not initialized.")
    assert(apiKey != nil, "The property apiKey is not defined.")

    let twitterAuthHelper = TwitterAuthHelper(firebaseRef: ref, apiKey:apiKey)
    twitterAuthHelper.selectTwitterAccountWithCallback { error, accounts in
      if error != nil {
        // Error retrieving Twitter accounts
        self.delegate.twitterLogin?(error)
      } else if accounts.count >= 1 {
        // Select an account. Here we pick the first one for simplicity
        let account = accounts[0] as? ACAccount
        twitterAuthHelper.authenticateAccount(account, withCallback: { (error, authData) in
          self.delegate.twitterLogin(error, authData: authData)
        })
      }
    }
    
    
  }
  
  func twitterLogin(error: NSError!) {
    
  }
  
  func twitterLogin(error: NSError!, authData: FAuthData!) {
    
  }
  
}