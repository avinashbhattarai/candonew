//
//  SuggestionsViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 23.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import ESPullToRefresh
import SVProgressHUD


extension UIView {
    
    func rotate(toValue: CGFloat, duration: CFTimeInterval = 0.2, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.toValue = toValue
        rotateAnimation.duration = duration
        rotateAnimation.removedOnCompletion = false
        rotateAnimation.fillMode = kCAFillModeForwards
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.addAnimation(rotateAnimation, forKey: nil)
    }
}

class SuggestionsViewController: BaseSecondLineViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var sections = [Suggestion]()

    @IBOutlet weak var suggestionsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Suggestions"
        
        suggestionsTableView.delegate = self
        suggestionsTableView.dataSource = self;
        suggestionsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        suggestionsTableView.contentInset = UIEdgeInsetsMake(0, 0, 94, 0)
        
        suggestionsTableView.es_addPullToRefresh {
            self.runSuggestionsInfoRequest()
        }
        
        suggestionsTableView.es_startPullToRefresh()
 
        // Do any additional setup after loading the view.
    }

    func runSuggestionsInfoRequest() {
        
        
        provider.request(.SuggestionsInfo()) { result in
            switch result {
            case let .Success(moyaResponse):
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [[String: AnyObject]] else {
                        print("wrong json format")
                        self.suggestionsTableView.es_stopPullToRefresh(completion: true)
                        SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                        return
                    }
                    
                   self.sections = [Suggestion]()
                    for category in json {
                        if let categoryId = category["id"] as? Int {
                            let newCategory = Suggestion(name: category["category"] as? String, suggestionId: categoryId)
                            var suggestionsArray = [SuggestionsItem]()
                            if let suggestions = category["suggestions"] as? [[String: AnyObject]] {
                                for suggestion in suggestions{
                                    if let suggestionId = suggestion["id"] as? Int {
                                        let newSuggestion = SuggestionsItem(name: suggestion["suggestion"] as? String, suggestionItemId: suggestionId, suggestion: newCategory)
                                        suggestionsArray.append(newSuggestion)
                                    }
                                }
                                
                            }
                            newCategory.suggestionItems = suggestionsArray
                            self.sections.append(newCategory)
                           
                        }
                    }
                    
                    self.suggestionsTableView.reloadData()
                    SVProgressHUD.dismiss()
                    self.suggestionsTableView.es_stopPullToRefresh(completion: true)

                    
                }
                catch {
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
                        item = json[0] as? [String: AnyObject],
                        message = item["message"] as? String else {
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            self.suggestionsTableView.es_stopPullToRefresh(completion: true)
                            return
                    }
                    SVProgressHUD.showErrorWithStatus("\(message)")
                    self.suggestionsTableView.es_stopPullToRefresh(completion: true)
                }
                
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                SVProgressHUD.showErrorWithStatus("\(error.description)")
                self.suggestionsTableView.es_stopPullToRefresh(completion: true)
                
            }
        }
        
    }

    func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No suggestions"
        let attrs = [NSFontAttributeName: UIFont(name: "MuseoSansRounded-300", size: 18)!, NSForegroundColorAttributeName:Helper.Colors.RGBCOLOR(104, green: 104, blue: 104)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView) -> Bool {
        return true
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return (sections[section].collapsed!) ? 0 : sections[section].suggestionItems!.count
    }
    
    
    
    
     func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCellWithIdentifier("header") as! CollapsibleTableViewHeader
        header.toggleButton.tag = section
        header.backgroundColor = UIColor.whiteColor()
        header.titleLabel.text = sections[section].name
        header.toggleButton.rotate(sections[section].collapsed! ? CGFloat(M_PI) : 0.0)
        header.toggleButton.addTarget(self, action: #selector(SuggestionsViewController.toggleCollapse), forControlEvents: .TouchUpInside)
        
        return header.contentView
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 76
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! SuggestionsItemCell!
            let item = sections[indexPath.section].suggestionItems![indexPath.row]
            cell.nameLabel?.text = item.name
            cell.selectedButton.backgroundColor = UIColor.clearColor()
            cell.selectedButton.layer.cornerRadius = 5
            cell.selectedButton.layer.borderWidth = 1
            cell.selectedButton.layer.borderColor = UIColor(red: 185/255.0, green: 212/255.0, blue: 214/255.0, alpha: 1.0).CGColor
            cell.selectedButton.indexPath = indexPath
            if item.selected! {
                print(indexPath)
                cell.selectedButton .setImage(UIImage(named:"iconHelpAssignTickCopy"), forState: .Normal)
            }else{
                cell.selectedButton .setImage(UIImage(), forState: .Normal)
            }
            cell.selectedButton.addTarget(self, action: #selector(SuggestionsViewController.selectSuggestionsItem), forControlEvents: .TouchUpInside)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
             return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath)
    }
    
   
    @IBAction func allSelectedButtonTapped(sender: AnyObject) {
        
        var selectedTodos = [Int]()
        for suggestion in sections {
            for suggestionItem in suggestion.suggestionItems! {
                if suggestionItem.selected == true {
                    selectedTodos.append(suggestionItem.suggestionItemId)
                }
            }
        }
        
        print(selectedTodos)
        runAddSuggestionsRequest(selectedTodos)
        
    }
    func runAddSuggestionsRequest(suggestions:NSArray) {
        
        SVProgressHUD.show()
        provider.request(.AddSuggestions(suggestions: suggestions)) { result in
            switch result {
            case let .Success(moyaResponse):
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    NSNotificationCenter.defaultCenter().postNotificationName("reDownloadDataTodo", object: nil)
                    self.navigationController?.popViewControllerAnimated(true)
                    SVProgressHUD.dismiss()
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
    
    
    func selectSuggestionsItem(button:SelectSuggestionButton) {
        print(button.indexPath)
        let item = sections[button.indexPath!.section].suggestionItems![button.indexPath!.row]
        item.selected = !item.selected
        suggestionsTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: (button.indexPath?.row)!, inSection: (button.indexPath?.section)!)], withRowAnimation: .Automatic)
    }
    //
    // MARK: - Event Handlers
    //
    func toggleCollapse(sender: UIButton) {
        let section = sender.tag
        let collapsed = sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = !collapsed
        sender.rotate(0.0)
        
        // Reload section
        suggestionsTableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .Automatic)
        
        if sections[section].collapsed == false
        {
            let lastRow: Int = suggestionsTableView.numberOfRowsInSection(section)-1
            suggestionsTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lastRow, inSection: section), atScrollPosition: .Bottom, animated: true)
        }
       
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
