//
//  SetPasswordViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 22.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import SVProgressHUD
import NVActivityIndicatorView
class SetPasswordViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    var activityIndicatorView: NVActivityIndicatorView?
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
        self.view.layer.insertSublayer(generateGradientForFrame(self.view.frame), atIndex: 0)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    

    func generateGradientForFrame(frame: CGRect) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor(red: 40/255.0, green: 235/255.0, blue: 249/255.0, alpha: 1.0).CGColor, UIColor(red: 194/255.0, green: 127/255.0, blue: 255/255.0, alpha: 1.0).CGColor]
        
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = frame
        return gradient
    }
    
    func configureSignUpButton(button:UIButton,showSpinner:Bool)  {
        if showSpinner {
            
            button.backgroundColor = UIColor.clearColor()
            button.setTitle("Logging in", forState: .Normal)
            button.contentHorizontalAlignment = .Left
            activityIndicatorView?.removeFromSuperview()
            activityIndicatorView = NVActivityIndicatorView(frame: CGRectMake(button.frame.size.width-30, (button.frame.size.height-30)/2, 30, 30), type: .BallClipRotate, color: UIColor.whiteColor(), padding: 0)
            button.addSubview(activityIndicatorView!)
            activityIndicatorView!.startAnimation()
            button.userInteractionEnabled = false
            
            
            
        }else{
            button.backgroundColor =  UIColor(red: 44/255.0, green: 89/255.0, blue: 134/255.0, alpha: 1.0)
            button.setTitle("Set Password", forState: .Normal)
            activityIndicatorView?.stopAnimation()
            button.contentHorizontalAlignment = .Center
            activityIndicatorView?.removeFromSuperview()
            button.userInteractionEnabled = true
           
        }
        
    }


    @IBAction func passwordActionTapped(sender: UIButton) {
        
        if !passwordTextField.hasText() {
            SVProgressHUD.showErrorWithStatus("Password field is empty")
            return
        }
        passwordTextField.resignFirstResponder()
     runSetPasswordForUserRequest(sender)

    }
    func runSetPasswordForUserRequest(sender:UIButton) {
        
        configureSignUpButton(sender, showSpinner: true)
        let code :Int = Int(Helper.UserDefaults.kStandardUserDefaults.objectForKey(Helper.UserDefaults.kUserSecretCode) as! String)!
        let email: String = Helper.UserDefaults.kStandardUserDefaults.objectForKey(Helper.UserDefaults.kUserEmail) as! String
        
        provider.request(.SetPasswordForUser(password: passwordTextField.text!, code:code, email: email)) { result in
            switch result {
            case let .Success(moyaResponse):
                
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject],
                        let email = json["email"] as? String,
                        let id = json["id"] as? Int,
                        let last_name = json["last_name"] as? String,
                        let first_name = json["first_name"] as? String,
                        let token = json["token"] as? String
                        
                        else {
                            
                            self.configureSignUpButton(sender,showSpinner: false)
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    
                    Helper.UserDefaults.kStandardUserDefaults.setObject(email, forKey: Helper.UserDefaults.kUserEmail)
                    Helper.UserDefaults.kStandardUserDefaults.setObject(first_name, forKey: Helper.UserDefaults.kUserFirstName)
                    Helper.UserDefaults.kStandardUserDefaults.setObject(last_name, forKey: Helper.UserDefaults.kUserLastName)
                    Helper.UserDefaults.kStandardUserDefaults.setObject(id, forKey: Helper.UserDefaults.kUserId)
                    Helper.UserDefaults.kStandardUserDefaults.setObject(token, forKey: Helper.UserDefaults.kUserToken)
                    Helper.UserDefaults.kStandardUserDefaults.synchronize()
                    
                    
                    self.configureSignUpButton(sender,showSpinner: false)
                    self.performSegueWithIdentifier(Helper.SegueKey.kToDashboardViewController, sender: self)
                    
                }
                catch {
                    
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
                        let item = json[0] as? [String: AnyObject],
                        let message = item["message"] as? String else {
                            self.configureSignUpButton(sender,showSpinner: false)
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    SVProgressHUD.showErrorWithStatus("\(message)")
                    self.configureSignUpButton(sender,showSpinner: false)
                    
                    
                    
                }
                
                
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                SVProgressHUD.showErrorWithStatus("\(error.description)")
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
