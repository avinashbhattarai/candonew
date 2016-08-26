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
    var activityIndicatorView: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     self.view.layer.insertSublayer(generateGradientForFrame(self.view.frame), atIndex: 0)
        self.hideKeyboardWhenTappedAround()
        
        if self.isUserLogined() {
            performSegueWithIdentifier(Helper.SegueKey.kToDashboardViewController, sender: self)
        }
        
        
      self.emailTextfield.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
         self.firstNameTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
         self.lastNameTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
      self.emailTextfield.delegate = self
      self.lastNameTextField.delegate = self
        self.firstNameTextField.delegate = self
        self.cancelButton.hidden = true
        self.answerLabel.alpha = 0;
        self.firstNameTextField.alpha = 0;
     fadeViewInThenOut(self.answerLabel, delay: 0.5)
        
        
        
        
    }
    func cleanTextFields() {
        self.emailTextfield.text = ""
        self.firstNameTextField.text = ""
        self.lastNameTextField.text = ""
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
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
        
   
        self.emailTextfield.textAlignment = .Left
        
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
            self.firstNameTextField.alpha = 1.0
            self.cancelButton.hidden = false
             self.loginButton.hidden = true
            let y = self.emailTextfield.frame.origin.y-28
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
        
        
        if !isValidEmail(self.emailTextfield.text!) {
            SVProgressHUD.showErrorWithStatus("Entered email is not valid")
                 return
        }
        if !self.firstNameTextField.hasText() {
            SVProgressHUD.showErrorWithStatus("First name field is empty")
            return
        }
        if !self.lastNameTextField.hasText() {
            SVProgressHUD.showErrorWithStatus("Last name field is empty")
            return
        }
 
       
        runSignUpRequest(sender)
        
        
        
    }
    func runSignUpRequest(sender:UIButton) {
        
        configureSignUpButton(sender,showSpinner: true)
        provider.request(.CreateUser(firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, email: self.emailTextfield.text!)) { result in
            switch result {
            case let .Success(moyaResponse):
                
               
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    Helper.UserDefaults.kStandardUserDefaults.setObject(self.emailTextfield.text!, forKey: Helper.UserDefaults.kUserEmail)
                    Helper.UserDefaults.kStandardUserDefaults.setObject(self.firstNameTextField.text!, forKey: Helper.UserDefaults.kUserFirstName)
                    Helper.UserDefaults.kStandardUserDefaults.setObject(self.lastNameTextField.text!, forKey: Helper.UserDefaults.kUserLastName)
                    Helper.UserDefaults.kStandardUserDefaults.synchronize()
                    
                    self.configureSignUpButton(sender,showSpinner: false)
                    self.performSegueWithIdentifier(Helper.SegueKey.kToCodeViewController, sender: self)
                    
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
    
    
  
    
    func configureSignUpButton(button:UIButton,showSpinner:Bool)  {
        if showSpinner {
            
            button.backgroundColor = UIColor.clearColor()
            button.setTitle("Signing up", forState: .Normal)
            button.contentHorizontalAlignment = .Left
            activityIndicatorView?.removeFromSuperview()
            activityIndicatorView = NVActivityIndicatorView(frame: CGRectMake(button.frame.size.width-30, (button.frame.size.height-30)/2, 30, 30), type: .BallClipRotate, color: UIColor.whiteColor(), padding: 0)
            button.addSubview(activityIndicatorView!)
            activityIndicatorView!.startAnimation()
            button.userInteractionEnabled = false
           
           
            
           
        }else{
            button.backgroundColor =  UIColor(red: 44/255.0, green: 89/255.0, blue: 134/255.0, alpha: 1.0)
            button.setTitle("Sign up", forState: .Normal)
            activityIndicatorView?.stopAnimation()
            button.contentHorizontalAlignment = .Center
            activityIndicatorView?.removeFromSuperview()
            button.userInteractionEnabled = true
           
        }

    }
  
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.view.endEditing(true)
        cleanTextFields()
        self.cancelButton.hidden = true
        self.isKeyboardOpened = false
        self.firstNameTextField.alpha=0
         self.loginButton.hidden = false
        self.emailTextfield.textAlignment = .Center
        for view in self.view.subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // Facebook Delegate Methods
    
    @IBAction func facebookLoginButtonTapped(sender: AnyObject) {
        
        //commented for debug
        /*
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["email"], fromViewController: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.returnUserData()
                }
            }
        }
 */
         self.performSegueWithIdentifier(Helper.SegueKey.kToDashboardViewController, sender: self)
        
        
    }
  
      
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
                
                self.performSegueWithIdentifier(Helper.SegueKey.kToDashboardViewController, sender: self)
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
                view.alpha = 1
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
