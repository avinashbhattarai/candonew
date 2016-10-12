//
//  BaseViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 12.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIButton()
        backButton.setImage(UIImage(named: "iconChevronRightWhite-1"), for: UIControlState())
        backButton.frame = CGRect(x: 0, y: 0, width: 11, height: 16)
        backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        let fixedSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        fixedSpace.width = 5.0
        navigationItem.leftBarButtonItems = [fixedSpace, UIBarButtonItem(customView: backButton)]
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func backButtonTapped(_ sender: AnyObject) {
        let nc = (self.tabBarController?.navigationController)! as UINavigationController
        nc.popViewController(animated: true)
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
