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
            performSegueWithIdentifier("toSetPasswordViewController", sender: self)
        }else{
            SVProgressHUD.showErrorWithStatus("Entered code is not valid")
            
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
