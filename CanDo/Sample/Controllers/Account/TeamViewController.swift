//
//  TeamViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 05.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import Moya
import SVProgressHUD
import ESPullToRefresh

class TeamViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var inviteTextField: UITextField!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var teamTableView: UITableView!
    @IBOutlet weak var inviteView: UIView!
    
    var members = [Member]()
    var iamOwner : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.teamTableView.delegate = self
        self.teamTableView.dataSource = self
        
        self.teamTableView.contentInset = UIEdgeInsetsMake(0, 0, 160, 0)
        
        
        self.teamTableView.es_addPullToRefresh {
            [weak self] in
            /// Do anything you want...
            /// ...
             NSNotificationCenter.defaultCenter().postNotificationName("reloadDataNotification", object: nil)
            /// Stop refresh when your job finished, it will reset refresh footer if completion is true
            
            /// Set ignore footer or not
            // self?.teamTableView.es_stopPullToRefresh(completion: true, ignoreFooter: false)
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
        return members.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let member : Member = members[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TeamMemberTableViewCell
        
        cell.memberName.text = String(format: "%@ %@", member.firstName, member.lastName)
        
       
        if iamOwner {
            cell.removeFromTeamButton.hidden = false
            if indexPath.row == 0 {
                cell.removeFromTeamButton.hidden = true
            }
        }else{
            cell.removeFromTeamButton.hidden = true
        }
        
        if member.owner == true {
            cell.backgroundColor = Helper.Colors.RGBCOLOR(207, green: 222, blue: 255)
        }else{
            cell.backgroundColor = Helper.Colors.RGBCOLOR(246, green: 249, blue: 249)
        }
        if member.facebook == true {
            cell.prividerButton.setImage(UIImage(named:"iconFb"), forState: .Normal)
            cell.prividerButton.backgroundColor = Helper.Colors.RGBCOLOR(95, green: 145, blue: 255)
            cell.providerDetails.text = String(format: "%@ %@", member.firstName, member.lastName)
        }else{
            cell.prividerButton.setImage(UIImage(named:"icon-email"), forState: .Normal)
            cell.prividerButton.backgroundColor = Helper.Colors.RGBCOLOR(179, green: 183, blue: 194)
            cell.providerDetails.text = member.email
        }
        
        cell.removeFromTeamButton.tag = indexPath.row
        cell.removeFromTeamButton.addTarget(self, action: #selector(self.removeButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    func removeButtonTapped(sender:UIButton) {
        print(sender.tag)
          let member : Member = members[sender.tag]
        
        
        
        SVProgressHUD.show()
        provider.request(.RemoveFromTeam(memberId: member.memberId)) { result in
            switch result {
            case let .Success(moyaResponse):
                
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject]
                        else {
                            
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    SVProgressHUD.dismiss()
                    self.members.removeAtIndex(sender.tag)
                    self.teamTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: sender.tag, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                    print(json)
                    
                    
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

    func updateTeamTableView(){
        
        self.teamTableView.reloadData()
        if !iamOwner{
            self.inviteView.hidden = true
             self.teamTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }else{
            self.inviteView.hidden = false
             self.teamTableView.contentInset = UIEdgeInsetsMake(0, 0, 160, 0)
        }
        
       self.teamTableView.es_stopPullToRefresh(completion: true)

    }
    
    @IBAction func inviteButtonTapped(sender: AnyObject) {
        
        if !self.inviteTextField.hasText() {
            SVProgressHUD.showErrorWithStatus("Invite field is empty")
            return
        }
        
        
        SVProgressHUD.show()
        provider.request(.InviteToTeam(email: self.inviteTextField.text!)) { result in
            switch result {
            case let .Success(moyaResponse):
                
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject]
                        else {
                            
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    
                    SVProgressHUD.showSuccessWithStatus("User was invited successfully")
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadDataNotification", object: nil)
                    self.inviteTextField.text = ""
                    print(json)
                    
                    
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
