//
//  SetNewPasswordViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 31.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import SVProgressHUD
import NVActivityIndicatorView
class SetNewPasswordViewController: UIViewController {

    @IBOutlet weak var newPassword: UITextField!
     var activityIndicatorView: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("setNewPasswordViewController")
        newPassword.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
        self.view.layer.insertSublayer(generateGradientForFrame(self.view.frame), at: 0)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    func generateGradientForFrame(_ frame: CGRect) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor(red: 40/255.0, green: 235/255.0, blue: 249/255.0, alpha: 1.0).cgColor, UIColor(red: 194/255.0, green: 127/255.0, blue: 255/255.0, alpha: 1.0).cgColor]
        
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = frame
        return gradient
    }
    
    func configureSignUpButton(_ button:UIButton,showSpinner:Bool)  {
        if showSpinner {
            
            button.backgroundColor = UIColor.clear
            button.setTitle("Logging in", for: UIControlState())
            button.contentHorizontalAlignment = .left
            activityIndicatorView?.removeFromSuperview()
            activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: button.frame.size.width-30, y: (button.frame.size.height-30)/2, width: 30, height: 30), type: .ballClipRotate, color: UIColor.white, padding: 0)
            button.addSubview(activityIndicatorView!)
            activityIndicatorView!.startAnimating()
            button.isUserInteractionEnabled = false
            
            
            
        }else{
            button.backgroundColor =  UIColor(red: 44/255.0, green: 89/255.0, blue: 134/255.0, alpha: 1.0)
            button.setTitle("Set New Password", for: UIControlState())
            activityIndicatorView?.stopAnimating()
            button.contentHorizontalAlignment = .center
            activityIndicatorView?.removeFromSuperview()
            button.isUserInteractionEnabled = true
            
        }
        
    }

    
    @IBAction func newPasswordTapped(_ sender: UIButton) {
        
        
        configureSignUpButton(sender, showSpinner: true)
        let code :Int = Int(Helper.UserDefaults.kStandardUserDefaults.object(forKey: Helper.UserDefaults.kUserSecretCode) as! String)!
        let email: String = Helper.UserDefaults.kStandardUserDefaults.object(forKey: Helper.UserDefaults.kUserEmail) as! String
        
        provider.request(.resetPasswordForUser(password: newPassword.text!, code:code, email: email)) { result in
            switch result {
            case let .success(moyaResponse):
                
                
                do {
                   try _ = moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject],
                        let email = json["email"] as? String,
                        let id = json["id"] as? Int,
                        let last_name = json["last_name"] as? String,
                        let first_name = json["first_name"] as? String,
                        let token = json["token"] as? String
                        
                        else {
                            
                            self.configureSignUpButton(sender,showSpinner: false)
                            SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    
                    Helper.UserDefaults.kStandardUserDefaults.set(email, forKey: Helper.UserDefaults.kUserEmail)
                    Helper.UserDefaults.kStandardUserDefaults.set(first_name, forKey: Helper.UserDefaults.kUserFirstName)
                    Helper.UserDefaults.kStandardUserDefaults.set(last_name, forKey: Helper.UserDefaults.kUserLastName)
                    Helper.UserDefaults.kStandardUserDefaults.set(id, forKey: Helper.UserDefaults.kUserId)
                    Helper.UserDefaults.kStandardUserDefaults.set(token, forKey: Helper.UserDefaults.kUserToken)
                    if var imgURL = json["avatar"] as? String{
                        imgURL = imgURL.replacingOccurrences(of: "\\", with: "")
                        Helper.UserDefaults.kStandardUserDefaults.set(imgURL, forKey: Helper.UserDefaults.kUserAvatar)
                    }

                    Helper.UserDefaults.kStandardUserDefaults.synchronize()
                    
                    
                    self.configureSignUpButton(sender,showSpinner: false)
                    self.performSegue(withIdentifier: Helper.SegueKey.kToDashboardViewController, sender: self)
                    
                }
                catch {
                    
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
                        let item = json[0] as? [String: AnyObject],
                        let message = item["message"] as? String else {
                            self.configureSignUpButton(sender,showSpinner: false)
                            SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    SVProgressHUD.showError(withStatus: "\(message)")
                    self.configureSignUpButton(sender,showSpinner: false)
                    
                    
                    
                }
                
                
            case let .failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                SVProgressHUD.showError(withStatus: "\(error.description)")
                self.configureSignUpButton(sender,showSpinner: false)
                
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
