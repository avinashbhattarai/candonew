//
//  TodoViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class TodoViewController: UIViewController {
    
    
    var selectedIndex: NSInteger?

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
         let backButton = UIButton()
        backButton.setImage(UIImage(named: "iconChevronRightWhite-1"), forState: .Normal)
        backButton.frame = CGRectMake(0, 0, 11, 16)
        backButton.addTarget(self, action: #selector(TodoViewController.backButtonTapped(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: backButton), animated: true);
        
        self.tabBarController?.selectedIndex = selectedIndex!
        
      
    }
    
    func backButtonTapped(sender: AnyObject) {
        let nc = (self.tabBarController?.navigationController)! as UINavigationController
        nc.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func suggestionButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier(Helper.SegueKey.kToSuggestionsViewController, sender: self)
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
