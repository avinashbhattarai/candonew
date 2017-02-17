//
//  LoginViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 23.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import SVProgressHUD
import NVActivityIndicatorView
import IQKeyboardManagerSwift
import SwiftyJSON
class LoginViewController: UIViewController, UITextFieldDelegate {

    enum LoginType {
        case email
        case mobile
    }
    
    
    
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var successContainer: UIView!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var resetPasswordContainer: UIView!
    @IBOutlet weak var resetPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var ansewerLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var forgotPassword: UIButton!
    var isKeyboardOpened = false
    var activityIndicatorView: NVActivityIndicatorView?
    var facebookId: String?
    var loginType: LoginType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if UIScreen.main.isPhone5 {
            ansewerLabel.isHidden = true
        }
        
        signUpButton.setUnderlineTitle("Not yet on Can Do?")
        cancelButton.setUnderlineTitle("Cancel")
        
        
        self.view.layer.insertSublayer(generateGradientForFrame(self.view.frame), at: 0)
        
        hideKeyboardWhenTappedAround()
        
        emailTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
        passwordTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
        mobileTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
        resetPasswordTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        cancelButton.isHidden = true
        passwordTextField.alpha = 0;
        resetPasswordContainer.isHidden = true
        successContainer.isHidden = true
        fadeViewIn(ansewerLabel, delay: 1.0)

