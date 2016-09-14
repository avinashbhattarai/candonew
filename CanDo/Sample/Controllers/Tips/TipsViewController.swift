//
//  TipsViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import Moya
import SVProgressHUD
import ESPullToRefresh
import SDWebImage

class TipsViewController: BaseViewController {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tipsTableView: UITableView!
    
    var tipsArray = [Tip]()
    var cachedImages:[UIImage?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tipsTableView.dataSource = self
        tipsTableView.delegate = self
        runTipsInfoRequest()
        
      
        
       

    }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func runTipsInfoRequest(){
        
        SVProgressHUD.show()
        provider.request(.TipsInfo()) { result in
            switch result {
            case let .Success(moyaResponse):
                
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [[String: AnyObject]] else {
                            print("wrong json format")
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    for tip in json{
                            let newTip = Tip(title: tip["title"]as? String, cover: tip["cover"]as? String, url: tip["url"]as? String)
                            self.tipsArray.append(newTip)
                        }
                    self.cachedImages = [UIImage?](count:self.tipsArray.count, repeatedValue: nil)
                    for index in 0 ..< self.tipsArray.count {
                        
                        let indexPath = NSIndexPath(forRow: index, inSection: 0)
                        self.loadImage(indexPath,tip: self.tipsArray[index])
                    }

                    
                    self.tipsTableView.reloadData()
                    SVProgressHUD.dismiss()
                    
                    
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

    func loadImage(indexPath: NSIndexPath, tip:Tip){
        
        
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:tip.cover), options: [], progress: {(receivedSize: Int, expectedSize: Int) -> Void in
            // progression tracking code
            
            }, completed: {(image: UIImage?, error: NSError!, cacheType: SDImageCacheType, finished: Bool!, imageURL: NSURL!) -> Void in
                // progression tracking code
            
                self.cachedImages![indexPath.row] = image
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tipsTableView.beginUpdates()
                    self.tipsTableView.reloadRowsAtIndexPaths(
                        [indexPath],
                        withRowAnimation: .Fade)
                    self.tipsTableView.endUpdates()
                })

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

}

// MARK: - UITableViewDataSource
extension TipsViewController : UITableViewDataSource{
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tipsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tip : Tip = tipsArray[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TipTableViewCell
        
        cell.titleLabel.text = tip.title
        
       
        
          cell.setPostedImage(self.cachedImages![indexPath.row])
         
            
        return cell
    }


 
}
// MARK: - UITableViewDelegate
extension TipsViewController : UITableViewDelegate{
    
}

