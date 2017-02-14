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
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.toValue = toValue
        rotateAnimation.duration = duration
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.fillMode = kCAFillModeForwards
        /*
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate
        }
 */
        self.layer.add(rotateAnimation, forKey: nil)
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
        suggestionsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        suggestionsTableView.emptyDataSetSource = self;
        suggestionsTableView.emptyDataSetDelegate = self;
        
        suggestionsTableView.contentInset = UIEdgeInsetsMake(0, 0, 94, 0)
        
        _ = suggestionsTableView.es_addPullToRefresh {
            self.runSuggestionsInfoRequest()
        }
        
        suggestionsTableView.es_startPullToRefresh()
 
        // Do any additional setup after loading the view.
    }

    func runSuggestionsInfoRequest() {
        
        
        provider.request(.suggestionsInfo()) { result in
            switch result {
            case let .success(moyaResponse):
                
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [[String: AnyObject]] else {
                        print("wrong json format")
                        self.suggestionsTableView.es_stopPullToRefresh(completion: true)
                        SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
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
                    
                    let firstCategory = self.sections.first
                    firstCategory?.collapsed = false
                    
                    self.suggestionsTableView.reloadData()
                    SVProgressHUD.dismiss()
                    self.suggestionsTableView.es_stopPullToRefresh(completion: true)

                    
                }
                catch {
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
                        let item = json[0] as? [String: AnyObject],
                        let message = item["message"] as? String else {
                           // SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                            self.suggestionsTableView.es_stopPullToRefresh(completion: true)
                            return
                    }
                    SVProgressHUD.showError(withStatus: "\(message)")
                    self.suggestionsTableView.es_stopPullToRefresh(completion: true)
                }
                
            case let .failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                SVProgressHUD.showError(withStatus: "\(error.description)")
                self.suggestionsTableView.es_stopPullToRefresh(completion: true)
                
            }
        }
        
    }

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No suggestions"
        let attrs = [NSFontAttributeName: UIFont(name: "MuseoSansRounded-300", size: 18)!, NSForegroundColorAttributeName:Helper.Colors.RGBCOLOR(104, green: 104, blue: 104)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return (sections[section].collapsed!) ? 0 : sections[section].suggestionItems!.count
    }
    
    
    
    
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "header") as! CollapsibleTableViewHeader
        header.toggleButton.tag = section
        header.backgroundColor = UIColor.white
        header.titleLabel.text = sections[section].name
        header.toggleButton.rotate(sections[section].collapsed! ? CGFloat(M_PI) : 0.0)
        header.toggleButton.addTarget(self, action: #selector(SuggestionsViewController.toggleCollapse), for: .touchUpInside)
        
        return header.contentView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 76
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SuggestionsItemCell!
            let item = sections[(indexPath as NSIndexPath).section].suggestionItems![(indexPath as NSIndexPath).row]
            cell?.nameLabel?.text = item.name
            cell?.selectedButton.backgroundColor = UIColor.clear
            cell?.selectedButton.layer.cornerRadius = 5
            cell?.selectedButton.layer.borderWidth = 1
            cell?.selectedButton.layer.borderColor = UIColor(red: 185/255.0, green: 212/255.0, blue: 214/255.0, alpha: 1.0).cgColor
            cell?.selectedButton.indexPath = indexPath
            cell?.selectionStyle = .none
            if item.selected! {
                print(indexPath)
                cell?.selectedButton .setImage(UIImage(named:"iconHelpAssignTickCopy"), for: UIControlState())
            }else{
                cell?.selectedButton .setImage(UIImage(), for: UIControlState())
            }
            cell?.selectedButton.addTarget(self, action: #selector(SuggestionsViewController.selectSuggestionsItem), for: .touchUpInside)
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
             return cell!

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
    
   
    @IBAction func allSelectedButtonTapped(_ sender: AnyObject) {
        
        var selectedTodos = [Int]()
        for suggestion in sections {
            for suggestionItem in suggestion.suggestionItems! {
                if suggestionItem.selected == true {
                    selectedTodos.append(suggestionItem.suggestionItemId)
                }
            }
        }
        
        print(selectedTodos)
        runAddSuggestionsRequest(selectedTodos as NSArray)
        
    }
    func runAddSuggestionsRequest(_ suggestions:NSArray) {
        
        SVProgressHUD.show()
        provider.request(.addSuggestions(suggestions: suggestions)) { result in
            switch result {
            case let .success(moyaResponse):
                
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "reDownloadDataTodo"), object: nil)
                    _ = self.navigationController?.popViewController(animated: true)
                    SVProgressHUD.dismiss()
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
    
    
    func selectSuggestionsItem(_ button:SelectSuggestionButton) {
        print(button.indexPath)
        let item = sections[(button.indexPath! as NSIndexPath).section].suggestionItems![(button.indexPath! as NSIndexPath).row]
        item.selected = !item.selected
        suggestionsTableView.reloadRows(at: [IndexPath(row: ((button.indexPath as NSIndexPath?)?.row)!, section: ((button.indexPath as NSIndexPath?)?.section)!)], with: .automatic)
    }
    //
    // MARK: - Event Handlers
    //
    func toggleCollapse(_ sender: UIButton) {
        let section = sender.tag
        let collapsed = sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = !collapsed!
        sender.rotate(0.0)
        
        // Reload section
        suggestionsTableView.reloadSections(IndexSet(integer: section), with: .automatic)
        
        if sections[section].collapsed == false
        {
            let lastRow: Int = suggestionsTableView.numberOfRows(inSection: section)-1
            suggestionsTableView.scrollToRow(at: IndexPath(row: lastRow, section: section), at: .bottom, animated: true)
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
