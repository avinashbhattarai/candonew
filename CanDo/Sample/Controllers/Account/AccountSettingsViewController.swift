//
//  AccountSettingsViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 05.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import ImagePicker
import Moya
import SVProgressHUD

class AccountSettingsViewController: UIViewController, ImagePickerDelegate {

  
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var leaveTeamButton: UIButton!
    
    var iamOwner : Bool = false
    var iamInTeam : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.title = "Account"
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "iconChevronRightWhite-1"), forState: .Normal)
        backButton.frame = CGRectMake(0, 0, 11, 16)
        backButton.addTarget(self, action: #selector(self.backButtonTapped(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: backButton), animated: true);
         self.avatarButton.layer.cornerRadius = 5
        self.avatarButton.clipsToBounds = true
        
        if iamInTeam {
            self.leaveTeamButton.hidden = false
        }else{
            self.leaveTeamButton.hidden = true
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        
        cleanUserDefaults()
        
        self.performSegueWithIdentifier("unwindToSignUpViewController", sender: self)
    }
    
    func runDeleteTeamRequest() {
        
        SVProgressHUD.show()
        provider.request(.DeleteTeam()) { result in
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
                    print(json)
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadDataNotification", object: nil)
                    self.navigationController?.popViewControllerAnimated(true)
                    
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
    
    func runLeaveTeamRequest() {
        
        SVProgressHUD.show()
        provider.request(.LeaveTeam()) { result in
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
                    print(json)
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadDataNotification", object: nil)
                    self.navigationController?.popViewControllerAnimated(true)
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
    
    @IBAction func leaveTemaTapped(sender: AnyObject) {
        
        
        if iamOwner {
            runDeleteTeamRequest()
        }else{
            runLeaveTeamRequest()
        }
     }
    
    
    @IBAction func avatarButtonTapped(sender: AnyObject) {
        let imagePicker = ImagePickerController()
        imagePicker.imageLimit = 1
        imagePicker.delegate = self
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func cleanUserDefaults() {
        
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserEmail)
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserFirstName)
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserId)
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserLastName)
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserSecretCode)
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserToken)
        
        Helper.UserDefaults.kStandardUserDefaults.synchronize()
        
    }

    // MARK: - ImagePickerDelegate
    
    func cancelButtonDidPress(imagePicker: ImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        /*
         guard images.count > 0 else { return }
         
         let lightboxImages = images.map {
         return LightboxImage(image: $0)
         }
         
         let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
         imagePicker.presentViewController(lightbox, animated: true, completion: nil)
         */
    }
    
    
    func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        self.avatarButton .setImage(images[0], forState: .Normal)
        print(images)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonTapped(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
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
