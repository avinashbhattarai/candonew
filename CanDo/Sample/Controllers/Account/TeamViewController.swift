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
        teamTableView.delegate = self
        teamTableView.dataSource = self
        
        teamTableView.contentInset = UIEdgeInsetsMake(0, 0, 160, 0)
        
        
      _ = teamTableView.es_addPullToRefresh {
         
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "reloadDataNotification"), object: nil)
        
        }
       
        
       
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let member : Member = members[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TeamMemberTableViewCell
        
        cell.memberName.text = String(format: "%@ %@", member.firstName, member.lastName)
        cell.selectionStyle = .none
       
        if iamOwner {
            cell.removeFromTeamButton.isHidden = false
            if (indexPath as NSIndexPath).row == 0 {
                cell.removeFromTeamButton.isHidden = true
            }
        }else{
            cell.removeFromTeamButton.isHidden = true
        }
        
        if member.owner == true {
            cell.backgroundColor = Helper.Colors.RGBCOLOR(207, green: 222, blue: 255)
        }else{
            cell.backgroundColor = Helper.Colors.RGBCOLOR(246, green: 249, blue: 249)
        }
        if member.facebook == true {
            cell.prividerButton.setImage(UIImage(named:"iconFb"), for: UIControlState())
            cell.prividerButton.backgroundColor = Helper.Colors.RGBCOLOR(95, green: 145, blue: 255)
            cell.providerDetails.text = String(format: "%@ %@", member.firstName, member.lastName)
        }else{
            cell.prividerButton.setImage(UIImage(named:"icon-email"), for: UIControlState())
            cell.prividerButton.backgroundColor = Helper.Colors.RGBCOLOR(179, green: 183, blue: 194)
            cell.providerDetails.text = member.email
        }
        if member.status == Helper.AccountStatusKey.kInvited {
            cell.pendingInviteLabel.isHidden = false
        }else{
            cell.pendingInviteLabel.isHidden = true
        }
        
       
        cell.memberAvatar.kf.setImage(with: URL(string:member.avatar), placeholder: UIImage(named: Helper.PlaceholderImage.kAvatar), options: nil, progressBlock: nil, completionHandler: nil)
        
        cell.removeFromTeamButton.tag = (indexPath as NSIndexPath).row
        cell.removeFromTeamButton.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func removeButtonTapped(_ sender:UIButton) {
        
        
        
        let alert = UIAlertController(title: "", message: "Do you want to remove this user from team?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            print("OK")
            
            self.runRemoveUserFromTeamRequest(sender)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            print("Cancel")
        }))
        self.present(alert, animated: true, completion: nil)
    
    }
    func runRemoveUserFromTeamRequest(_ sender: UIButton) {
        
        print(sender.tag)
        
        let member : Member = members[sender.tag]
        
        
        
        SVProgressHUD.show()
        provider.request(.removeFromTeam(memberId: member.memberId)) { result in
            switch result {
            case let .success(moyaResponse):
                
                
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject]
                        else {
                            
                            SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    SVProgressHUD.dismiss()
                    self.members.remove(at: sender.tag)
                    self.teamTableView.deleteRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
                    print(json)
                    
                    
                }
                catch {
                    
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
                        let item = json[0] as? [String: AnyObject],
                        let message = item["message"] as? String else {
                            SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    SVProgressHUD.showError(withStatus: "\(message)")
                }
                
                
            case let .failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                SVProgressHUD.showError(withStatus: "\(error.description)")
                
                
            }
        }

    }

    func updateTeamTableView(){
        
        teamTableView.reloadData()
        if !iamOwner{
            inviteView.isHidden = true
            teamTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }else{
            inviteView.isHidden = false
             teamTableView.contentInset = UIEdgeInsetsMake(0, 0, 160, 0)
        }
        
       teamTableView.es_stopPullToRefresh(completion: true)

    }
    
    @IBAction func inviteButtonTapped(_ sender: AnyObject) {
        
        if !inviteTextField.hasText {
            SVProgressHUD.showError(withStatus: "Invite field is empty")
            return
        }
        
        
        SVProgressHUD.show()
        provider.request(.inviteToTeam(email: inviteTextField.text!)) { result in
            switch result {
            case let .success(moyaResponse):
                
                
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject]
                        else {
                            
                            SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    
                    SVProgressHUD.showSuccess(withStatus: "Invite sent!")
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "reloadDataNotification"), object: nil)
                    self.inviteTextField.text = ""
                    print(json)
                    
                    
                }
                catch {
                    
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
                        let item = json[0] as? [String: AnyObject],
                        let message = item["message"] as? String else {
                            SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    SVProgressHUD.showError(withStatus: "\(message)")
                }
                
                
            case let .failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                SVProgressHUD.showError(withStatus: "\(error.description)")
                
                
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
