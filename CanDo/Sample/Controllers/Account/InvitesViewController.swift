//
//  InvitesViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 05.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import Moya
import SVProgressHUD
import PullToRefresh

class InvitesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var invitesTableView: UITableView!
    
     var invites = [Invite]()
    
    @IBOutlet weak var startTeamView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.invitesTableView.delegate = self;
        self.invitesTableView.dataSource = self;
        self.invitesTableView.tableFooterView = UIView()
        
        let refresher = PullToRefresh()
        self.invitesTableView.addPullToRefresh(refresher, action: {
            // action to be performed (pull data from some source)
            NSNotificationCenter.defaultCenter().postNotificationName("reloadDataNotification", object: nil)
        })
      
               // Do any additional setup after loading the view.
    }
    deinit {
        self.invitesTableView.removePullToRefresh(self.invitesTableView.topPullToRefresh!)
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
         let invite : Invite = invites[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! InviteTableViewCell
        
        
        cell.nameLabel.text = String(format: "%@ %@", invite.ownerFirstName, invite.ownerLastName)
        cell.acceptButton.tag = indexPath.row
        cell.acceptButton.addTarget(self, action: #selector(self.acceptButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    func reloadInvitesTableView() {
        if invites.count == 0 {
            self.startTeamView.hidden = false
        }
        self.invitesTableView.reloadData()
           self.invitesTableView.endRefreshing(at: .Top)

    }
    
    
    
    
    @IBAction func startTeamTapped(sender: AnyObject) {
        
        
        SVProgressHUD.show()
        provider.request(.CreateTeam()) { result in
            switch result {
            case let .Success(moyaResponse):
                
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let _ = moyaResponse.data.nsdataToJSON() as? [String: AnyObject]
                        else {
                            
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    
                    SVProgressHUD.dismiss()
                    self.hideInvitesView()
                    
                    }
                catch {
                    
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
                        let item = json[0] as? [String: AnyObject],
                        let message = item["message"] as? String else {
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    SVProgressHUD.showErrorWithStatus("\(message)")
                }
                
                
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                SVProgressHUD.showErrorWithStatus("\(error.description)")
                
                
            }
        }
       
    }

    func acceptButtonTapped(sender: UIButton){
        print("accept tapped \(sender.tag)")
         let invite : Invite = invites[sender.tag]
        if invites.count == 1 {
    
        self.runAcceptTeamRequest(invite.teamId)
            
        }else{
            
            let alert = UIAlertController(title: "", message: "You can only join one team at a time. Choose this team?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
                print("OK")
                
            self.runAcceptTeamRequest(invite.teamId)
            
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
                print("Cancel")
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    func runAcceptTeamRequest(teamId:Int){
        
        print("team_id \(teamId)")
        
        SVProgressHUD.show()
        provider.request(.AcceptInvite(teamId: teamId)) { result in
            switch result {
            case let .Success(moyaResponse):
                
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let _ = moyaResponse.data.nsdataToJSON() as? [String: AnyObject]
                        else {
                            
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    
                    SVProgressHUD.dismiss()
                    self.hideInvitesView()
                    
                }
                catch {
                    
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
                        let item = json[0] as? [String: AnyObject],
                        let message = item["message"] as? String else {
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    SVProgressHUD.showErrorWithStatus("\(message)")
                }
                
                
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                SVProgressHUD.showErrorWithStatus("\(error.description)")
                
                
            }
        }

    }
    
    func hideInvitesView() {
        
        if  let parentViewController: AccountViewController = self.parentViewController as? AccountViewController{
            parentViewController.runTeamInfoRequest()
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
