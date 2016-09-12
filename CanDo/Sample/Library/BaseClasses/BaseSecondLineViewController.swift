//
//  BaseSecondLineViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 12.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class BaseSecondLineViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "iconChevronRightWhite-1"), forState: .Normal)
        backButton.frame = CGRectMake(0, 0, 11, 16)
        backButton.addTarget(self, action: #selector(self.backButtonTapped(_:)), forControlEvents: .TouchUpInside)
        let fixedSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        fixedSpace.width = 5.0
        navigationItem.leftBarButtonItems = [fixedSpace, UIBarButtonItem(customView: backButton)]

        // Do any additional setup after loading the view.
    }
    func backButtonTapped(sender: AnyObject) {
       self.navigationController!.popViewControllerAnimated(true)
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
