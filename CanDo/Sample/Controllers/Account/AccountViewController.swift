//
//  AccountViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "iconChevronRightWhite-1"), forState: .Normal)
        backButton.frame = CGRectMake(0, 0, 11, 16)
        backButton.addTarget(self, action: #selector(AccountViewController.backButtonTapped(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: backButton), animated: true);
       

    }
    func backButtonTapped(sender: AnyObject) {
        let nc = (self.tabBarController?.navigationController)! as UINavigationController
        nc.popViewControllerAnimated(true)
    }

    @IBAction func logoutButtonTapped(sender: AnyObject) {
        
        cleanUserDefaults()
        
        self.performSegueWithIdentifier("unwindToSignUpViewController", sender: self)
        
        
        
    }
    
    func cleanUserDefaults() {
        
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserEmail)
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserFirstName)
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserId)
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserLastName)
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserSecretCode)
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserToken)
        
        Helper.UserDefaults.kStandardUserDefaults.synchronize()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
