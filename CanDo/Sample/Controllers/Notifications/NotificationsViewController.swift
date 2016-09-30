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
import SVProgressHUD
import Kingfisher

class NotificationsViewController: BaseViewController, ImagePickerDelegate, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var notificationTableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var addPhotoButton: AddPhotoButton!
    @IBOutlet weak var selectedImageButton: UIButton!
    var heightAtIndexPath = NSMutableDictionary()
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
        
        
        let imageUrl = NSURL(string:(Helper.UserDefaults.kStandardUserDefaults.valueForKey(Helper.UserDefaults.kUserAvatar) as? String) ?? "")
        
        userAvatar.kf_setImageWithURL(imageUrl, placeholderImage: UIImage(named: Helper.PlaceholderImage.kAvatar), optionsInfo: nil, progressBlock: nil, completionHandler: nil)

        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        notificationTableView.emptyDataSetSource = self;
        notificationTableView.emptyDataSetDelegate = self;

        
        dateFormatter = NSDateFormatter()
        dateFormatter?.dateStyle = .LongStyle
        dateFormatter?.timeStyle = .ShortStyle
        
        
        
     //   notificationTableView.estimatedRowHeight = 80
        notificationTableView.rowHeight = UITableViewAutomaticDimension
        notificationTableView.tableFooterView = UIView()
        notificationTableView.setNeedsLayout()
        notificationTableView.layoutIfNeeded()
        
        
        self.notificationTableView.es_addPullToRefresh {
            self.runNotificationsInfoRequest()
        }
        
        notificationTableView.es_startPullToRefresh()

        
    }
    func runNotificationsInfoRequest() {
        
        
        provider.request(.NotificationsInfo()) { result in
            switch result {
            case let .Success(moyaResponse):
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [[String: AnyObject]] else {
                        print("wrong json format")
                        self.notificationTableView.es_stopPullToRefresh(completion: true)
                        SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                        return
                    }
                    self.notifications.removeAll()
                    for notification in json {
                        if let notificationId = notification["id"] as? Int {
                            let newNotification = Notification(text: notification["post"] as? String, name: notification["user"] as? String, createdDate: notification["created_at"] as? String, updatedDate: notification["updated_at"] as? String, imageURL: notification["image"] as? String, notificationId: notificationId, avatar:notification["avatar"] as? String)
                        self.notifications.append(newNotification)
                        }
                    }
                    
                    self.notificationTableView.reloadData()
                    SVProgressHUD.dismiss()
                    self.notificationTableView.es_stopPullToRefresh(completion: true)
                    
                }
                catch {
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
                        item = json[0] as? [String: AnyObject],
                        message = item["message"] as? String else {
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            self.notificationTableView.es_stopPullToRefresh(completion: true)
                            return
                    }
                    SVProgressHUD.showErrorWithStatus("\(message)")
                    self.notificationTableView.es_stopPullToRefresh(completion: true)
                }
                
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                SVProgressHUD.showErrorWithStatus("\(error.description)")
                self.notificationTableView.es_stopPullToRefresh(completion: true)
                
            }
        }
        
    }

    func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No notifications"
        let attrs = [NSFontAttributeName: UIFont(name: "MuseoSansRounded-300", size: 18)!, NSForegroundColorAttributeName:Helper.Colors.RGBCOLOR(104, green: 104, blue: 104)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView) -> Bool {
        return true
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
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = self.heightAtIndexPath.objectForKey(indexPath)
        if ((height) != nil) {
            return CGFloat(height!.floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
     func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let height = cell.frame.size.height
        self.heightAtIndexPath.setObject(height, forKey: indexPath)
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let notification : Notification = notifications[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! NotificationTableViewCell
        
       cell.nameLabel.text = notification.name
       cell.contentLabel.text = notification.text
       cell.avatarImageView.kf_setImageWithURL(NSURL(string:notification.avatar), placeholderImage: UIImage(named: Helper.PlaceholderImage.kAvatar), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
       cell.dateLabel.text = dateFormatter?.stringFromDate(notification.createdDate)
        if notification.imageURL.characters.count > 0 && notification.image == nil {
            loadImage(indexPath, notification: notification)
        } else {
            cell.setPostedImage(notification.image)
        }
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImage(indexPath: NSIndexPath, notification: Notification) {
        
        ImageDownloader(name: "imageDownloader").downloadImageWithURL(NSURL(string: notification.imageURL)!, progressBlock: { (receivedSize: Int64, expectedSize: Int64) -> Void in
            // progression tracking code
            
            }, completionHandler: { (image: Kingfisher.Image?, error: NSError?, imageURL: NSURL?, originalData: NSData?) -> Void in
                
                print("image \(image)  url \(NSURL(string:notification.imageURL))  error \(error)")
                
                if image != nil {
                    let localImage: UIImage = image!
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        notification.image = localImage
                        self.notificationTableView.beginUpdates()
                        self.notificationTableView.reloadRowsAtIndexPaths(
                            [indexPath],
                            withRowAnimation: .Automatic)
                        self.notificationTableView.endUpdates()
                    })
                }
                
        })
        
    }

    func runPostNotificationRequest(text:String?, imageData: String?) {
        
        SVProgressHUD.show()
       
        provider.request(.PostNotification(post:text, image:imageData)) { result in
            switch result {
            case let .Success(moyaResponse):
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject] else {
                        print("wrong json format")
                       
                        SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                        return
                    }
                    
                    print(json)
                    if let notificationId = json["id"] as? Int {
                        let newNotification = Notification(text: json["post"] as? String, name: json["user"] as? String, createdDate: json["created_at"] as? String, updatedDate: json["updated_at"] as? String, imageURL: json["image"] as? String, notificationId: notificationId, avatar:json["avatar"] as? String)
                    
                    self.notifications.insert(newNotification, atIndex: 0)
                    self.notificationTableView.beginUpdates()
                    self.notificationTableView.insertRowsAtIndexPaths([
                        NSIndexPath(forRow: 0, inSection: 0)
                        ], withRowAnimation: .Automatic)
                    self.notificationTableView.endUpdates()
                    
                    
                    self.postTextView.text = ""
                    self.selectedImageButton.hidden = true
                    self.addPhotoButton.hidden = false
                    self.selectedImage = nil
                        SVProgressHUD.dismiss()
                        
                    }else{
                        
                        SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                    }

                }
                catch {
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
                        item = json[0] as? [String: AnyObject],
                        message = item["message"] as? String else {
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                           
                            return
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

    @IBAction func postButtonTapped(sender: AnyObject) {
        
        
        if !postTextView.hasText() && selectedImage == nil {
            SVProgressHUD.showErrorWithStatus("Post field is empty")
            return
        }
        var dataString:String?
        if selectedImage != nil {
            let data = resizeImage(selectedImage!)
            dataString = data!.toBase64()
        }
        
        //1371322 +
        //1498758 +
        
        //1635920 -
        //1917631 -
        
        runPostNotificationRequest(postTextView.text, imageData:dataString)
        
    }
    func resizeImage(image:UIImage) -> NSData? {
        let resizedImage = image.resizeWithPercentage(0.9)
        let data:NSData = UIImageJPEGRepresentation(resizedImage!, 1)!
        print(resizedImage, data.length)
        if data.length > Helper.UploadImageSize.kUploadSize as Int {
          let newData = resizeImage(resizedImage!)
          return newData
            
        }
        return data
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


