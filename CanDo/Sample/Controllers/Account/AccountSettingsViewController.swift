//
//  AccountSettingsViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 05.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import ImagePicker
class AccountSettingsViewController: UIViewController, ImagePickerDelegate {

  
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.title = "Account"
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "iconChevronRightWhite-1"), forState: .Normal)
        backButton.frame = CGRectMake(0, 0, 11, 16)
        backButton.addTarget(self, action: #selector(self.backButtonTapped(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: backButton), animated: true);
         self.avatarButton.layer.cornerRadius = 5
        self.avatarButton.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        
        cleanUserDefaults()
        
        self.performSegueWithIdentifier("unwindToSignUpViewController", sender: self)
        
        
        
    }
    
    @IBAction func leaveTemaTapped(sender: AnyObject) {
        
        
    }
    @IBAction func avatarButtonTapped(sender: AnyObject) {
        let imagePicker = ImagePickerController()
        imagePicker.imageLimit = 1
        imagePicker.delegate = self
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func cleanUserDefaults() {
        
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserEmail)
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserFirstName)
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserId)
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserLastName)
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserSecretCode)
        Helper.UserDefaults.kStandardUserDefaults.removeObjectForKey(Helper.UserDefaults.kUserToken)
        
        Helper.UserDefaults.kStandardUserDefaults.synchronize()
        
    }

    // MARK: - ImagePickerDelegate
    
    func cancelButtonDidPress(imagePicker: ImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        /*
         guard images.count > 0 else { return }
         
         let lightboxImages = images.map {
         return LightboxImage(image: $0)
         }
         
         let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
         imagePicker.presentViewController(lightbox, animated: true, completion: nil)
         */
    }
    
    
    func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        self.avatarButton .setImage(images[0], forState: .Normal)
        print(images)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonTapped(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
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
