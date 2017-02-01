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
import SwiftyJSON
class CodeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    var isMobileSignUpType: Bool = false
    
       override func viewDidLoad() {
        super.viewDidLoad()
       
       codeTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
         self.view.layer.insertSublayer(generateGradientForFrame(self.view.frame), at: 0)
        codeTextField.delegate = self
      
        codeTextField.addDoneOnKeyboardWithTarget(self, action: #selector(doneButtonTapped))
        
         if isMobileSignUpType{
            infoLabel.text = "You’ll receive a text message with a verification link"
            }
        
        
     
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
    
    func doneButtonTapped() {
        
        if codeTextField.text?.characters.count == 6 {
             print("textfield \(self.codeTextField.text)")
            codeTextField.resignFirstResponder()
            let code :String = codeTextField.text!
            let key: String = Helper.UserDefaults.kStandardUserDefaults.object(forKey: Helper.UserDefaults.kUserKey) as! String
            runVerificateUserRequest(key, code: code)
            
        }else{
            SVProgressHUD.showError(withStatus: "Entered code is not valid")
            
        }
    }
    
    
    func runVerificateUserRequest(_ key: String, code :String) {
        
        
        SVProgressHUD.show()
      
        let codeInt :Int = Int(code)!
        
        provider.request(.verificateUser(code: codeInt, key: key)) { result in
            switch result {
            case let .success(moyaResponse):
                
                
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: moyaResponse.data)
                    let secretCode = json["code"].stringValue
                    
                    SVProgressHUD.dismiss()
                     Helper.UserDefaults.kStandardUserDefaults.set(secretCode, forKey: Helper.UserDefaults.kUserSecretCode)
                     Helper.UserDefaults.kStandardUserDefaults.synchronize()
                     self.performSegue(withIdentifier: Helper.SegueKey.kToSetPasswordViewController, sender: self)
                    
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
    
    
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 6 // Bool
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