        // Do any additional setup after loading the view.
    }
    func cleanTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
        resetPasswordTextField.text = ""
        mobileTextField.text = ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        emailTextField.textAlignment = .left
        mobileTextField.textAlignment = .left
        
        return true
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTage=textField.tag+1;
        // Try to find next responder
        let nextResponder=textField.superview?.viewWithTag(nextTage) as UIResponder!
        
        if (nextResponder != nil){
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    
    func keyboardWillShow(_ notification: Foundation.Notification) {
        
        
        print("field \(mobileTextField.isFirstResponder)")
        
        if !isKeyboardOpened {
            isKeyboardOpened = true
            print("show")
            passwordTextField.alpha = 1.0
            cancelButton.isHidden = false
            signUpButton.isHidden = true
            var y : CGFloat = 0
            if mobileTextField.isFirstResponder {
                y = mobileTextField.frame.origin.y - 28
                orLabel.isHidden = true
                loginType = .mobile
            }else{
                y = emailTextField.frame.origin.y + 77
                mobileTextField.isHidden = true
                orLabel.isHidden = true
                loginType = .email
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                
                for view in self.view.subviews {
                    view.translatesAutoresizingMaskIntoConstraints = true
                    view.center = CGPoint(x: view.center.x, y: view.center.y-y)
                }
                
                if self.emailTextField.isFirstResponder {
                    self.emailTextField.center = CGPoint(x: self.emailTextField.center.x, y: self.emailTextField.center.y+107)
                }
                
                self.cancelButton.frame = CGRect(x: self.cancelButton.frame.origin.x, y: self.view.frame.size.height - self.cancelButton.frame.size.height - 10, width: self.cancelButton.frame.size.width, height: self.cancelButton.frame.size.height)
                
            })
            
        }
        if resetPasswordTextField.isFirstResponder{
            
            if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                   var yOffset = -((self.view.frame.size.height - keyboardSize.height) - (resetPasswordContainer.frame.origin.y+resetPasswordButton.frame.origin.y))
                   yOffset += (resetPasswordButton.frame.size.height + 10)
              UIView.animate(withDuration: 0.2, animations: {
                self.view.frame.origin.y = -yOffset
         })
            }
        }
        
    }
    func keyboardWillHide(_ notification: Foundation.Notification) {
        if resetPasswordTextField.isFirstResponder{
            
            UIView.animate(withDuration: 0.2, animations: {
                self.view.frame.origin.y = 0
                
            })
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookLoginTapped(_ sender: AnyObject) {
        
        //commented for debug
        
         let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
         fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
           print(error,result)
        if (error == nil){
         let fbloginresult : FBSDKLoginManagerLoginResult = result!
            if (result?.isCancelled)! {
                return
            }
            
           print(fbloginresult.grantedPermissions)
         if(fbloginresult.grantedPermissions.contains("email"))
         {
         self.returnUserData()
         }
         }
         }

    }
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
                SVProgressHUD.showError(withStatus: "\(error)")
            }
            else
            {
                print("fetched user: \(result)")
                
                guard  let facebookResponse = result as? [String:AnyObject] else{
                    SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                    return
                }
                
                guard let userId = facebookResponse["id"] as? String
                    else{
                        
                        SVProgressHUD.showError(withStatus: "Can not get all needed data from Facebook")
                        
                        return
                }
                self.facebookId = userId
                self.runLoginUserRequest(UIButton())
                    
                
            }
        })
    }

    func configureSignUpButton(_ button:UIButton,showSpinner:Bool,spinnerTitle:String,nonSpinnerTitle:String)  {
        if showSpinner {
            
            button.backgroundColor = UIColor.clear
            button.setTitle(spinnerTitle, for: UIControlState())
            button.contentHorizontalAlignment = .left
            activityIndicatorView?.removeFromSuperview()
            activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: button.frame.size.width-30, y: (button.frame.size.height-30)/2, width: 30, height: 30), type: .ballClipRotate, color: UIColor.white, padding: 0)
            button.addSubview(activityIndicatorView!)
            activityIndicatorView!.startAnimating()
            button.isUserInteractionEnabled = false
            
            
            
        }else{
            button.backgroundColor =  UIColor(red: 44/255.0, green: 89/255.0, blue: 134/255.0, alpha: 1.0)
            button.setTitle(nonSpinnerTitle, for: UIControlState())
            activityIndicatorView?.stopAnimating()
            button.contentHorizontalAlignment = .center
            activityIndicatorView?.removeFromSuperview()
            button.isUserInteractionEnabled = true
        }
        
    }

    @IBAction func resetPasswordButtonTapped(_ sender: AnyObject) {
        
        if !isValidEmail(resetPasswordTextField.text!) && loginType == .email {
            SVProgressHUD.showError(withStatus: "Entered email is not valid")
            return
        }
 
        self.view.endEditing(true)
       
        runForgotPasswordRequest(sender as! UIButton)
        
    }
    func runForgotPasswordRequest(_ sender:UIButton) {
        
        
        var email: String?
        var phone: String?
        
        if loginType == .mobile {
            phone = resetPasswordTextField.text
        }else{
            email = resetPasswordTextField.text
        }

        
         configureSignUpButton(sender,showSpinner: true ,spinnerTitle: "Reseting",nonSpinnerTitle: "Reset Password")
        
        provider.request(.forgotPassword(email: email, phone: phone)) { result in
            switch result {
            case let .success(moyaResponse):
                
                
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject] else{
                        
                        self.configureSignUpButton(sender,showSpinner: false ,spinnerTitle: "Reseting",nonSpinnerTitle: "Reset Password")
                        SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                        return;
                    }
                    print(json)
                    self.configureSignUpButton(sender,showSpinner: false ,spinnerTitle: "Reseting",nonSpinnerTitle: "Reset Password")
                    self.showSuccessView()
                   
                    
                }
                catch {
                    
                    let json = JSON(dota: moyaResponse.data)
                    let message = json[0]["message"].stringValue
                    SVProgressHUD.showError(withStatus: "\(message)")
                    self.configureSignUpButton(sender,showSpinner: false ,spinnerTitle: "Reseting",nonSpinnerTitle: "Reset Password")
                }
                
                
            case let .failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                SVProgressHUD.showError(withStatus: "\(error.description)")
                self.configureSignUpButton(sender ,showSpinner: false ,spinnerTitle: "Logging in",nonSpinnerTitle: "Log In")
                
            }
        }
    }

    
    
    func showSuccessView(){
        resetPasswordContainer.isHidden = true
        successContainer.isHidden = false
        if loginType == .mobile {
            successLabel.text = "You’ll receive a password\nreset text message "
        }else{
            successLabel.text = "Check your mailbox, you will\nreceive a password reset email"
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
         if !isValidEmail(emailTextField.text!) && loginType == .email{
         SVProgressHUD.showError(withStatus: "Entered email is not valid")
         return
         }
         if !passwordTextField.hasText {
         SVProgressHUD.showError(withStatus: "Password field is empty")
         return
         }
        
        
       facebookId = nil
        
       runLoginUserRequest(sender)
    }
    
    func runLoginUserRequest(_ sender:UIButton) {
        
        var password: String?
        var email: String?
        var phone: String?
        
        
         if facebookId == nil{
            configureSignUpButton(sender ,showSpinner: true ,spinnerTitle: "Logging in",nonSpinnerTitle: "Log In")
            
            if loginType == .mobile {
                phone = mobileTextField.text
            }else{
                email = emailTextField.text
            }
            password = passwordTextField.text
            
         }else{
            SVProgressHUD.show()
        }
        
        provider.request(.loginUser(password: password, email: email, facebookId: facebookId, phone: phone)) { result in
            switch result {
            case let .success(moyaResponse):
                
                
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    
                    
                    let json = JSON(dota: moyaResponse.data)
                    let email = json["email"].stringValue
                    let uid = json["id"].intValue
                    let last_name = json["last_name"].stringValue
                    let first_name = json["first_name"].stringValue
                    let token = json["token"].stringValue
                    let phone = json["phone"].stringValue
                    let isTeamOwner = json["is_team_owner"].boolValue


                    
                    Helper.UserDefaults.kStandardUserDefaults.set(email, forKey: Helper.UserDefaults.kUserEmail)
                    Helper.UserDefaults.kStandardUserDefaults.set(phone, forKey: Helper.UserDefaults.kUserMobile)
                    Helper.UserDefaults.kStandardUserDefaults.set(first_name, forKey: Helper.UserDefaults.kUserFirstName)
                    Helper.UserDefaults.kStandardUserDefaults.set(last_name, forKey: Helper.UserDefaults.kUserLastName)
                    Helper.UserDefaults.kStandardUserDefaults.set(uid, forKey: Helper.UserDefaults.kUserId)
                    Helper.UserDefaults.kStandardUserDefaults.set(token, forKey: Helper.UserDefaults.kUserToken)
                    Helper.UserDefaults.kStandardUserDefaults.set(isTeamOwner, forKey: Helper.UserDefaults.kIsUserGroupOwner)
                    
                    if var imgURL = json["avatar"].string{
                        imgURL = imgURL.replacingOccurrences(of: "\\", with: "")
                        Helper.UserDefaults.kStandardUserDefaults.set(imgURL, forKey: Helper.UserDefaults.kUserAvatar)
                    }
                    
                    Helper.UserDefaults.kStandardUserDefaults.synchronize()
                    
                    SVProgressHUD.dismiss()
                    self.configureSignUpButton(sender ,showSpinner: false ,spinnerTitle: "Logging in",nonSpinnerTitle: "Log In")
                    self.performSegue(withIdentifier: Helper.SegueKey.kToDashboardViewController, sender: self)
                    
                }
                catch {
                    
                    let json = JSON(dota: moyaResponse.data)
                    let message = json[0]["message"].stringValue
                    SVProgressHUD.showError(withStatus: "\(message)")
                    self.configureSignUpButton(sender ,showSpinner: false ,spinnerTitle: "Logging in",nonSpinnerTitle: "Log In")
                }
                
                
            case let .failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                SVProgressHUD.showError(withStatus: "\(error.description)")
                self.configureSignUpButton(sender ,showSpinner: false ,spinnerTitle: "Logging in",nonSpinnerTitle: "Log In")
                
            }
        }
    }

  
    @IBAction func forgotPasswordTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        resetPasswordContainer.isHidden = false
        if loginType == .mobile{
            print("mobile")
            resetPasswordTextField.placeholder = "Enter Mobile Number"
            resetPasswordTextField.keyboardType = .phonePad
            
        }else{
            print("email")
            resetPasswordTextField.placeholder = "Enter Email Address"
            resetPasswordTextField.keyboardType = .emailAddress
        }
        
    }
    @IBAction func signupButtontapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        cleanTextFields()
        resetPasswordContainer.isHidden = true
        orLabel.isHidden = false
        successContainer.isHidden = true
        mobileTextField.isHidden = false
        cancelButton.isHidden = true
        isKeyboardOpened = false
        signUpButton.isHidden = false
        passwordTextField.alpha=0
        emailTextField.textAlignment = .center
        mobileTextField.textAlignment = .center
        for view in self.view.subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
        }

    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func fadeViewIn(_ view : UIView, delay: TimeInterval) {
        
        let animationDuration = 1.0
        
        // Fade out the view after a delay
        
        UIView.animate(withDuration: animationDuration, delay: delay, options: UIViewAnimationOptions(), animations: { () -> Void in
            view.alpha = 1
            },
                                   completion: nil)
        
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

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
