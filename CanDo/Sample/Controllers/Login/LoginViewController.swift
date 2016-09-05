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
class LoginViewController: UIViewController, UITextFieldDelegate {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.signUpButton.setUnderlineTitle("Not yet on Can Do?")
        self.cancelButton.setUnderlineTitle("Cancel")
        
        
        self.view.layer.insertSublayer(generateGradientForFrame(self.view.frame), atIndex: 0)
        self.hideKeyboardWhenTappedAround()
        self.emailTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
        self.passwordTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
        self.resetPasswordTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.cancelButton.hidden = true
        self.passwordTextField.alpha = 0;
        self.resetPasswordContainer.hidden = true
        self.successContainer.hidden = true
        fadeViewInThenOut(self.ansewerLabel, delay: 1.0)

        // Do any additional setup after loading the view.
    }
    func cleanTextFields() {
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        self.resetPasswordTextField.text = ""
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.navigationBarHidden = true
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        self.navigationController?.navigationBarHidden = false
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        
        self.emailTextField.textAlignment = .Left
        
        return true
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
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
    
    func keyboardWillShow(notification: NSNotification) {
        
        if !isKeyboardOpened {
            isKeyboardOpened = true
            print("show")
            self.passwordTextField.alpha = 1.0
            self.cancelButton.hidden = false
            self.signUpButton.hidden = true
            let y = self.emailTextField.frame.origin.y-28
            UIView.animateWithDuration(0.2, animations: {
                
                for view in self.view.subviews {
                    
                    
                    view.translatesAutoresizingMaskIntoConstraints = true
                    view.center = CGPointMake(view.center.x, view.center.y-y)
                    
                    
                }
                self.cancelButton.frame = CGRectMake(self.cancelButton.frame.origin.x, self.view.frame.size.height - self.cancelButton.frame.size.height - 10, self.cancelButton.frame.size.width, self.cancelButton.frame.size.height)
                
            })
            
        }
        if self.resetPasswordTextField.isFirstResponder(){
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                   var yOffset = -((self.view.frame.size.height - keyboardSize.height) - (self.resetPasswordContainer.frame.origin.y+self.resetPasswordButton.frame.origin.y))
                   yOffset += (self.resetPasswordButton.frame.size.height + 10)
              UIView.animateWithDuration(0.2, animations: {
                self.view.frame.origin.y = -yOffset
         })
            }
        }
        
    }
    func keyboardWillHide(notification: NSNotification) {
        if self.resetPasswordTextField.isFirstResponder(){
            
            UIView.animateWithDuration(0.2, animations: {
                self.view.frame.origin.y = 0
                
            })
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookLoginTapped(sender: AnyObject) {
        
        //commented for debug
        
         let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
         fbLoginManager.logInWithReadPermissions(["email"], fromViewController: self) { (result, error) -> Void in
         if (error == nil){
         let fbloginresult : FBSDKLoginManagerLoginResult = result
            if result.isCancelled {
                return
            }
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
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
                SVProgressHUD.showErrorWithStatus("\(error)")
            }
            else
            {
                print("fetched user: \(result)")
                guard let userId = result.valueForKey("id") as? String
                    else{
                        
                        SVProgressHUD.showErrorWithStatus("Can not get all needed data from Facebook")
                        
                        return;
                }
                self.facebookId = userId
                self.runLoginUserRequest(UIButton())
            }
        })
    }

    func configureSignUpButton(button:UIButton,showSpinner:Bool,spinnerTitle:String,nonSpinnerTitle:String)  {
        if showSpinner {
            
            button.backgroundColor = UIColor.clearColor()
            button.setTitle(spinnerTitle, forState: .Normal)
            button.contentHorizontalAlignment = .Left
            activityIndicatorView?.removeFromSuperview()
            activityIndicatorView = NVActivityIndicatorView(frame: CGRectMake(button.frame.size.width-30, (button.frame.size.height-30)/2, 30, 30), type: .BallClipRotate, color: UIColor.whiteColor(), padding: 0)
            button.addSubview(activityIndicatorView!)
            activityIndicatorView!.startAnimation()
            button.userInteractionEnabled = false
            
            
            
        }else{
            button.backgroundColor =  UIColor(red: 44/255.0, green: 89/255.0, blue: 134/255.0, alpha: 1.0)
            button.setTitle(nonSpinnerTitle, forState: .Normal)
            activityIndicatorView?.stopAnimation()
            button.contentHorizontalAlignment = .Center
            activityIndicatorView?.removeFromSuperview()
            button.userInteractionEnabled = true
        }
        
    }

    @IBAction func resetPasswordButtonTapped(sender: AnyObject) {
        if !isValidEmail(self.resetPasswordTextField.text!) {
            SVProgressHUD.showErrorWithStatus("Entered email is not valid")
            return
        }
 
        self.view.endEditing(true)
       
        runForgotPasswordRequest(sender as! UIButton)
        
    }
    func runForgotPasswordRequest(sender:UIButton) {
        
         configureSignUpButton(sender,showSpinner: true ,spinnerTitle: "Reseting",nonSpinnerTitle: "Reset Password")
        
        provider.request(.ForgotPassword(email: self.resetPasswordTextField.text!)) { result in
            switch result {
            case let .Success(moyaResponse):
                
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    /*
                     
                     Helper.UserDefaults.kStandardUserDefaults.setObject(self.emailTextfield.text!, forKey: Helper.UserDefaults.kUserEmail)
                     Helper.UserDefaults.kStandardUserDefaults.setObject(self.firstNameTextField.text!, forKey: Helper.UserDefaults.kUserFirstName)
                     Helper.UserDefaults.kStandardUserDefaults.setObject(self.lastNameTextField.text!, forKey: Helper.UserDefaults.kUserLastName)
                     Helper.UserDefaults.kStandardUserDefaults.synchronize()
                     
                     */
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject]else {
                        // let secretCode = json["code"] as? String
                        self.configureSignUpButton(sender,showSpinner: false ,spinnerTitle: "Reseting",nonSpinnerTitle: "Reset Password")
                        SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                        return;
                    }
                    print(json)
                    self.configureSignUpButton(sender,showSpinner: false ,spinnerTitle: "Reseting",nonSpinnerTitle: "Reset Password")
                    self.showSuccessView()
                   // self.performSegueWithIdentifier(Helper.SegueKey.kToDashboardViewController, sender: self)
                    
                }
                catch {
                    
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
                        let item = json[0] as? [String: AnyObject],
                        let message = item["message"] as? String else {
                            self.configureSignUpButton(sender,showSpinner: false ,spinnerTitle: "Reseting",nonSpinnerTitle: "Reset Password")
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    SVProgressHUD.showErrorWithStatus("\(message)")
                    self.configureSignUpButton(sender,showSpinner: false ,spinnerTitle: "Reseting",nonSpinnerTitle: "Reset Password")
                    
                    
                    
                }
                
                
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                SVProgressHUD.showErrorWithStatus("\(error.description)")
                self.configureSignUpButton(sender ,showSpinner: false ,spinnerTitle: "Logging in",nonSpinnerTitle: "Log In")
                
            }
        }
    }

    
    
    func showSuccessView(){
        self.resetPasswordContainer.hidden = true
        self.successContainer.hidden = false
    }
    
    @IBAction func loginButtonTapped(sender: UIButton) {
        
         if !isValidEmail(self.emailTextField.text!) {
         SVProgressHUD.showErrorWithStatus("Entered email is not valid")
         return
         }
         if !self.passwordTextField.hasText() {
         SVProgressHUD.showErrorWithStatus("Password field is empty")
         return
         }
        
        
       facebookId = nil
        
       runLoginUserRequest(sender)
        
        
    }
    
    func runLoginUserRequest(sender:UIButton) {
        
        
        
         if((facebookId) == nil){
            configureSignUpButton(sender ,showSpinner: true ,spinnerTitle: "Logging in",nonSpinnerTitle: "Log In")
         }else{
            SVProgressHUD.show()
        }
        
        provider.request(.LoginUser(password: (self.passwordTextField.text!.isEmpty ? nil : self.passwordTextField.text!), email: (self.emailTextField.text!.isEmpty ? nil : self.emailTextField.text!), facebookId: facebookId)) { result in
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
                        
                        self.configureSignUpButton(sender ,showSpinner: false ,spinnerTitle: "Logging in",nonSpinnerTitle: "Log In")
                        SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                        return;
                    }
                    
                    Helper.UserDefaults.kStandardUserDefaults.setObject(email, forKey: Helper.UserDefaults.kUserEmail)
                    Helper.UserDefaults.kStandardUserDefaults.setObject(first_name, forKey: Helper.UserDefaults.kUserFirstName)
                    Helper.UserDefaults.kStandardUserDefaults.setObject(last_name, forKey: Helper.UserDefaults.kUserLastName)
                    Helper.UserDefaults.kStandardUserDefaults.setObject(id, forKey: Helper.UserDefaults.kUserId)
                    Helper.UserDefaults.kStandardUserDefaults.setObject(token, forKey: Helper.UserDefaults.kUserToken)
                    Helper.UserDefaults.kStandardUserDefaults.synchronize()
                    
                    SVProgressHUD.dismiss()
                    self.configureSignUpButton(sender ,showSpinner: false ,spinnerTitle: "Logging in",nonSpinnerTitle: "Log In")
                    self.performSegueWithIdentifier(Helper.SegueKey.kToDashboardViewController, sender: self)
                    
                }
                catch {
                    
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
                        let item = json[0] as? [String: AnyObject],
                        let message = item["message"] as? String else {
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            self.configureSignUpButton(sender ,showSpinner: false ,spinnerTitle: "Logging in",nonSpinnerTitle: "Log In")
                            return;
                    }
                    SVProgressHUD.showErrorWithStatus("\(message)")
                    self.configureSignUpButton(sender ,showSpinner: false ,spinnerTitle: "Logging in",nonSpinnerTitle: "Log In")
                    
                    
                    
                }
                
                
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                SVProgressHUD.showErrorWithStatus("\(error.description)")
                self.configureSignUpButton(sender ,showSpinner: false ,spinnerTitle: "Logging in",nonSpinnerTitle: "Log In")
                
            }
        }
    }

  
    @IBAction func forgotPasswordTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.resetPasswordContainer.hidden = false
        
    }
    @IBAction func signupButtontapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.view.endEditing(true)
        cleanTextFields()
        self.cancelButton.hidden = true
        self.isKeyboardOpened = false
        self.signUpButton.hidden = false
        self.passwordTextField.alpha=0
        self.emailTextField.textAlignment = .Center
        for view in self.view.subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
        }

    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func fadeViewInThenOut(view : UIView, delay: NSTimeInterval) {
        
        let animationDuration = 1.0
        
        // Fade out the view after a delay
        
        UIView.animateWithDuration(animationDuration, delay: delay, options: .CurveEaseInOut, animations: { () -> Void in
            view.alpha = 0
            },
                                   completion: nil)
        
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

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
