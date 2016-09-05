//
//  SuggestionsViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 23.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

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

class SuggestionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var sections = [Suggestion]()

    @IBOutlet weak var suggestionsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Suggestions"
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "iconChevronRightWhite-1"), forState: .Normal)
        backButton.frame = CGRectMake(0, 0, 11, 16)
        backButton.addTarget(self, action: #selector(self.backButtonTapped(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: backButton), animated: true);
        
        self.suggestionsTableView.delegate = self
        self.suggestionsTableView.dataSource = self;
        self.suggestionsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        self.suggestionsTableView.contentInset = UIEdgeInsetsMake(0, 0, 94, 0)
        
        
        var items = [SuggestionsItem]()
        for _ in 0...4 {
            let item = SuggestionsItem(name: "Apple")
            items.append(item)
            }
        
        for _ in 0...4 {
           
            let suggestion = Suggestion(name: "Company", items: items)
            sections.append(suggestion)
        }
 
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func backButtonTapped(sender: AnyObject) {
        
        self.navigationController!.popViewControllerAnimated(true)
    }
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return (sections[section].collapsed!) ? 0 : sections[section].items.count
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
            let item = sections[indexPath.section].items[indexPath.row] as! SuggestionsItem
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
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func selectSuggestionsItem(button:SelectSuggestionButton) {
        print(button.indexPath)
        let item = sections[button.indexPath!.section].items[button.indexPath!.row] as! SuggestionsItem
        item.selected = !item.selected
        self.suggestionsTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: (button.indexPath?.row)!, inSection: (button.indexPath?.section)!)], withRowAnimation: .Automatic)
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
        self.suggestionsTableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .Automatic)
        
        if sections[section].collapsed == false
        {
            let lastRow: Int = self.suggestionsTableView.numberOfRowsInSection(section)-1
            self.suggestionsTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lastRow, inSection: section), atScrollPosition: .Bottom, animated: true)
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
