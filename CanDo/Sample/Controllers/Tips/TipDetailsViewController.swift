//
//  TipDetailsViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak on 9/15/16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import SVProgressHUD

class TipDetailsViewController: BaseSecondLineViewController,UIWebViewDelegate, NSXMLParserDelegate {

    @IBOutlet weak var tipsScrollView: UIScrollView!
    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tipWebView: UIWebView!
    @IBOutlet weak var tipImage: UIImageView!
    @IBOutlet weak var tipTitle: UILabel!
    var currentTip: Tip?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Supporter Tips"
        if currentTip?.image != nil {
             setPostedImage(currentTip?.image)
        }
       
        tipTitle.text = currentTip?.title
        tipWebView.delegate = self
       
        
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: (NSURL(string: currentTip!.url)!))
        
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error in
            if (error == nil && data != nil) {
                guard let json = data!.nsdataToJSON() as? [String: AnyObject],
                let jsonText = json["text"] as? String
                    else {
                        SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                        return;
                }
 
               
              self.tipWebView.loadHTMLString(String(format:"<div style=\"color:#686868; margin-left:20px; margin-right:20px; font-family: %@; font-size: %i\">%@</div>","MuseoSansRounded-300",18,jsonText), baseURL: nil)
            }
        })
        
        task.resume()
        
        
        // Do any additional setup after loading the view.
    }
   
    func setPostedImage(image : UIImage?) {
        
        if (image != nil) {
            let aspect = image!.size.width / image!.size.height
            
            aspectConstraint = NSLayoutConstraint(item: tipImage, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: tipImage, attribute: NSLayoutAttribute.Height, multiplier: aspect, constant: 0.0)
            
            tipImage.image = image
        }else{
            tipImage.image = UIImage()
        }
        
    }
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            
            if oldValue != nil {
                tipImage.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                tipImage.addConstraint(aspectConstraint!)
            }
        }
    }
    
    func webViewDidStartLoad(webView : UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(webView : UIWebView) {
      //  webView.stringByEvaluatingJavaScriptFromString("document.getElementsByTagName('body')[0].style.fontFamily =\"HelveticaNeue\"")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        SVProgressHUD.dismiss()
        print(webView.scrollView.contentSize.height)
        self.webViewHeight.constant = webView.scrollView.contentSize.height
        self.view.layoutIfNeeded()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        SVProgressHUD.showErrorWithStatus("Can not download content")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
