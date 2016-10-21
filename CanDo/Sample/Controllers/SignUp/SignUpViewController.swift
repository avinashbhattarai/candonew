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
        
     self.view.layer.insertSublayer(generateGradientForFrame(self.view.frame), at: 0)
        hideKeyboardWhenTappedAround()
        
        if isUserLogined() {
            performSegue(withIdentifier: Helper.SegueKey.kToDashboardViewController, sender: self)
        }
        
       
        loginButton.setUnderlineTitle("Already on Can Do?")
        cancelButton.setUnderlineTitle("Cancel")
        
      emailTextfield.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
    firstNameTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
    lastNameTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
    emailTextfield.delegate = self
    lastNameTextField.delegate = self
    firstNameTextField.delegate = self
    cancelButton.isHidden = true
    firstNameTextField.alpha = 0;
    
        

    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue){
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        answerLabel.alpha = 1.0
         fadeViewInThenOut(answerLabel, delay: 1.0)
        self.navigationController?.isNavigationBarHidden = true
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
       NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
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
        
   
        emailTextfield.textAlignment = .left
        
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
        
        if !isKeyboardOpened {
            isKeyboardOpened = true
            print("show")
            firstNameTextField.alpha = 1.0
            cancelButton.isHidden = false
            loginButton.isHidden = true
            let y = emailTextfield.frame.origin.y-28
            UIView.animate(withDuration: 0.2, animations: {
                
                for view in self.view.subviews {
                    view.translatesAutoresizingMaskIntoConstraints = true
                    view.center = CGPoint(x: view.center.x, y: view.center.y-y)
                     }
                self.cancelButton.frame = CGRect(x: self.cancelButton.frame.origin.x, y: self.view.frame.size.height - self.cancelButton.frame.size.height - 10, width: self.cancelButton.frame.size.width, height: self.cancelButton.frame.size.height)
                
            })

        }
           
      
        
    }
   
    @IBAction func loginButtonTapped(_ sender: AnyObject) {
          performSegue(withIdentifier: Helper.SegueKey.kToLoginViewController, sender: self)
    }
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        
        
        if !isValidEmail(emailTextfield.text!) {
            SVProgressHUD.showError(withStatus: "Entered email is not valid")
                 return
        }
        if !firstNameTextField.hasText {
            SVProgressHUD.showError(withStatus: "First name field is empty")
            return
        }
        if !lastNameTextField.hasText {
            SVProgressHUD.showError(withStatus: "Last name field is empty")
            return
        }
 
        facebookData = nil
        runSignUpRequest(sender)
        
        
        
    }
    func runSignUpRequest(_ sender:UIButton) {
        
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
            firstName = facebookData?.value(forKey: "first_name") as? String
            lastName = facebookData?.value(forKey: "last_name") as? String
            email = facebookData?.value(forKey: "email") as? String
            facebookId = facebookData?.value(forKey: "id") as? String
            SVProgressHUD.show()
            
        }
       
        
        provider.request(.createUser(firstName: firstName!, lastName: lastName!, email: email!, facebookId:facebookId)) { result in
            switch result {
            case let .success(moyaResponse):
                
               
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    
                    if((facebookId) == nil){
                    Helper.UserDefaults.kStandardUserDefaults.set(self.emailTextfield.text!, forKey: Helper.UserDefaults.kUserEmail)
                    Helper.UserDefaults.kStandardUserDefaults.set(self.firstNameTextField.text!, forKey: Helper.UserDefaults.kUserFirstName)
                    Helper.UserDefaults.kStandardUserDefaults.set(self.lastNameTextField.text!, forKey: Helper.UserDefaults.kUserLastName)
                        
                    Helper.UserDefaults.kStandardUserDefaults.synchronize()
                    
                    self.configureSignUpButton(sender,showSpinner: false)
                        self.cancelButtonTapped(UIButton())
                    self.performSegue(withIdentifier: Helper.SegueKey.kToCodeViewController, sender: self)
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
    
    func runLoginUserViaFacebookRequest() {
        
        
        var facebookId: String?
        if((facebookData) != nil){
            facebookId = facebookData?.value(forKey: "id") as? String
        }
        
        provider.request(.loginUser(password: nil, email: nil, facebookId: facebookId)) { result in
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
                    
                    SVProgressHUD.dismiss()
                   
                    self.performSegue(withIdentifier: Helper.SegueKey.kToDashboardViewController, sender: self)
                    
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

  
    
    func configureSignUpButton(_ button:UIButton,showSpinner:Bool)  {
        if showSpinner {
            
            button.backgroundColor = UIColor.clear
            button.setTitle("Signing up", for: UIControlState())
            button.contentHorizontalAlignment = .left
            activityIndicatorView?.removeFromSuperview()
            activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: button.frame.size.width-30, y: (button.frame.size.height-30)/2, width: 30, height: 30), type: .ballClipRotate, color: UIColor.white, padding: 0)
            button.addSubview(activityIndicatorView!)
            activityIndicatorView!.startAnimating()
            button.isUserInteractionEnabled = false
           
           
            
           
        }else{
            button.backgroundColor =  UIColor(red: 44/255.0, green: 89/255.0, blue: 134/255.0, alpha: 1.0)
            button.setTitle("Sign Up", for: UIControlState())
            activityIndicatorView?.stopAnimating()
            button.contentHorizontalAlignment = .center
            activityIndicatorView?.removeFromSuperview()
            button.isUserInteractionEnabled = true
           
        }

    }
  
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        cleanTextFields()
        cancelButton.isHidden = true
        isKeyboardOpened = false
        firstNameTextField.alpha=0
        loginButton.isHidden = false
        emailTextfield.textAlignment = .center
        for view in self.view.subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // Facebook Delegate Methods
    
    @IBAction func facebookLoginButtonTapped(_ sender: AnyObject) {
        
        //commented for debug
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if (result?.isCancelled)! {
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
                guard let userId = facebookResponse["id"] as? String,
                let userFirstName  = facebookResponse["first_name"] as? String,
                let userLastName  = facebookResponse["last_name"] as? String,
                let userEmail = facebookResponse["email"] as? String else{
                 
                    SVProgressHUD.showError(withStatus: "Can not get all needed data from Facebook")
                
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
    func isValidEmail(_ testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func fadeViewInThenOut(_ view : UIView, delay: TimeInterval) {
        
        let animationDuration = 1.0
        
      // Fade out the view after a delay
            
        UIView.animate(withDuration: animationDuration, delay: delay, options: UIViewAnimationOptions(), animations: { () -> Void in
                view.alpha = 0
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

}
