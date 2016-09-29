//
//  CalendarViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import FSCalendar
import SVProgressHUD
import ESPullToRefresh
class CalendarViewController: BaseViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UITextFieldDelegate {

    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var todoTableView: UITableView!
    var todos = [Todo]()
    var currentTodo: Todo?
    var cellDateFormatter = NSDateFormatter()
    var cellTimeFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cellDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        cellTimeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle

      
        todoTableView.delegate = self
        todoTableView.dataSource = self
        todoTableView.emptyDataSetSource = self;
        todoTableView.emptyDataSetDelegate = self;
      
        
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.headerDateFormat = "MMMM"
        calendarView.headerHeight = 64
        calendarView.appearance.headerTitleFont = UIFont(name: "MuseoSansRounded-500", size: 24)
        calendarView.appearance.weekdayFont = UIFont(name: "MuseoSansRounded-300", size: 20)
        calendarView.appearance.titleFont = UIFont(name: "MuseoSansRounded-300", size: 20)
        calendarView.clipsToBounds = true
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0;
       
        
        todoTableView.es_addPullToRefresh {
            
            /// Do anything you want...
            /// ...
            let dateString = self.calendarView.currentPage.toString(format: .Custom("YYYY-MM"))
            self.runListsInfoRequest(dateString)
            /// Stop refresh when your job finished, it will reset refresh footer if completion is true
        }

