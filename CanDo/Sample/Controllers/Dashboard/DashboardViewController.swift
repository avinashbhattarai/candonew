//
//  DashboardViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 17.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var dashboardTableView: UITableView!
    @IBOutlet weak var helloLabel: UILabel!
    
    var titles: [String] =  ["To Do", "Calendar", "Notifications", "Team", "Tips"]
    var imgNames: [String] =  ["iconMenuHelp", "iconMenuCalendar", "iconMenuNotifications", "iconMenuTeam", "iconMenuTips"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
         self.view.layer.insertSublayer(generateGradientForFrame(self.view.frame), atIndex: 0)
        
        self.helloLabel.alpha = 0;
        fadeViewInThenOut(self.helloLabel, delay: 0.5)
        
        self.dashboardTableView.delegate = self;
        self.dashboardTableView.dataSource = self;
        self.dashboardTableView.alwaysBounceVertical = false
        self.dashboardTableView.registerClass(DashboardTableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    
   
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
     
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fadeViewInThenOut(view : UIView, delay: NSTimeInterval) {
        
        let animationDuration = 1.0
        
        // Fade out the view after a delay
        
        UIView.animateWithDuration(animationDuration, delay: delay, options: .CurveEaseInOut, animations: { () -> Void in
            view.alpha = 1
            },
                                   completion: nil)
        
    }

    func generateGradientForFrame(frame: CGRect) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor(red: 194/255.0, green: 128/255.0, blue: 255/255.0, alpha: 1.0).CGColor, UIColor(red: 72/255.0, green: 106/255.0, blue: 249/255.0, alpha: 1.0).CGColor]
        
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = frame
        
        
        return gradient
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
        
       let cell:DashboardTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! DashboardTableViewCell
            
            cell.textLabel?.text = titles[indexPath.row]
              cell.backgroundColor = UIColor.clearColor();
            cell.imageView?.image = UIImage(named: imgNames[indexPath.row])
      
            var imageView : UIImageView
            imageView  = UIImageView(frame:CGRectMake(0, 0, 14, 20))
            imageView.image = UIImage(named:"iconChevronRightWhite")
        
            // then set it as cellAccessoryType
            cell.accessoryView = imageView
            return cell
    
   
    }

     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         print("You selected cell #\(indexPath.row)!")
        
      
        
        
        performSegueWithIdentifier("toTodoViewController", sender: self)
    }
    
    // if tableView is set in attribute inspector with selection to multiple Selection it should work.
    
    // Just set it back in deselect
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toTodoViewController" {
            let tabbarController:UITabBarController = segue.destinationViewController as! UITabBarController
            let navigationController = tabbarController.viewControllers?.first as! UINavigationController
            let viewController = navigationController.topViewController as! TodoViewController
            let indexPath = self.dashboardTableView.indexPathForSelectedRow!
            viewController.selectedIndex = indexPath.row
            
        }
    }
    

}
