//
//  CodeViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 19.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SVProgressHUD
class CodeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var codeTextField: UITextField!
    
       override func viewDidLoad() {
        super.viewDidLoad()
       
       self.codeTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
         self.view.layer.insertSublayer(generateGradientForFrame(self.view.frame), atIndex: 0)
        self.codeTextField.delegate = self
      
        self.codeTextField.addDoneOnKeyboardWithTarget(self, action: #selector(CodeViewController.doneButtonTapped))
        
        
     
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
    
    func doneButtonTapped() {
        
        if self.codeTextField.text?.characters.count == 6 {
             print("textfield \(self.codeTextField.text)")
            self.codeTextField.resignFirstResponder()
            let code :String = self.codeTextField.text!
            let email: String = Helper.UserDefaults.kStandardUserDefaults.objectForKey(Helper.UserDefaults.kUserEmail) as! String
            runVerificateUserRequest(email, code: code)
        }else{
            SVProgressHUD.showErrorWithStatus("Entered code is not valid")
            
        }
    }
    
    
    func runVerificateUserRequest(email: String, code :String) {
        
        
        SVProgressHUD.show()
      
        let code :Int = Int(code)!
        let email: String = email
       
        provider.request(.VerificateUser(code: code, email: email)) { result in
            switch result {
            case let .Success(moyaResponse):
                
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject],
                        let secretCode = json["code"] as? String else {
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                     SVProgressHUD.dismiss()
                     Helper.UserDefaults.kStandardUserDefaults.setObject(secretCode, forKey: Helper.UserDefaults.kUserSecretCode)
                     Helper.UserDefaults.kStandardUserDefaults.synchronize()
                     self.performSegueWithIdentifier(Helper.SegueKey.kToSetPasswordViewController, sender: self)
                    
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
    
    
    
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 6 // Bool
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
