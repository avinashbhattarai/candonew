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
class CalendarViewController: BaseViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var todoTableView: UITableView!
    var todos = [Todo]()
    var cellDateFormatter = NSDateFormatter()
    var cellTimeFormatter = NSDateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cellDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        cellTimeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle

      
        todoTableView.delegate = self
        todoTableView.dataSource = self
        print(todoTableView.tableHeaderView)
        
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.headerDateFormat = "MMMM"
        calendarView.headerHeight = 64
        calendarView.appearance.headerTitleFont = UIFont(name: "MuseoSansRounded-500", size: 24)
        calendarView.appearance.weekdayFont = UIFont(name: "MuseoSansRounded-300", size: 20)
        calendarView.appearance.titleFont = UIFont(name: "MuseoSansRounded-300", size: 20)
        calendarView.clipsToBounds = true
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0;
        
    
        let dateString = calendarView.currentPage.toString(format: .Custom("YYYY-MM"))
        
        
        runListsInfoRequest(dateString)
        
    }
    
       
    func runListsInfoRequest(date:String) {
        
        SVProgressHUD.show()
        provider.request(.ListsInfo(date:date)) { result in
            switch result {
            case let .Success(moyaResponse):
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [[String: AnyObject]] else {
                        print("wrong json format")
                       
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
            cell.dateButton.setTitle(String(format: "%@, %@", selectedTime!, selectedDate), forState: .Normal)
            cell.timeButton.setTitle(String(format: "%@", selectedTime!), forState: .Normal)
        }

        cell.dateButton.indexPath = indexPath
        cell.dateButton.addTarget(self, action: #selector(dateButtonTapped(_:)), forControlEvents: .TouchUpInside)
      
       
        
        return cell
    }
   
    func assignTodoButtonTapped(sender: ButtonWithIndexPath) {
        let section :Int = sender.indexPath!.section
        let row: Int = sender.indexPath!.row
        
      //  let list = lists[section]
      //  currentTodo = list.todos![row]
      //  print(currentTodo)
        
        performSegueWithIdentifier(Helper.SegueKey.kToAssignTodoViewController, sender: self)
        
    }
    
    func dateButtonTapped(sender: ButtonWithIndexPath) {
        let section :Int = sender.indexPath!.section
        let row: Int = sender.indexPath!.row
        
       // let list = lists[section]
       // currentTodo = list.todos![row]
       //  print(currentTodo)
        
        performSegueWithIdentifier(Helper.SegueKey.kToSelectTodoDateViewController, sender: self)
        
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
            /*
            if (currentTodo != nil) {
                viewController.currentTodo = currentTodo
            }
 */
            viewController.senderViewController = self
            
            
        }
        
        if segue.identifier == Helper.SegueKey.kToAssignTodoViewController {
            let viewController:AssignTodoViewController = segue.destinationViewController as! AssignTodoViewController
            /*
            if (currentTodo != nil) {
                viewController.currentTodo = currentTodo
            }
 */
             viewController.senderViewController = self
            
            
        }
        
        
    }

}
