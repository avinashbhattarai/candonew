//
//  TodoViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class TodoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var listTextField: UITextField!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var toDoTableView: UITableView!
    
    var selectedIndex: NSInteger?
    var isHeaderOpened:Bool = false
    
    var lists = [List]()

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
         let backButton = UIButton()
        backButton.setImage(UIImage(named: "iconChevronRightWhite-1"), forState: .Normal)
        backButton.frame = CGRectMake(0, 0, 11, 16)
        backButton.addTarget(self, action: #selector(TodoViewController.backButtonTapped(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: backButton), animated: true);
        
        self.tabBarController?.selectedIndex = selectedIndex!
        
        self.toDoTableView.delegate = self;
        self.toDoTableView.dataSource = self;
        self.toDoTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        if let path = NSBundle.mainBundle().pathForResource("todoResponse", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                do {
                   let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    parseListsResponse(jsonResult)
                    print(lists)
                    
                } catch {}
            } catch {}
        }
        
        
      
    }
    
    
    func parseListsResponse(data:NSDictionary) {
        
       
        if let response : [NSDictionary] = data["lists"] as? [NSDictionary] {
            
            for list: NSDictionary in response {
                if let name : String = list["name"] as? String {
                    
                    let newList = List(name: name)
                    var todosArray = [Todo]()
                    
                    if let todos : [NSDictionary] = list["todos"] as? [NSDictionary] {
                        
                        for todo: NSDictionary in todos {
                            
                            if let todoName: String = todo["name"] as? String{
                                
                                if let personName: String = todo["person"] as? String {
                                    
                                    if let finished: Bool = todo["finished"] as? Bool {
                                        
                                        let person = Person(name: personName, avatar: "img")
                                        let newTodo = Todo(name: todoName, list: newList, finished: finished, assignedPerson: person, date: NSDate())
                                        todosArray.append(newTodo)
                                        
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    newList.todos = todosArray
                    lists.append(newList)
                }
                
            }
            
        }
        
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return lists.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists[section].todos!.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let contentView: UIView = UIView(frame: CGRectMake(0 , 0, self.view.frame.width, 60))
        let listTitle: TodoListSectionTextField = TodoListSectionTextField(frame: CGRectMake(20 , 0, self.view.frame.width-40, 29))
        listTitle.center = CGPointMake(listTitle.center.x, contentView.frame.size.height/2)
        listTitle.text = lists[section].name
        contentView.addSubview(listTitle)
        return contentView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       
            let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TodoTableViewCell
            return cell
    }


    
    
    func backButtonTapped(sender: AnyObject) {
        let nc = (self.tabBarController?.navigationController)! as UINavigationController
        nc.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addNewListTapped(sender: AnyObject) {
        
    }
    
    @IBAction func addLIstButtonTaped(sender: AnyObject) {
        
        var height:CGFloat = 0
        if isHeaderOpened {
            height = 0
            isHeaderOpened = false
            self.listTextField.resignFirstResponder()
        }else{
            height = 100
            isHeaderOpened = true
            self.listTextField.becomeFirstResponder()
        }
        
        
        var newRect = self.toDoTableView.tableHeaderView?.frame
        newRect?.size.height = height
        // Get the reference to the header view
        let tblHeaderView = self.toDoTableView.tableHeaderView
        // Animate the height change
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            tblHeaderView?.frame = newRect!
            self.toDoTableView.tableHeaderView = tblHeaderView
            
        })

        
    }
    @IBAction func suggestionButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier(Helper.SegueKey.kToSuggestionsViewController, sender: self)
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
