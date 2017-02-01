//
//  AccountSettingsViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 05.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import Moya
import SVProgressHUD
import Kingfisher
class AccountSettingsViewController: BaseSecondLineViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var leaveTeamButton: UIButton!
    let imagePicker = UIImagePickerController()
    var iamOwner : Bool = false
    var iamInTeam : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.title = "Account"
        imagePicker.delegate = self
        userNameLabel.text = String(format: "%@ %@", (Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kUserFirstName) as? String) ?? "", (Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kUserLastName) as? String) ?? "")
        
        avatarButton.layer.cornerRadius = 5
        avatarButton.clipsToBounds = true
        
        let imageUrl = URL(string:(Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kUserAvatar) as? String) ?? "")
        
        avatarButton.kf.setImage(with: imageUrl, for: .normal, placeholder: UIImage(named: Helper.PlaceholderImage.kAvatar), options: nil, progressBlock: nil, completionHandler: nil)
        
        

        if iamInTeam {
            leaveTeamButton.isHidden = false
        }else{
            leaveTeamButton.isHidden = true
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutButtonTapped(_ sender: AnyObject) {
        
        cleanUserDefaults()
        
        self.performSegue(withIdentifier: "unwindToSignUpViewController", sender: self)
    }
    
    func runDeleteTeamRequest() {
        
        SVProgressHUD.show()
        provider.request(.deleteTeam()) { result in
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
                    print(json)
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "reloadDataNotification"), object: nil)
                    _ = self.navigationController?.popViewController(animated: true)
                    
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
    
    func runLeaveTeamRequest() {
        
        SVProgressHUD.show()
        provider.request(.leaveTeam()) { result in
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
                    print(json)
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "reloadDataNotification"), object: nil)
                    _ = self.navigationController?.popViewController(animated: true)
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
    
    @IBAction func leaveTemaTapped(_ sender: AnyObject) {
        
        
        if iamOwner {
            runDeleteTeamRequest()
        }else{
            runLeaveTeamRequest()
        }
     }
    
    
    @IBAction func avatarButtonTapped(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        
        let optionMenu = UIAlertController(title: nil, message: "Set a Photo", preferredStyle: .actionSheet)
        
        // 2
        let createPhotoAction = UIAlertAction(title: "Create Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
            
        })
        let chooseFromLibraryAction = UIAlertAction(title: "Choose from Library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        // 4
        optionMenu.addAction(createPhotoAction)
        optionMenu.addAction(chooseFromLibraryAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)

    }
    
    func cleanUserDefaults() {
        
        Helper.UserDefaults.kStandardUserDefaults.removeObject(forKey: Helper.UserDefaults.kUserMobile)
        Helper.UserDefaults.kStandardUserDefaults.removeObject(forKey: Helper.UserDefaults.kUserEmail)
        Helper.UserDefaults.kStandardUserDefaults.removeObject(forKey: Helper.UserDefaults.kUserFirstName)
        Helper.UserDefaults.kStandardUserDefaults.removeObject(forKey: Helper.UserDefaults.kUserId)
        Helper.UserDefaults.kStandardUserDefaults.removeObject(forKey: Helper.UserDefaults.kUserLastName)
        Helper.UserDefaults.kStandardUserDefaults.removeObject(forKey: Helper.UserDefaults.kUserSecretCode)
        Helper.UserDefaults.kStandardUserDefaults.removeObject(forKey: Helper.UserDefaults.kUserToken)
        Helper.UserDefaults.kStandardUserDefaults.removeObject(forKey: Helper.UserDefaults.kUserAvatar)
        Helper.UserDefaults.kStandardUserDefaults.removeObject(forKey: Helper.UserDefaults.kUserGroupOwner)
        Helper.UserDefaults.kStandardUserDefaults.removeObject(forKey: Helper.UserDefaults.kUserGroupOwnerId)
        Helper.UserDefaults.kStandardUserDefaults.synchronize()
        
    }

    // MARK: - ImagePickerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let data = resizeImage(pickedImage)
            let  dataString = data!.toBase64()
            
            runUpdateUserRequest(dataString, firstName: nil, lastName: nil, image: pickedImage)
            
        }
        
        dismiss(animated: true, completion: nil)
    }

    
    func resizeImage(_ image:UIImage) -> Data? {
        let resizedImage = image.resizeWithPercentage(0.9)
        let data:Data = UIImageJPEGRepresentation(resizedImage!, 1)!
        print(resizedImage, data.count)
        if data.count > Helper.UploadImageSize.kUploadSize as Int
        {
            let newData = resizeImage(resizedImage!)
            return newData
            
        }
        return data
    }


    func runUpdateUserRequest(_ avatar:String?,firstName:String?,lastName:String?, image:UIImage) {
        
        SVProgressHUD.show()
        provider.request(.updateUser(avatar:avatar,firstName:firstName,lastName:lastName)) { result in
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
                    self.avatarButton .setImage(image, for: .normal)
                    if var imgURL = json["avatar"] as? String{
                         imgURL = imgURL.replacingOccurrences(of: "\\", with: "")
                        Helper.UserDefaults.kStandardUserDefaults.set(imgURL, forKey: Helper.UserDefaults.kUserAvatar)
                        Helper.UserDefaults.kStandardUserDefaults.synchronize()
                    }
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "reloadDataNotification"), object: nil)
                   
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
