//
//  TodoViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import SVProgressHUD
import IQKeyboardManagerSwift
class TodoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate{
    
    @IBOutlet weak var listTextField: UITextField!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var toDoTableView: UITableView!
    
    var selectedIndex: NSInteger?
    var isHeaderOpened:Bool = false
    var currentTodo: Todo?
    
    
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
        
       // IQKeyboardManager.sharedManager().toolbarDoneBarButtonItemText = "Hide"
        
        self.toDoTableView.delegate = self;
        self.toDoTableView.dataSource = self;
        self.toDoTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        let nib = UINib(nibName: "TodoSectionFooter", bundle: nil)
        self.toDoTableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "TodoSectionFooter")
        
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
                                        let newTodo = Todo(name: todoName, list: newList, finished: finished)
                                        newTodo.assignedPerson = person
                                        newTodo.date = NSDate()
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
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 90
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let contentView: UIView = UIView(frame: CGRectMake(0 , 0, self.view.frame.width, 60))
        contentView.backgroundColor = Helper.Colors.RGBCOLOR(250, green: 255, blue: 254)
        let listTitle: TodoListSectionTextField = TodoListSectionTextField(frame: CGRectMake(20 , 0, self.view.frame.width-40, 29))
        listTitle.center = CGPointMake(listTitle.center.x, contentView.frame.size.height/2)
        listTitle.text = lists[section].name
        listTitle.placeholder = "List title"
        listTitle.tag = section
        listTitle.delegate = self
        listTitle.returnKeyType = .Done
        contentView.addSubview(listTitle)
        return contentView
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
       
        // Dequeue with the reuse identifier
        let cell = self.toDoTableView.dequeueReusableHeaderFooterViewWithIdentifier("TodoSectionFooter")
        let footer = cell as! TodoTableSectionFooter
        footer.addTodoButton.tag = section
        footer.dateButton.tag = section
        footer.addNewTodoButton.tag = section
        footer.titleTextField.tag = section
        footer.titleTextField.delegate = self
        footer.dateButton.addTarget(self, action:#selector(TodoViewController.dateNewTodoButtonTapped(_:)), forControlEvents: .TouchUpInside)
        footer.assignTodoButton.addTarget(self, action:#selector(TodoViewController.assignNewTodoButtonTapped(_:)), forControlEvents: .TouchUpInside)
        footer.addNewTodoButton.addTarget(self, action:#selector(TodoViewController.addNewTodoButtonTapped(_:)), forControlEvents: .TouchUpInside)
        footer.addTodoButton.addTarget(self, action:#selector(TodoViewController.addTodoTapped(_:)), forControlEvents: .TouchUpInside)
        return footer
 
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let todo : Todo = lists[indexPath.section].todos![indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TodoTableViewCell
        
        if todo.finished! {
            print(indexPath)
            cell.selectedButton .setImage(UIImage(named:"iconHelpAssignTickCopy"), forState: .Normal)
        }else{
            cell.selectedButton .setImage(UIImage(), forState: .Normal)
        }

        cell.titleTextField.text = todo.name
        cell.titleTextField.indexPath = indexPath
        cell.titleTextField.delegate = self
        cell.selectedButton.indexPath = indexPath
        cell.dateButton.indexPath = indexPath
        cell.assignedPersonButton.indexPath = indexPath
        
        cell.dateButton.addTarget(self, action: #selector(TodoViewController.dateButtonTapped(_:)), forControlEvents: .TouchUpInside)
        cell.selectedButton.addTarget(self, action: #selector(TodoViewController.selectedButtonTapped(_:)), forControlEvents: .TouchUpInside)
        cell.assignedPersonButton.setTitle(todo.assignedPerson?.name, forState: .Normal)
        cell.assignedPersonButton.addTarget(self, action: #selector(TodoViewController.assignTodoButtonTapped(_:)), forControlEvents: .TouchUpInside)

        return cell
    }
    
    
    func assignNewTodoButtonTapped(sender: DateUnderlineButton) {
        
        currentTodo = nil
        let section :Int = sender.tag
        let list = lists[section]
        print(list)
        performSegueWithIdentifier(Helper.SegueKey.kToAssignTodoViewController, sender: self)
        
    }

    
    
    func assignTodoButtonTapped(sender: ButtonWithIndexPath) {
        let section :Int = sender.indexPath!.section
        let row: Int = sender.indexPath!.row
        let list = lists[section]
        currentTodo = list.todos![row]
        print(currentTodo)
        performSegueWithIdentifier(Helper.SegueKey.kToAssignTodoViewController, sender: self)
        
    }

    
    
    func dateNewTodoButtonTapped(sender: DateUnderlineButton) {
        
        currentTodo = nil
        let section :Int = sender.tag
        let list = lists[section]
        print(list)
        performSegueWithIdentifier(Helper.SegueKey.kToSelectTodoDateViewController, sender: self)
        
    }

    
    
    func dateButtonTapped(sender: ButtonWithIndexPath) {
        let section :Int = sender.indexPath!.section
        let row: Int = sender.indexPath!.row
        let list = lists[section]
        currentTodo = list.todos![row]
       print(currentTodo)
        performSegueWithIdentifier(Helper.SegueKey.kToSelectTodoDateViewController, sender: self)
        
    }

    
    func selectedButtonTapped(sender: ButtonWithIndexPath) {
        let section :Int = sender.indexPath!.section
        let row: Int = sender.indexPath!.row
        let list = lists[section]
        let todo = list.todos![row]
        todo.finished = !todo.finished
        self.toDoTableView.reloadRowsAtIndexPaths([sender.indexPath!], withRowAnimation: .Automatic)
        
    }
    
    
    func  addNewTodoButtonTapped(sender: UIButton) {
        
        if let footer = self.toDoTableView.footerViewForSection(sender.tag) as? TodoTableSectionFooter{
    
                let section :Int = sender.tag
                let list = lists[section]
                let newTodo = Todo(name: footer.titleTextField.text!, list: list)
                let person = Person(name: footer.assignTodoButton.titleLabel!.text!, avatar: "img")
                newTodo.date = NSDate()
                newTodo.assignedPerson = person
                list.todos?.append(newTodo)
                self.toDoTableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .Automatic)
                
                let lastRow: Int = self.toDoTableView.numberOfRowsInSection(section)-1
                self.toDoTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lastRow, inSection: section), atScrollPosition: .Bottom, animated: true)
            }
    }


   func addTodoTapped(sender: UIButton) {
    print(sender.superview)
    sender.hidden = true
    
    if let footer =  sender.superview as? TodoTableSectionFooter{
        footer.addTodoView.hidden = false
        footer.titleTextField.becomeFirstResponder()
    }
    
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
       
            if let todoName = textField as? TodoNameTextField {
                print("show \(todoName.indexPath)")
                self.toDoTableView.footerViewForSection(todoName.indexPath!.section)?.hidden = true
                
            }
        

    }
        
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let todoName = textField as? TodoNameTextField {
            print("hide \(todoName.indexPath)")
            self.toDoTableView.footerViewForSection(todoName.indexPath!.section)?.hidden = false
        }
    }
   
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        
        if textField is TodoListSectionTextField {
            if textField.hasText() {
            textField.resignFirstResponder()
            let section :Int = textField.tag
            let list = lists[section]
            list.name = textField.text
            self.toDoTableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .Automatic)
            }
        }
        
      
            if let todoName = textField as? TodoNameTextField {
                if todoName.hasText() {
                    todoName.resignFirstResponder()
                    let section :Int = todoName.indexPath!.section
                    let row: Int = todoName.indexPath!.row
                    let list = lists[section]
                    let todo = list.todos![row]
                    todo.name = todoName.text
                    self.toDoTableView.reloadRowsAtIndexPaths([todoName.indexPath!], withRowAnimation: .Automatic)
                }

            }
        

        

        
        return false
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
        
        if !self.listTextField.hasText() {
            SVProgressHUD.showErrorWithStatus("List field is empty")
            return
        }
        
         let newList = List(name: self.listTextField.text!)
        newList.todos = [Todo]()
        lists.insert(newList, atIndex: 0)
        
        self.listTextField.text = ""
         self.toDoTableView.reloadData()
        
        addLIstButtonTaped(UIButton())
        
        
        
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
    
    
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == Helper.SegueKey.kToSelectTodoDateViewController {
            let viewController:SelectTodoDateViewController = segue.destinationViewController as! SelectTodoDateViewController
            if (currentTodo != nil) {
                viewController.currentTodo = currentTodo
            }
            
            
        }
        
        if segue.identifier == Helper.SegueKey.kToAssignTodoViewController {
            let viewController:AssignTodoViewController = segue.destinationViewController as! AssignTodoViewController
            if (currentTodo != nil) {
                viewController.currentTodo = currentTodo
            }
            
            
        }

        
    }
    

}
