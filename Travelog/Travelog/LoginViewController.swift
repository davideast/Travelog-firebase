//
//  LoginViewController.swift
//  Travelog
//
//  Created by deast on 10/18/15.
//  Copyright © 2015 www.razeware.com. All rights reserved.
//

import UIKit

class LoginViewController: TwitterAuthViewController {
  
  @IBAction func loginDidTouch(sender: UIButton) {
    login()
  }
  
  override func twitterLogin(error: NSError!, authData: FAuthData!) {
    performSegueWithIdentifier("LoginToList", sender: nil)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    guard segue.identifier == "LoginToList" else { return }
    
    // Navigation Voodoo
    let vc = segue.destinationViewController as! SplitViewController
    let navVc = vc.viewControllers.first as! UINavigationController
    let logsVc = navVc.viewControllers.first as! LogsViewController
    
    logsVc.user = User(uid: ref.authData.uid)
  }
  
  
}
