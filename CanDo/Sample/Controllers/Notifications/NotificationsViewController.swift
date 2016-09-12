//
//  NotificationsViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import ImagePicker
//import Lightbox
import ESPullToRefresh


class NotificationsViewController: BaseViewController, ImagePickerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var notificationTableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var addPhotoButton: AddPhotoButton!
    @IBOutlet weak var selectedImageButton: UIButton!
    
    var dateFormatter : NSDateFormatter?
    var selectedImage: UIImage?
    
    var isHeaderOpened:Bool = false
    var notifications = [Notification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //test
        
    
        
        
        postTextView.layer.cornerRadius = 5
        postTextView.layer.borderWidth = 1
        postTextView.layer.borderColor = UIColor(red: 228/255.0, green: 241/255.0, blue: 240/255.0, alpha: 1.0).CGColor
    
        selectedImageButton.layer.borderWidth = 1
        selectedImageButton.layer.borderColor = UIColor(red: 228/255.0, green: 241/255.0, blue: 240/255.0, alpha: 1.0).CGColor
        selectedImageButton.clipsToBounds = true

        self.notificationTableView.delegate = self
        self.notificationTableView.dataSource = self
        
        dateFormatter = NSDateFormatter()
        dateFormatter?.dateStyle = .LongStyle
        dateFormatter?.timeStyle = .ShortStyle
        
        
        
        self.notificationTableView.estimatedRowHeight = 80
        self.notificationTableView.rowHeight = UITableViewAutomaticDimension
        self.notificationTableView.tableFooterView = UIView()
        self.notificationTableView.setNeedsLayout()
        self.notificationTableView.layoutIfNeeded()
        
        
        self.notificationTableView.es_addPullToRefresh {
            [weak self] in
            /// Do anything you want...
            /// ...
           
            /// Stop refresh when your job finished, it will reset refresh footer if completion is true
            
            /// Set ignore footer or not
            //self?.notificationTableView.es_stopPullToRefresh(completion: true, ignoreFooter: false)
        }

        
    }
    
    
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
   // func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      //  return 370
   // }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let notification : Notification = notifications[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! NotificationTableViewCell
        
       cell.nameLabel.text = String(format: "%@ %@", notification.firstName, notification.lastName)
       cell.contentLabel.text = notification.text
       cell.dateLabel.text = dateFormatter?.stringFromDate(notification.date)
        if (notification.image != nil){
       cell.setPostedImage(notification.image)
        }else{
           cell.setPostedImage(nil)
        }
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func postButtonTapped(sender: AnyObject) {
        
        
        let newNotification :Notification = Notification(text: postTextView.text, firstName: Helper.UserDefaults.kStandardUserDefaults.valueForKey(Helper.UserDefaults.kUserFirstName) as? String, lastName: Helper.UserDefaults.kStandardUserDefaults.valueForKey(Helper.UserDefaults.kUserLastName) as? String, date: NSDate(), image: selectedImage)
        notifications.insert(newNotification, atIndex: 0)
        self.notificationTableView.reloadData()
        
        
        self.postTextView.text = ""
        self.selectedImageButton.hidden = true
        self.addPhotoButton.hidden = false
        self.selectedImage = nil
        
       // postUpdateButtonTapped(UIButton())
        
        
    }
    @IBAction func selectedButtonTapped(sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: "", preferredStyle: .ActionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Choose new photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
           self.addPhotoTapped(UIButton())
        })
        let saveAction = UIAlertAction(title: "Remove selected photo", style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
           
            self.selectedImageButton.hidden = true
            self.addPhotoButton.hidden = false
            self.selectedImage = nil
            
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
           
        })
        
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
        
    }
    
   
    @IBAction func addPhotoTapped(sender: AnyObject) {
        
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageLimit = 1
        
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
        print(images)
        selectedImage = images[0]
        self.selectedImageButton.setImage(images[0], forState: .Normal)
        self.selectedImageButton.hidden = false
        self.addPhotoButton.hidden = true
       
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
