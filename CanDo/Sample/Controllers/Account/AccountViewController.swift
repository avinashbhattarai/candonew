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
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewControllerWithIdentifier("TeamViewController") as! TeamViewController
        
        // Add View Controller as Child View Controller
        self.addViewControllerAsChildViewController(viewController)
        
        return viewController
    }()
    
 lazy   var sessionsViewController: InvitesViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewControllerWithIdentifier("InvitesViewController") as! InvitesViewController
        
        // Add View Controller as Child View Controller
        self.addViewControllerAsChildViewController(viewController)
        
        return viewController
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
       
        runTeamInfoRequest()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadDataNotification(_:)), name:"reloadDataNotification", object: nil)
       
        
        
        
    }
    
    func reloadDataNotification(notification: NSNotification){
        //Take Action on Notification
        runTeamInfoRequest()
    }
    
    
    func runTeamInfoRequest(){
        // SVProgressHUD.show()
        provider.request(.TeamInfo()) { result in
            switch result {
            case let .Success(moyaResponse):
                
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject],
                        let inTeam = json["in_team"] as? Bool,
                        let invitations = json["invitations"] as? [[String: AnyObject]],
                        let members = json["members"] as? [[String: AnyObject]],
                        let owner = json["owner"] as? [String: AnyObject],
                        let iam = json["iam"] as? [String: AnyObject]
                        else {
                            
                            
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    
                    SVProgressHUD.dismiss()
                    
                    self.iamInTeam = inTeam
                    
                    if inTeam {
                         self.updateContainerViews(false, showTeam: true)
                        for vc in self.childViewControllers{
                            if let membersVC = vc as? TeamViewController{
                                
                                self.iamOwner = false
                                if let receivedOwnerId = owner["id"] as? Int{
                                     if let receivedIamId = iam["id"] as? Int{
                                    if receivedOwnerId == receivedIamId{
                                        self.iamOwner = true
                                        }
                                        
                                    }
                                }
                                var parsedMembersArray : [Member] = self.parseMembers(members, owner: owner)
                                parsedMembersArray.sortInPlace({$0.owner && !$1.owner})
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
    
    func parseInvites(invitations :[[String: AnyObject]]) -> [Invite] {
        var invitesArray = [Invite]()
        for invite in invitations{
            if let teamId = invite["team_id"] as? Int{
                let newInvite = Invite(teamId: teamId, ownerEmail: invite["owner_email"] as? String, ownerFirstName: invite["owner_first_name"] as? String, ownerLastName: invite["owner_last_name"] as? String, avatar:invite["avatar"] as? String)
                    invitesArray.append(newInvite)
            }
        }
        
        return invitesArray

    }
    
    func parseMembers(members :[[String: AnyObject]], owner: [String: AnyObject]) -> [Member] {
        
        var membersArray = [Member]()
        for member in members{
            if let memberId = member["id"] as? Int{
                if let userId = member["user_id"] as? Int{
                    if let facebook = member["facebook"] as? Bool{
                                        
                                        var isOwner: Bool = false
                                        if let receivedOwnerId = owner["id"] as? Int{
                                            if receivedOwnerId == memberId{
                                                isOwner = true
                                            }
                                        }
                        
                        let newMember = Member(memberId: memberId, userId: userId, email: member["email"] as? String, firstName: member["first_name"] as? String, lastName: member["last_name"] as? String, status: member["status"] as? String, facebook: facebook, owner: isOwner, avatar: member["avatar"] as? String)
                                        membersArray.append(newMember)
                    }
                }
            }
        }
        
        return membersArray
        
    }

    
    
    private func addViewControllerAsChildViewController(viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Notify Child View Controller
        viewController.didMoveToParentViewController(self)
    }

  
    func updateContainerViews(showInvites:Bool, showTeam:Bool)
    {
        self.InvitesView.hidden = !showInvites
        self.TeamView.hidden = !showTeam

    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Helper.SegueKey.kToAccountSettingsViewController {
            let viewController:AccountSettingsViewController = segue.destinationViewController as! AccountSettingsViewController
            viewController.iamInTeam = self.iamInTeam
            viewController.iamOwner = self.iamOwner
            
        }

    }
    

}
