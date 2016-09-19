//
//  SignUpViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 17.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import SVProgressHUD
import NVActivityIndicatorView
import IQKeyboardManagerSwift
import Moya

class SignUpViewController: UIViewController, UITextFieldDelegate {

   
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var answerLabel: UILabel!
    var isKeyboardOpened = false
    var facebookData : NSDictionary?
    var activityIndicatorView: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     self.view.layer.insertSublayer(generateGradientForFrame(self.view.frame), atIndex: 0)
        hideKeyboardWhenTappedAround()
        
        if isUserLogined() {
            performSegueWithIdentifier(Helper.SegueKey.kToDashboardViewController, sender: self)
        }
        
       
        loginButton.setUnderlineTitle("Already on Can Do?")
        cancelButton.setUnderlineTitle("Cancel")
        
      emailTextfield.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
    firstNameTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
    lastNameTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
    emailTextfield.delegate = self
    lastNameTextField.delegate = self
    firstNameTextField.delegate = self
    cancelButton.hidden = true
    firstNameTextField.alpha = 0;
    
        

    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
    
    func cleanTextFields() {
        emailTextfield.text = ""
        firstNameTextField.text = ""
        lastNameTextField.text = ""
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        answerLabel.alpha = 1.0
         fadeViewInThenOut(answerLabel, delay: 1.0)
        self.navigationController?.navigationBarHidden = true
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
       NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
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
        
   
        emailTextfield.textAlignment = .Left
        
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
            firstNameTextField.alpha = 1.0
            cancelButton.hidden = false
            loginButton.hidden = true
            let y = emailTextfield.frame.origin.y-28
            UIView.animateWithDuration(0.2, animations: {
                
                for view in self.view.subviews {
                    view.translatesAutoresizingMaskIntoConstraints = true
                    view.center = CGPointMake(view.center.x, view.center.y-y)
                     }
                self.cancelButton.frame = CGRectMake(self.cancelButton.frame.origin.x, self.view.frame.size.height - self.cancelButton.frame.size.height - 10, self.cancelButton.frame.size.width, self.cancelButton.frame.size.height)
                
            })

        }
           
      
        
    }
   
    @IBAction func loginButtonTapped(sender: AnyObject) {
          performSegueWithIdentifier(Helper.SegueKey.kToLoginViewController, sender: self)
    }
    @IBAction func signUpButtonTapped(sender: UIButton) {
        
        
        if !isValidEmail(emailTextfield.text!) {
            SVProgressHUD.showErrorWithStatus("Entered email is not valid")
                 return
        }
        if !firstNameTextField.hasText() {
            SVProgressHUD.showErrorWithStatus("First name field is empty")
            return
        }
        if !lastNameTextField.hasText() {
            SVProgressHUD.showErrorWithStatus("Last name field is empty")
            return
        }
 
        facebookData = nil
        runSignUpRequest(sender)
        
        
        
    }
    func runSignUpRequest(sender:UIButton) {
        
        configureSignUpButton(sender,showSpinner: true)
        var firstName: String?
        var lastName: String?
        var email: String?
        var facebookId: String?
        
        if((facebookData) == nil){
            firstName = firstNameTextField.text
            lastName = lastNameTextField.text
            email = emailTextfield.text
            facebookId = nil
        }else{
            firstName = facebookData?.valueForKey("first_name") as? String
            lastName = facebookData?.valueForKey("last_name") as? String
            email = facebookData?.valueForKey("email") as? String
            facebookId = facebookData?.valueForKey("id") as? String
            SVProgressHUD.show()
            
        }
       
        
        provider.request(.CreateUser(firstName: firstName!, lastName: lastName!, email: email!, facebookId:facebookId)) { result in
            switch result {
            case let .Success(moyaResponse):
                
               
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    if((facebookId) == nil){
                    Helper.UserDefaults.kStandardUserDefaults.setObject(self.emailTextfield.text!, forKey: Helper.UserDefaults.kUserEmail)
                    Helper.UserDefaults.kStandardUserDefaults.setObject(self.firstNameTextField.text!, forKey: Helper.UserDefaults.kUserFirstName)
                    Helper.UserDefaults.kStandardUserDefaults.setObject(self.lastNameTextField.text!, forKey: Helper.UserDefaults.kUserLastName)
                    Helper.UserDefaults.kStandardUserDefaults.synchronize()
                    
                    self.configureSignUpButton(sender,showSpinner: false)
                    self.performSegueWithIdentifier(Helper.SegueKey.kToCodeViewController, sender: self)
                        SVProgressHUD.dismiss()
                    }else{
                        
                        print("Login via facebook")
                        
                        self.runLoginUserViaFacebookRequest()
                    }
                    
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
    
    func runLoginUserViaFacebookRequest() {
        
        
        var facebookId: String?
        if((facebookData) != nil){
            facebookId = facebookData?.valueForKey("id") as? String
        }
        
        provider.request(.LoginUser(password: nil, email: nil, facebookId: facebookId)) { result in
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
                   
                    self.performSegueWithIdentifier(Helper.SegueKey.kToDashboardViewController, sender: self)
                    
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

  
    
    func configureSignUpButton(button:UIButton,showSpinner:Bool)  {
        if showSpinner {
            
            button.backgroundColor = UIColor.clearColor()
            button.setTitle("Signing up", forState: .Normal)
            button.contentHorizontalAlignment = .Left
            activityIndicatorView?.removeFromSuperview()
            activityIndicatorView = NVActivityIndicatorView(frame: CGRectMake(button.frame.size.width-30, (button.frame.size.height-30)/2, 30, 30), type: .BallClipRotate, color: UIColor.whiteColor(), padding: 0)
            button.addSubview(activityIndicatorView!)
            activityIndicatorView!.startAnimating()
            button.userInteractionEnabled = false
           
           
            
           
        }else{
            button.backgroundColor =  UIColor(red: 44/255.0, green: 89/255.0, blue: 134/255.0, alpha: 1.0)
            button.setTitle("Sign Up", forState: .Normal)
            activityIndicatorView?.stopAnimating()
            button.contentHorizontalAlignment = .Center
            activityIndicatorView?.removeFromSuperview()
            button.userInteractionEnabled = true
           
        }

    }
  
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.view.endEditing(true)
        cleanTextFields()
        cancelButton.hidden = true
        isKeyboardOpened = false
        firstNameTextField.alpha=0
        loginButton.hidden = false
        emailTextfield.textAlignment = .Center
        for view in self.view.subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // Facebook Delegate Methods
    
    @IBAction func facebookLoginButtonTapped(sender: AnyObject) {
        
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
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name,first_name, last_name"])
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
                
                guard let userId = result.valueForKey("id") as? String,
                let userFirstName  = result.valueForKey("first_name") as? String,
                let userLastName  = result.valueForKey("last_name") as? String,
                let userEmail = result.valueForKey("email") as? String else{
                 
                    SVProgressHUD.showErrorWithStatus("Can not get all needed data from Facebook")
                
                        return;
                }
                self.facebookData = ["id":userId,"first_name":userFirstName,"last_name":userLastName,"email":userEmail]
               self.runSignUpRequest(UIButton())

                
                
                
               // self.performSegueWithIdentifier(Helper.SegueKey.kToDashboardViewController, sender: self)
            }
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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

}
