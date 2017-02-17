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
        
         self.view.layer.insertSublayer(generateGradientForFrame(self.view.frame), at: 0)
        
      
        fadeViewIn(helloLabel, delay: 1.0)
        
        let isUserGroupOwner = Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kIsUserGroupOwner) as? Bool ?? false
        if isUserGroupOwner {
            helloLabel.text = "Hi \(Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kUserFirstName)!),\nhow can we help today?"
        }else{
            helloLabel.text = "Hi \(Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kUserFirstName)!),\nhow can you help today?"
        }
        
        
        dashboardTableView.delegate = self;
        dashboardTableView.dataSource = self;
        dashboardTableView.alwaysBounceVertical = false
        dashboardTableView.register(DashboardTableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
     
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fadeViewIn(_ view : UIView, delay: TimeInterval) {
        
        let animationDuration = 2.0
        
        // Fade out the view after a delay
        
        UIView.animate(withDuration: animationDuration, delay: delay, options: UIViewAnimationOptions(), animations: { () -> Void in
            view.alpha = 1
            },
                                   completion: nil)
        
    }

    func generateGradientForFrame(_ frame: CGRect) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor(red: 194/255.0, green: 128/255.0, blue: 255/255.0, alpha: 1.0).cgColor, UIColor(red: 72/255.0, green: 106/255.0, blue: 249/255.0, alpha: 1.0).cgColor]
        
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = frame
        
        
        return gradient
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        
       let cell:DashboardTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DashboardTableViewCell
            
            cell.textLabel?.text = titles[(indexPath as NSIndexPath).row]
              cell.backgroundColor = UIColor.clear;
            cell.imageView?.image = UIImage(named: imgNames[(indexPath as NSIndexPath).row])
            cell.selectionStyle = .none
            var imageView : UIImageView
            imageView  = UIImageView(frame:CGRect(x: 0, y: 0, width: 14, height: 20))
            imageView.image = UIImage(named:"iconChevronRightWhite")
        
            // then set it as cellAccessoryType
            cell.accessoryView = imageView
            return cell
    
   
    }

     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         print("You selected cell #\((indexPath as NSIndexPath).row)!")
        
      
        
        
        performSegue(withIdentifier: Helper.SegueKey.kToTodoViewController, sender: self)
    }
    
    // if tableView is set in attribute inspector with selection to multiple Selection it should work.
    
    // Just set it back in deselect
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toTodoViewController" {
            let tabbarController:UITabBarController = segue.destination as! UITabBarController
            let navigationController = tabbarController.viewControllers?.first as! UINavigationController
            let viewController = navigationController.topViewController as! TodoViewController
            let indexPath = dashboardTableView.indexPathForSelectedRow!
            viewController.selectedIndex = (indexPath as NSIndexPath).row
            
        }
    }
    

}
