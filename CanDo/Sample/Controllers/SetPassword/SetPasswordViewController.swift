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
        self.passwordTextField.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4)
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
        
        if !self.passwordTextField.hasText() {
            SVProgressHUD.showErrorWithStatus("Password field is empty")
            return
        }

        configureSignUpButton(sender, showSpinner: true)
        self.passwordTextField.resignFirstResponder()
       // self.performSegueWithIdentifier("toDashboardViewController", sender: self)

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
