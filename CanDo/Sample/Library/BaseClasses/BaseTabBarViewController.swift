//
//  BaseTabBarViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class BaseTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
         // UITabBar.appearance().tintColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.green], for: UIControlState())
        
        for item in self.tabBar.items! as [UITabBarItem] {
            
            if let image = item.image {
                item.image = image.imageWithColor(UIColor.white).withRenderingMode(.alwaysOriginal)
            }
        }

        
        
        // Do any additional setup after loading the view.
        //test
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
