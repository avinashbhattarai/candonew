//
//  NotificationsViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
//import ImagePicker
//import Lightbox
import ESPullToRefresh
import SVProgressHUD
import Kingfisher

class NotificationsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var notificationTableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var addPhotoButton: AddPhotoButton!
    @IBOutlet weak var selectedImageButton: UIButton!
    var heightAtIndexPath = NSMutableDictionary()
    var dateFormatter : DateFormatter?
    var selectedImage: UIImage?
    let imagePicker = UIImagePickerController()
    var isHeaderOpened:Bool = false
    var notifications = [Notification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //test
        imagePicker.delegate = self
        postTextView.layer.cornerRadius = 5
        postTextView.layer.borderWidth = 1
        postTextView.layer.borderColor = UIColor(red: 228/255.0, green: 241/255.0, blue: 240/255.0, alpha: 1.0).cgColor
    
        selectedImageButton.layer.borderWidth = 1
        selectedImageButton.layer.borderColor = UIColor(red: 228/255.0, green: 241/255.0, blue: 240/255.0, alpha: 1.0).cgColor
        selectedImageButton.clipsToBounds = true
        
        
        let imageUrl = URL(string:(Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kUserAvatar) as? String) ?? "")
        
        userAvatar.kf.setImage(with: imageUrl, placeholder: UIImage(named: Helper.PlaceholderImage.kAvatar), options: nil, progressBlock: nil, completionHandler: nil)

        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        notificationTableView.emptyDataSetSource = self;
        notificationTableView.emptyDataSetDelegate = self;

        
        dateFormatter = DateFormatter()
        dateFormatter?.dateStyle = .long
        dateFormatter?.timeStyle = .short
        
        
        
     //   notificationTableView.estimatedRowHeight = 80
        notificationTableView.rowHeight = UITableViewAutomaticDimension
        notificationTableView.tableFooterView = UIView()
        notificationTableView.setNeedsLayout()
        notificationTableView.layoutIfNeeded()
        
        
        _ = notificationTableView.es_addPullToRefresh {
            self.runNotificationsInfoRequest()
        }
        
        notificationTableView.es_startPullToRefresh()

        
    }
    func runNotificationsInfoRequest() {
        
        
        provider.request(.notificationsInfo()) { result in
            switch result {
            case let .success(moyaResponse):
                
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [[String: AnyObject]] else {
                        print("wrong json format")
                        self.notificationTableView.es_stopPullToRefresh(completion: true)
                        SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
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
                        let item = json[0] as? [String: AnyObject],
                        let message = item["message"] as? String else {
                            //SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                            self.notificationTableView.es_stopPullToRefresh(completion: true)
                            return
                    }
                    SVProgressHUD.showError(withStatus: "\(message)")
                    self.notificationTableView.es_stopPullToRefresh(completion: true)
                }
                
            case let .failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                SVProgressHUD.showError(withStatus: "\(error.description)")
                self.notificationTableView.es_stopPullToRefresh(completion: true)
                
            }
        }
        
    }
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 100
    }

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No notifications"
        let attrs = [NSFontAttributeName: UIFont(name: "MuseoSansRounded-300", size: 18)!, NSForegroundColorAttributeName:Helper.Colors.RGBCOLOR(104, green: 104, blue: 104)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
   // func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      //  return 370
   // }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = self.heightAtIndexPath.object(forKey: indexPath)
        if ((height) != nil) {
            return CGFloat((height! as AnyObject).floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = cell.frame.size.height
        self.heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let notification : Notification = notifications[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! NotificationTableViewCell
        
       cell.nameLabel.text = notification.name
       cell.contentLabel.text = notification.text
       cell.avatarImageView.kf.setImage(with: URL(string:notification.avatar), placeholder: UIImage(named: Helper.PlaceholderImage.kAvatar), options: nil, progressBlock: nil, completionHandler: nil)
       cell.dateLabel.text = dateFormatter?.string(from: notification.createdDate as Date)
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
    
    func loadImage(_ indexPath: IndexPath, notification: Notification) {
        
        ImageDownloader(name: "imageDownloader").downloadImage(with: URL(string: notification.imageURL)!, progressBlock: { (receivedSize: Int64, expectedSize: Int64) -> Void in
            // progression tracking code
            
            }, completionHandler: { (image: Image?, error: NSError?, imageURL: URL?, originalData: Data?) -> Void in
                
                print("image \(image)  url \(NSURL(string:notification.imageURL))  error \(error)")
                
                if image != nil {
                    let localImage: UIImage = image!
                    
                   DispatchQueue.main.async{
                        notification.image = localImage
                        self.notificationTableView.beginUpdates()
                        self.notificationTableView.reloadRows(at: [indexPath],with: .automatic)
                        self.notificationTableView.endUpdates()
                    }
                }
                
        })
        
    }

    func runPostNotificationRequest(_ text:String?, imageData: String?) {
        
        SVProgressHUD.show()
       
        provider.request(.postNotification(post:text, image:imageData)) { result in
            switch result {
            case let .success(moyaResponse):
                
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject] else {
                        print("wrong json format")
                       
                        SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                        return
                    }
                    
                    print(json)
                    if let notificationId = json["id"] as? Int {
                        let newNotification = Notification(text: json["post"] as? String, name: json["user"] as? String, createdDate: json["created_at"] as? String, updatedDate: json["updated_at"] as? String, imageURL: json["image"] as? String, notificationId: notificationId, avatar:json["avatar"] as? String)
                    
                    self.notifications.insert(newNotification, at: 0)
                    self.notificationTableView.beginUpdates()
                    self.notificationTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    self.notificationTableView.endUpdates()
                    self.postTextView.text = ""
                    self.selectedImageButton.isHidden = true
                    self.addPhotoButton.isHidden = false
                    self.selectedImage = nil
                        SVProgressHUD.dismiss()
                        
                    }else{
                        
                        SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                    }

                }
                catch {
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
                        let item = json[0] as? [String: AnyObject],
                        let message = item["message"] as? String else {
                            SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                           
                            return
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

    @IBAction func postButtonTapped(_ sender: AnyObject) {
        
        
        if !postTextView.hasText && selectedImage == nil {
            SVProgressHUD.showError(withStatus: "Post or image field is empty")
            return
        }
        
         var dataString:String?
         if selectedImage != nil {
            SVProgressHUD.show()
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            let data = self.resizeImage(self.selectedImage!)
            dataString = data!.toBase64()
            
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
                self.runPostNotificationRequest(self.postTextView.text, imageData:dataString)
            }
        }
         }else{
            runPostNotificationRequest(postTextView.text, imageData:dataString)
        }
        
    }
    
    func resizeImage(_ image:UIImage) -> Data? {
        let resizedImage = image.resizeWithPercentage(0.9)
        let data:Data = UIImageJPEGRepresentation(resizedImage!, 1)!
        print(resizedImage, data.count)
        if data.count > Helper.UploadImageSize.kUploadSize as Int {
          let newData = resizeImage(resizedImage!)
          return newData
            
        }
        return data
    }
    
    @IBAction func selectedButtonTapped(_ sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Choose new photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
           self.addPhotoTapped(UIButton())
        })
        let saveAction = UIAlertAction(title: "Remove selected photo", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
           
            self.selectedImageButton.isHidden = true
            self.addPhotoButton.isHidden = false
            self.selectedImage = nil
            
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
           
        })
        
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }
    
   
    @IBAction func addPhotoTapped(_ sender: AnyObject) {
        
        imagePicker.allowsEditing = false
        
        let optionMenu = UIAlertController(title: nil, message: "Add a Photo", preferredStyle: .actionSheet)
        
        // 2
        let createPhotoAction = UIAlertAction(title: "Create Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
            
        })
        let chooseFromLibraryAction = UIAlertAction(title: "Choose from Library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        // 4
        optionMenu.addAction(createPhotoAction)
        optionMenu.addAction(chooseFromLibraryAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)

    }
    @IBAction func postUpdateButtonTapped(_ sender: AnyObject) {
        
        
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
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            tblHeaderView?.frame = newRect!
            self.notificationTableView.tableHeaderView = tblHeaderView
            
        })
    }
    
    // MARK: - ImagePickerDelegate
    
    
      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = pickedImage
            self.selectedImageButton.setImage(pickedImage, for: UIControlState())
            self.selectedImageButton.isHidden = false
            self.addPhotoButton.isHidden = true

        }
        
        dismiss(animated: true, completion: nil)
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


