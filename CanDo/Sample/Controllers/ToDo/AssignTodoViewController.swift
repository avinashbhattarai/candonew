//
//  AssignTodoViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 04.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import SVProgressHUD
import Moya
import ESPullToRefresh
import Kingfisher
class AssignTodoViewController: BaseSecondLineViewController,UITableViewDelegate,UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var todoTitleLabel: UILabel!
    @IBOutlet weak var personsTableView: UITableView!
   
    var persons = [Person]()
    var currentTodo: Todo?
    var senderViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if senderViewController is TodoViewController {
            self.title = "To Do List"
        }else if senderViewController is CalendarViewController{
            self.title = "Calendar"
        }
        
        
        
        if (currentTodo != nil) {
            todoTitleLabel.text = currentTodo?.name
        }
        
        

        personsTableView.delegate = self;
        personsTableView.dataSource = self;
        personsTableView.emptyDataSetSource = self;
        personsTableView.emptyDataSetDelegate = self;
        personsTableView.contentInset = UIEdgeInsetsMake(0, 0, 94, 0)
        
        personsTableView.es_addPullToRefresh {
            
            /// Do anything you want...
            /// ...
            self.runTeamInfoRequest()
            /// Stop refresh when your job finished, it will reset refresh footer if completion is true
            
        }

        
        personsTableView.es_startPullToRefresh()
        
        // Do any additional setup after loading the view.
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No members"
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
        return persons.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
  

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let person : Person = persons[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! PersonTableViewCell
        
        
        if person.selected == true {
             cell.selectButton .setImage(UIImage(named:"iconHelpAssignTickCopy"), forState: .Normal)
        }else{
            cell.selectButton .setImage(UIImage(), forState: .Normal)
        }
        
 
        cell.selectButton.backgroundColor = UIColor.clearColor()
        cell.selectButton.layer.cornerRadius = cell.selectButton.frame.size.height/2
        cell.selectButton.layer.borderWidth = 1
        cell.selectButton.layer.borderColor = UIColor(red: 185/255.0, green: 212/255.0, blue: 214/255.0, alpha: 1.0).CGColor
        
        cell.personAvatar.layer.cornerRadius = 5
        if person.personId == 0 {
            cell.personAvatar.image =  UIImage()
        }else{
            
            cell.personAvatar.kf_setImageWithURL(NSURL(string:person.avatar), placeholderImage: UIImage(named: Helper.PlaceholderImage.kAvatar), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        }

        cell.personTitle.text = person.name
        
        cell.selectButton.indexPath = indexPath
        cell.selectButton.addTarget(self, action: #selector(selectedButtonTapped(_:)), forControlEvents: .TouchUpInside)
      
        
        return cell
    }


    func runTeamInfoRequest(){
        
        provider.request(.TeamInfo()) { result in
            switch result {
            case let .Success(moyaResponse):
                
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject],
                        let members = json["members"] as? [[String: AnyObject]]
                        else {
                            
                            self.personsTableView.es_stopPullToRefresh(completion: true)
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    
                    SVProgressHUD.dismiss()
                    self.persons = [Person]()
                    for member in members{
                        
                            if let userId = member["user_id"] as? Int{
                              
                                let newPerson = Person(name: String(format:"%@ %@",(member["first_name"] as? String ?? ""),(member["last_name"] as? String ?? "")), personId: userId, avatar: member["avatar"] as? String)
                                    self.persons.append(newPerson)
                        }
                    }
                    let anyOnePerson = Person(name: "Anyone", personId: 0, avatar: "")
                    self.persons.insert(anyOnePerson, atIndex: 0)
                    
                    for person:Person in self.persons{
                        if self.currentTodo?.assignedTo.personId == person.personId{
                            person.selected = true
                            break
                        }
                    }
                    
                    self.personsTableView.es_stopPullToRefresh(completion: true)
                    self.personsTableView.reloadData()

                    
                }
                catch {
                    
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
                        let item = json[0] as? [String: AnyObject],
                        let message = item["message"] as? String else {
                            self.personsTableView.es_stopPullToRefresh(completion: true)
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    self.personsTableView.es_stopPullToRefresh(completion: true)
                    SVProgressHUD.showErrorWithStatus("\(message)")
                }
                
                
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                self.personsTableView.es_stopPullToRefresh(completion: true)
                SVProgressHUD.showErrorWithStatus("\(error.description)")
                
                
            }
        }
        
    }

  
    
    @IBAction func assignTodoButtonTapped(sender: AnyObject) {
        
        
        for person:Person in persons{
            if person.selected! {
                currentTodo?.assignedTo = person
                break
            }
            
        }
        if currentTodo?.footer != nil {
            currentTodo?.footer?.assignTodoButton.setTitle(currentTodo?.assignedTo.name, forState: .Normal)
            currentTodo?.footer?.assignTodoButton.setImage(nil, forState: .Normal)
            

        
        }else{
            
            if senderViewController is TodoViewController {
                NSNotificationCenter.defaultCenter().postNotificationName("reloadDataTodo", object: nil, userInfo: ["todo":currentTodo!])
            }else if senderViewController is CalendarViewController{
                NSNotificationCenter.defaultCenter().postNotificationName("reloadDataCalendar", object: nil, userInfo: ["todo":currentTodo!])
            }

            
        }
       
        self.navigationController!.popViewControllerAnimated(true)
     }
    
    
    func selectedButtonTapped(sender: ButtonWithIndexPath) {
        
        
        for person:Person in persons{
            person.selected = false
        }
        
        let row: Int = sender.indexPath!.row
        let selectedPerson:Person = persons[row]
        selectedPerson.selected = true
 
        
        personsTableView.reloadData()
        

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
