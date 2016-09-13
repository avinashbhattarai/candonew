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
import ESPullToRefresh

class InvitesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var invitesTableView: UITableView!
    
     var invites = [Invite]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        invitesTableView.delegate = self;
        invitesTableView.dataSource = self;
        invitesTableView.tableFooterView = UIView()
        invitesTableView.emptyDataSetSource = self;
        invitesTableView.emptyDataSetDelegate = self;
        
        
        
        invitesTableView.es_addPullToRefresh {
            [weak self] in
            /// Do anything you want...
            /// ...
            NSNotificationCenter.defaultCenter().postNotificationName("reloadDataNotification", object: nil)
            /// Stop refresh when your job finished, it will reset refresh footer if completion is true
            
            /// Set ignore footer or not
           //  self?.invitesTableView.es_stopPullToRefresh(completion: true, ignoreFooter: false)
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
         let invite : Invite = invites[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! InviteTableViewCell
        
        
        cell.nameLabel.text = String(format: "%@ %@", invite.ownerFirstName, invite.ownerLastName)
        cell.acceptButton.tag = indexPath.row
        cell.acceptButton.addTarget(self, action: #selector(acceptButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    func reloadInvitesTableView() {
        invitesTableView.reloadData()
        invitesTableView.es_stopPullToRefresh(completion: true)

    }
    
    
    
    
     func startTeamTapped(sender: AnyObject) {
        
        
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
    
        runAcceptTeamRequest(invite.teamId)
            
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
    
    
    func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No invites"
        let attrs = [NSFontAttributeName: UIFont(name: "MuseoSansRounded-300", size: 18)!, NSForegroundColorAttributeName:Helper.Colors.RGBCOLOR(104, green: 104, blue: 104)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView, forState state: UIControlState) -> NSAttributedString? {
        let str = "Start my own team"
        let attrs = [NSFontAttributeName: UIFont(name: "MuseoSansRounded-700", size: 24)!, NSForegroundColorAttributeName:Helper.Colors.RGBCOLOR(65, green: 207, blue: 108)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView) {
        startTeamTapped(UIButton())
    }
    /*
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView) -> CGFloat {
        return -100
    }
 */
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView) -> Bool {
        return true
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
