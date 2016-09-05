//
//  InvitesViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 05.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class InvitesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var invitesTableView: UITableView!
    
     var invites = [String]()
    
    @IBOutlet weak var startTeamView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.invitesTableView.delegate = self;
        self.invitesTableView.dataSource = self;
        self.invitesTableView.tableFooterView = UIView()
        
        for index in 1...3{
           // invites.append(String(format: "Person %d",index))
        }
        
        if invites.count == 0 {
            self.startTeamView.hidden = false
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invites.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let inviteName : String = invites[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! InviteTableViewCell
        
        
        cell.nameLabel.text = inviteName
        cell.acceptButton.tag = indexPath.row
        cell.acceptButton.addTarget(self, action: #selector(self.acceptButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        return cell
    }
    @IBAction func startTeamTapped(sender: AnyObject) {
        
       self.hideInvitesView()
    }

    func acceptButtonTapped(sender: UIButton){
        print("accept tapped \(sender.tag)")
        if invites.count == 1 {
        
         self.hideInvitesView()
            
        }else{
            
            let alert = UIAlertController(title: "", message: "You can only join one team at a time. Choose this team?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
                print("OK")
                
            self.hideInvitesView()
            
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
                print("Cancel")
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    func hideInvitesView() {
        if  let parentViewController: AccountViewController = self.parentViewController as? AccountViewController{
            parentViewController.updateContainerViews(false,showTeam:true)
        }

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
