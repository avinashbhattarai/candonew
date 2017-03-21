//
//  AccountViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import Moya
import SVProgressHUD
class AccountViewController: BaseViewController {

    @IBOutlet weak var TeamView: UIView!
    @IBOutlet weak var InvitesView: UIView!
    
    var iamOwner : Bool = false
    var iamInTeam : Bool = false

  
  lazy  var teamViewController: TeamViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "TeamViewController") as! TeamViewController
        
        // Add View Controller as Child View Controller
        self.addViewControllerAsChildViewController(viewController)
        
        return viewController
    }()
    
 lazy   var sessionsViewController: InvitesViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "InvitesViewController") as! InvitesViewController
        
        // Add View Controller as Child View Controller
        self.addViewControllerAsChildViewController(viewController)
        
        return viewController
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        runTeamInfoRequest()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataNotification(_:)), name:NSNotification.Name(rawValue: "reloadDataNotification"), object: nil)
       
    }
    
    func reloadDataNotification(_ notification: Foundation.Notification){
        //Take Action on Notification
        runTeamInfoRequest()
    }
    
    
    func runTeamInfoRequest(){
        // SVProgressHUD.show()
        provider.request(.teamInfo()) { result in
            switch result {
            case let .success(moyaResponse):
                
                
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject],
                        let inTeam = json["in_team"] as? Bool,
                        let invitations = json["invitations"] as? [[String: AnyObject]],
                        let members = json["members"] as? [[String: AnyObject]],
                        let owner = json["owner"] as? [String: AnyObject],
                        let iam = json["iam"] as? [String: AnyObject]
                        else {
                            
                            
                            SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    
                    print("json \(json)")
                    
                    SVProgressHUD.dismiss()
                    
                    self.iamInTeam = inTeam
                    
                    if inTeam {
                         self.updateContainerViews(false, showTeam: true)
                        for vc in self.childViewControllers{
                            if let membersVC = vc as? TeamViewController{
                                
                                self.iamOwner = false
                                if let receivedOwnerId = owner["id"] as? Int{
                                    Helper.UserDefaults.kStandardUserDefaults.set(owner["first_name"] as? String ?? "", forKey: Helper.UserDefaults.kUserGroupOwner)
                                    Helper.UserDefaults.kStandardUserDefaults.set(owner["user_id"], forKey: Helper.UserDefaults.kUserGroupOwnerId)
                                    Helper.UserDefaults.kStandardUserDefaults.synchronize()
                                     if let receivedIamId = iam["id"] as? Int{
                                    if receivedOwnerId == receivedIamId{
                                        self.iamOwner = true
                                        Helper.UserDefaults.kStandardUserDefaults.set(true, forKey: Helper.UserDefaults.kIsUserGroupOwner)
                                        Helper.UserDefaults.kStandardUserDefaults.synchronize()
                                        }
                                        
                                    }
                                }
                                var parsedMembersArray : [Member] = self.parseMembers(members, owner: owner, iam: iam)
                                parsedMembersArray.sort(by: {$0.owner && !$1.owner})
                                membersVC.iamOwner = self.iamOwner
                                membersVC.members = parsedMembersArray
                                membersVC.updateTeamTableView()
                                                break
                            }
                        }

                    }else{
                        self.updateContainerViews(true, showTeam: false)
                        for vc in self.childViewControllers{
                            if let invitesVC = vc as? InvitesViewController{
                              invitesVC.invites = self.parseInvites(invitations)
                                invitesVC.reloadInvitesTableView()
                                break
                            }
                        }
                    }
  
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
    
    func parseInvites(_ invitations :[[String: AnyObject]]) -> [Invite] {
        var invitesArray = [Invite]()
        for invite in invitations{
            if let teamId = invite["team_id"] as? Int{
                let newInvite = Invite(teamId: teamId, ownerEmail: invite["owner_email"] as? String, ownerFirstName: invite["owner_first_name"] as? String, ownerLastName: invite["owner_last_name"] as? String, avatar:invite["avatar"] as? String)
                    invitesArray.append(newInvite)
            }
        }
        
        return invitesArray

    }
    
    func parseMembers(_ members :[[String: AnyObject]], owner: [String: AnyObject], iam: [String: AnyObject]) -> [Member] {
        
        var membersArray = [Member]()
        for member in members{
            if let memberId = member["id"] as? Int{
                if let userId = member["user_id"] as? Int{
                    if let facebook = member["facebook"] as? Bool{
                        let newMember = Member(memberId: memberId, userId: userId, email: member["email"] as? String, firstName: member["first_name"] as? String, lastName: member["last_name"] as? String, status: member["status"] as? String, facebook: facebook, owner: false, avatar: member["avatar"] as? String)
                                        membersArray.append(newMember)
                    }
                }
            }
        }
        
        if let newMemeber = parseOwnerData(owner, isOwner: true){
        membersArray.append(newMemeber)
        }
        if !iamOwner {
            if let newMemeber = parseOwnerData(iam, isOwner: false){
                membersArray.append(newMemeber)
            }

        }
        
        return membersArray
        
    }
    
    func parseOwnerData(_ owner: [String: AnyObject], isOwner: Bool) -> Member?{
        
        if let memberId = owner["id"] as? Int{
            if let userId = owner["user_id"] as? Int{
                if let facebook = owner["facebook"] as? Bool{
                    let newMember = Member(memberId: memberId, userId: userId, email: owner["email"] as? String, firstName: owner["first_name"] as? String, lastName: owner["last_name"] as? String, status: owner["status"] as? String, facebook: facebook, owner: isOwner, avatar: owner["avatar"] as? String)
                    return newMember
                }
            }
        }
        
        return nil
    }

    
    
    fileprivate func addViewControllerAsChildViewController(_ viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }

  
    func updateContainerViews(_ showInvites:Bool, showTeam:Bool)
    {
        self.InvitesView.isHidden = !showInvites
        self.TeamView.isHidden = !showTeam

    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Helper.SegueKey.kToAccountSettingsViewController {
            let viewController:AccountSettingsViewController = segue.destination as! AccountSettingsViewController
            viewController.iamInTeam = self.iamInTeam
            viewController.iamOwner = self.iamOwner
            
        }

    }
    

}
