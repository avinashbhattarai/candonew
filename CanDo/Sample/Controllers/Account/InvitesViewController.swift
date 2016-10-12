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
        
        
        
         _ = invitesTableView.es_addPullToRefresh {
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
        return invites.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let invite : Invite = invites[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! InviteTableViewCell
        
        
        cell.nameLabel.text = String(format: "%@ %@", invite.ownerFirstName, invite.ownerLastName)
        cell.acceptButton.tag = (indexPath as NSIndexPath).row
        cell.acceptButton.addTarget(self, action: #selector(acceptButtonTapped(_:)), for: .touchUpInside)
         cell.avatar.kf.setImage(with: URL(string:invite.avatar), placeholder: UIImage(named: Helper.PlaceholderImage.kAvatar), options: nil, progressBlock: nil, completionHandler: nil)
        return cell
    }
    
    func reloadInvitesTableView() {
        invitesTableView.reloadData()
        invitesTableView.es_stopPullToRefresh(completion: true)

    }
    
    
    
    
     func startTeamTapped(_ sender: AnyObject) {
        
        
        SVProgressHUD.show()
        provider.request(.createTeam()) { result in
            switch result {
            case let .success(moyaResponse):
                
                
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    guard let _ = moyaResponse.data.nsdataToJSON() as? [String: AnyObject]
                        else {
                            
                            SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    
                    SVProgressHUD.dismiss()
                    self.hideInvitesView()
                    
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

    func acceptButtonTapped(_ sender: UIButton){
        print("accept tapped \(sender.tag)")
         let invite : Invite = invites[sender.tag]
        if invites.count == 1 {
    
        runAcceptTeamRequest(invite.teamId)
            
        }else{
            
            let alert = UIAlertController(title: "", message: "You can only join one team at a time. Choose this team?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                print("OK")
                
            self.runAcceptTeamRequest(invite.teamId)
            
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                print("Cancel")
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func runAcceptTeamRequest(_ teamId:Int){
        
        print("team_id \(teamId)")
        
        SVProgressHUD.show()
        provider.request(.acceptInvite(teamId: teamId)) { result in
            switch result {
            case let .success(moyaResponse):
                
                
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    guard let _ = moyaResponse.data.nsdataToJSON() as? [String: AnyObject]
                        else {
                            
                            SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    
                    SVProgressHUD.dismiss()
                    self.hideInvitesView()
                    
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
    
    func hideInvitesView() {
        
        if  let parentViewController: AccountViewController = self.parent as? AccountViewController{
            parentViewController.runTeamInfoRequest()
        }

    }
    
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No invites"
        let attrs = [NSFontAttributeName: UIFont(name: "MuseoSansRounded-300", size: 18)!, NSForegroundColorAttributeName:Helper.Colors.RGBCOLOR(104, green: 104, blue: 104)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString? {
        let str = "Start my own team"
        let attrs = [NSFontAttributeName: UIFont(name: "MuseoSansRounded-700", size: 24)!, NSForegroundColorAttributeName:Helper.Colors.RGBCOLOR(65, green: 207, blue: 108)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView) {
        startTeamTapped(UIButton())
    }
    /*
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView) -> CGFloat {
        return -100
    }
 */
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
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
