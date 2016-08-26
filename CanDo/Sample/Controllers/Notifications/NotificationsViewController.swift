//
//  NotificationsViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import ImagePicker
import Lightbox

class NotificationsViewController: UIViewController, ImagePickerDelegate {

    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var notificationTableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    var isHeaderOpened:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //test
        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "iconChevronRightWhite-1"), forState: .Normal)
        backButton.frame = CGRectMake(0, 0, 11, 16)
        backButton.addTarget(self, action: #selector(NotificationsViewController.backButtonTapped(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: backButton), animated: true);
        
        
        postTextView.layer.cornerRadius = 5
        postTextView.layer.borderWidth = 1
        postTextView.layer.borderColor = UIColor(red: 228/255.0, green: 241/255.0, blue: 240/255.0, alpha: 1.0).CGColor

        

    }
    func backButtonTapped(sender: AnyObject) {
        let nc = (self.tabBarController?.navigationController)! as UINavigationController
        nc.popViewControllerAnimated(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func postButtonTapped(sender: AnyObject) {
    }
   
    @IBAction func addPhotoTapped(sender: AnyObject) {
        
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        
        presentViewController(imagePicker, animated: true, completion: nil)

        
    }
    @IBAction func postUpdateButtonTapped(sender: AnyObject) {
        
        
        var height:CGFloat = 0
        if isHeaderOpened {
            height = 90
            isHeaderOpened = false
        }else{
            height = 260
            isHeaderOpened = true
        }
        
        
        var newRect = self.notificationTableView.tableHeaderView?.frame
        newRect?.size.height = height
        // Get the reference to the header view
        let tblHeaderView = self.notificationTableView.tableHeaderView
        // Animate the height change
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            tblHeaderView?.frame = newRect!
            self.notificationTableView.tableHeaderView = tblHeaderView
        })
    }
    
    // MARK: - ImagePickerDelegate
    
    func cancelButtonDidPress(imagePicker: ImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
        
        let lightboxImages = images.map {
            return LightboxImage(image: $0)
        }
        
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        imagePicker.presentViewController(lightbox, animated: true, completion: nil)
    }
    
    func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        print(images)
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