         todoTableView.es_startPullToRefresh()
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadDataCalendar(_:)), name:"reloadDataCalendar", object: nil)
        
    }
    
    func reloadDataCalendar(n: NSNotification) {
        todoTableView.reloadData()
        if (n.userInfo != nil) {
            if let todo = n.userInfo!["todo"] as? Todo{
                
                
                let dateFormatter: NSDateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let timeFormatter: NSDateFormatter = NSDateFormatter()
                timeFormatter.dateFormat = "HH:mm:ss"
                // get the date string applied date format
                var selectedDate:String?
                var selectedTime:String?
                
                if todo.date != nil {
                    selectedDate = dateFormatter.stringFromDate(todo.date!)
                }else{
                    selectedDate = nil
                }
                if todo.time != nil {
                    selectedTime = timeFormatter.stringFromDate(todo.time!)
                }else{
                    selectedTime = nil
                }
                
                runUpdateTodoRequest(todo.name, todoId: todo.todoId, assignToId: todo.assignedTo.personId,assignToName: todo.assignedTo.name, date: selectedDate, time: selectedTime,status: nil, todo: todo)
            }
            
        }
    }

    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView) -> CGFloat {
        return self.calendarView.frame.size.height/2
    }
    func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No todos"
        let attrs = [NSFontAttributeName: UIFont(name: "MuseoSansRounded-300", size: 18)!, NSForegroundColorAttributeName:Helper.Colors.RGBCOLOR(104, green: 104, blue: 104)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView) -> Bool {
        return true
    }
    func runListsInfoRequest(date:String) {
        
        
        provider.request(.ListsInfo(date:date)) { result in
            switch result {
            case let .Success(moyaResponse):
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [[String: AnyObject]] else {
                        print("wrong json format")
                       self.todoTableView.es_stopPullToRefresh(completion: true)
                        SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                        return;
                    }
                    
                    self.todos = [Todo]()
                    for list: NSDictionary in json {
                        if let listId = list["id"] as? Int {
                            let newList = List(name: list["name"] as? String, listId: listId)
                            if let todos = list["todo"] as? [[String: AnyObject]] {
                                for todo: NSDictionary in todos {
                                    if let todoId = todo["id"] as? Int {
                                        var person:Person?
                                        if let assignedToId = todo["assign_to_id"] as? Int {
                                            person = Person(name: todo["assign_to_name"] as? String, personId: assignedToId)
                                        }else{
                                            person = Person(name: nil, personId: 0)
                                        }
                                        let newTodo = Todo(name: todo["todo"] as? String, list: newList, updatedAt: todo["updated_at"] as? String , createdAt: todo["created_at"] as? String, date: todo["date"] as? String, time:todo["time"] as? String, status: todo["status"] as? String, todoId: todoId, assignedTo: person!)
                                        self.todos.append(newTodo)
                                    }
                                    
                                }
                            }
                           
                        }
                    }
                    self.calendarView.reloadData()
                    self.todoTableView.reloadData()
                    self.todoTableView.es_stopPullToRefresh(completion: true)
                    
                }
                catch {
                    
                    guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
                        let item = json[0] as? [String: AnyObject],
                        let message = item["message"] as? String else {
                            self.todoTableView.es_stopPullToRefresh(completion: true)
                            SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                            return;
                    }
                    self.todoTableView.es_stopPullToRefresh(completion: true)
                    SVProgressHUD.showErrorWithStatus("\(message)")
                    
                    
                }
                
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                self.todoTableView.es_stopPullToRefresh(completion: true)
                SVProgressHUD.showErrorWithStatus("\(error.description)")
               
                
            }
        }
        
    }
    func calendarCurrentPageDidChange(calendar: FSCalendar) {
        let dateString = calendarView.currentPage.toString(format: .Custom("YYYY-MM"))
        runListsInfoRequest(dateString)
    }
  
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        print(date)
    }
   
    func calendar(calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsForDate date: NSDate) -> [UIColor]?{
        print("color")
      
        var set = Set<UIColor>()
        for todo:Todo in todos {
            if (todo.date != nil) {
                if NSCalendar.currentCalendar().isDate(todo.date!, inSameDayAsDate:date) {
                    if todo.assignedTo.personId == 0 {
                        set.insert(Helper.Colors.RGBCOLOR(167, green: 90, blue: 255))
                    }else if todo.assignedTo.personId == (Helper.UserDefaults.kStandardUserDefaults.valueForKey(Helper.UserDefaults.kUserId) as? Int){
                        set.insert(Helper.Colors.RGBCOLOR(13, green: 218, blue: 157))
                    }else{
                        set.insert(Helper.Colors.RGBCOLOR(185, green: 212, blue: 214))
                    }
                }
            }
        }
        return Array(set)
    }
    func calendar(calendar: FSCalendar, appearance: FSCalendarAppearance, eventOffsetForDate date: NSDate) -> CGPoint{
        return CGPointMake(0, -5)
    }
    func calendar(calendar: FSCalendar, shouldSelectDate date: NSDate) -> Bool{
        return false
    }
    
    func calendar(calendar: FSCalendar, numberOfEventsForDate date: NSDate) -> Int {
        var events = [Todo]()
        for todo:Todo in todos {
            if (todo.date != nil) {
                if NSCalendar.currentCalendar().isDate(todo.date!, inSameDayAsDate:date) {
                    events.append(todo)
                }
            }
        }
        
        return events.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 74
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let todo: Todo = todos[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CalendarTodoTableViewCell
        
        cell.todoName.text = todo.name
        cell.todoName.delegate = self
        cell.todoName.indexPath = indexPath
        cell.assignPersonButton.setTitle(todo.assignedTo.name, forState: .Normal)
        cell.assignPersonButton.indexPath = indexPath
        cell.assignPersonButton.addTarget(self, action: #selector(assignTodoButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        if todo.assignedTo.personId == 0 {
            cell.dateButton.setTitleColor(Helper.Colors.RGBCOLOR(167, green: 90, blue: 255), forState: .Normal)
            cell.assignPersonButton.setTitleColor(Helper.Colors.RGBCOLOR(167, green: 90, blue: 255), forState: .Normal)
            cell.timeButton.setTitleColor(Helper.Colors.RGBCOLOR(167, green: 90, blue: 255), forState: .Normal)
        }else{
            cell.dateButton.setTitleColor(Helper.Colors.RGBCOLOR(135, green: 135, blue: 135), forState: .Normal)
            cell.assignPersonButton.setTitleColor(Helper.Colors.RGBCOLOR(135, green: 135, blue: 135), forState: .Normal)
            cell.timeButton.setTitleColor(Helper.Colors.RGBCOLOR(135, green: 135, blue: 135), forState: .Normal)
        }

        
        
        if todo.date == nil {
            cell.dateButton.setTitle("Anytime", forState: .Normal)
        }else{
            let selectedDate = cellDateFormatter.stringFromDate(todo.date!)
            
            var selectedTime:String?
            if todo.time == nil {
                selectedTime = "Any time"
            }else{
                selectedTime = cellTimeFormatter.stringFromDate(todo.time!)
            }
            cell.dateButton.setTitle(String(format: "%@", selectedDate), forState: .Normal)
            cell.timeButton.setTitle(String(format: "%@", selectedTime!), forState: .Normal)
        }

        cell.dateButton.indexPath = indexPath
        cell.dateButton.addTarget(self, action: #selector(dateButtonTapped(_:)), forControlEvents: .TouchUpInside)
      
       
        
        return cell
    }
   
    func assignTodoButtonTapped(sender: ButtonWithIndexPath) {
        let row: Int = sender.indexPath!.row
        currentTodo = todos[row]
        print(currentTodo)
        
        performSegueWithIdentifier(Helper.SegueKey.kToAssignTodoViewController, sender: self)
        
    }
    
    func dateButtonTapped(sender: ButtonWithIndexPath) {
        let row: Int = sender.indexPath!.row
        currentTodo = todos[row]
        
        performSegueWithIdentifier(Helper.SegueKey.kToSelectTodoDateViewController, sender: self)
        
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if let todoName = textField as? TodoNameTextField {
            
            todoName.resignFirstResponder()
            let row: Int = todoName.indexPath!.row
            let todo = todos[row]
            var todoTitle:String?
            if todoName.hasText() {
                todoTitle = todoName.text
            }else{
                todoTitle = "Untitled To Do"
            }
            
            
            runUpdateTodoRequest(todoTitle!, todoId: todo.todoId, assignToId: nil, assignToName: nil, date: nil, time: nil, status: nil,todo: todo)
            
        }
        
        return false
    }

    func runUpdateTodoRequest(todoName: String, todoId: Int, assignToId: Int?,assignToName: String?, date:String?, time:String?, status:String?, todo:Todo) {
        
        SVProgressHUD.show()
        provider.request(.UpdateTodo(todoId: todoId, name: todoName, assign_to: assignToId, date: date, time: time, status:status)) { result in
            switch result {
            case let .Success(moyaResponse):
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject] else {
                        print("wrong json format")
                        SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                        return;
                    }
                    if let todoId = json["id"] as? Int {
                        var person:Person?
                        if let assignedToId = json["assign_to_id"] as? Int {
                            person = Person(name: json["assign_to_name"] as? String, personId: assignedToId)
                            
                        }else{
                            
                            person = Person(name: nil, personId: 0)
                        }
                        
                        let newDate = json["date"] as? String
                        let newTime = json["time"] as? String
                        let newUpdatedAt = json["updated_at"] as? String
                        let newCreatedAt = json["created_at"] as? String
                        
                        todo.assignedTo = person
                        todo.name = json["todo"] as? String ?? ""
                        todo.date = newDate != nil ? self.stringDateToDate(newDate!) : nil
                        todo.time = newTime != nil ? self.stringTimeToDate(newTime!) : nil
                        todo.updatedAt = newUpdatedAt != nil ? self.stringCreateUpdateToDate(newUpdatedAt!) : nil
                        todo.createdAt = newCreatedAt != nil ? self.stringCreateUpdateToDate(newCreatedAt!) : nil
                        todo.todoId = todoId
                        todo.status = json["status"] as? String ?? Helper.TodoStatusKey.kActive
                        if (todo.date != nil){
                            if !todo.date!.isSameMonthAsDate(self.calendarView.currentPage){
                                if let index = self.todos.indexOf({$0.todoId == todo.todoId}) {
                                    self.todos.removeAtIndex(index)
                                }
                            }
                        }
                        
                        self.todoTableView.reloadData()
                        self.calendarView.reloadData()
                        SVProgressHUD.dismiss()
                        
                    }
                    
                    
                    
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
    
    func stringCreateUpdateToDate(stringDate: String) -> NSDate {
        return NSDate(fromString:stringDate, format: .Custom("yyyy-MM-dd HH:mm:ss"))
    }
    
    func stringDateToDate(stringDate: String) -> NSDate {
        return NSDate(fromString:stringDate, format: .Custom("yyyy-MM-dd"))
    }
    func stringTimeToDate(stringDate: String) -> NSDate {
        return NSDate(fromString:stringDate, format: .Custom("HH:mm:ss"))
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
 
            viewController.senderViewController = self
            
            
        }
        
        if segue.identifier == Helper.SegueKey.kToAssignTodoViewController {
            let viewController:AssignTodoViewController = segue.destinationViewController as! AssignTodoViewController
            
            if (currentTodo != nil) {
                viewController.currentTodo = currentTodo
            }
 
             viewController.senderViewController = self
            
            
        }
        
        
    }

}
