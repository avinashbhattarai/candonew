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
import EventKit
class CalendarViewController: BaseViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UITextFieldDelegate {

   
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var todoTableView: UITableView!
    var todos = [Todo]()
    var currentTodo: Todo?
    var cellDateFormatter = DateFormatter()
    var cellTimeFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cellDateFormatter.dateStyle = DateFormatter.Style.medium
        cellTimeFormatter.timeStyle = DateFormatter.Style.short

       
      
        todoTableView.delegate = self
        todoTableView.dataSource = self
        todoTableView.emptyDataSetSource = self;
        todoTableView.emptyDataSetDelegate = self;
      
        
        calendarView.delegate = self
        calendarView.dataSource = self
        //calendarView.headerDateFormat = "MMMM"
        calendarView.headerHeight = 64
        calendarView.appearance.headerTitleFont = UIFont(name: "MuseoSansRounded-500", size: 24)
        calendarView.appearance.weekdayFont = UIFont(name: "MuseoSansRounded-300", size: 20)
        calendarView.appearance.titleFont = UIFont(name: "MuseoSansRounded-300", size: 20)
        calendarView.clipsToBounds = true
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0;
       
        
        _ = todoTableView.es_addPullToRefresh {
            
            /// Do anything you want...
            /// ...
            let dateString = self.calendarView.currentPage.toString(.custom("YYYY-MM"))
            self.runListsInfoRequest(dateString)
            /// Stop refresh when your job finished, it will reset refresh footer if completion is true
        }

         
      NotificationCenter.default.addObserver(self, selector: #selector(reloadDataCalendar(_:)), name:NSNotification.Name(rawValue: "reloadDataCalendar"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        todoTableView.es_startPullToRefresh()
    }
    
    func reloadDataCalendar(_ n: Foundation.Notification) {
        todoTableView.reloadData()
        if ((n as NSNotification).userInfo != nil) {
            if let todo = (n as NSNotification).userInfo!["todo"] as? Todo{
                updateTodo(todo)
            }
            
        }
    }
    
    func updateTodo(_ todo : Todo){
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter: DateFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        // get the date string applied date format
        var selectedDate:String?
        var selectedTime:String?
        
        if todo.date != nil {
            selectedDate = dateFormatter.string(from: todo.date! as Date)
        }else{
            selectedDate = nil
        }
        if todo.time != nil {
            selectedTime = timeFormatter.string(from: todo.time! as Date)
        }else{
            selectedTime = nil
        }
        
        runUpdateTodoRequest(todo.name, todoId: todo.todoId, assignToId: todo.assignedTo.personId,assignToName: todo.assignedTo.name, date: selectedDate, time: selectedTime,status: nil, todo: todo)
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return self.calendarView.frame.size.height/2
    }
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No to do"
        let attrs = [NSFontAttributeName: UIFont(name: "MuseoSansRounded-300", size: 18)!, NSForegroundColorAttributeName:Helper.Colors.RGBCOLOR(104, green: 104, blue: 104)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    func runListsInfoRequest(_ date:String) {
        
        
        provider.request(.listsInfo(date:date)) { result in
            switch result {
            case let .success(moyaResponse):
                
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [[String: AnyObject]] else {
                        print("wrong json format")
                       self.todoTableView.es_stopPullToRefresh(completion: true)
                        SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                        return;
                    }
                    
                    self.todos = [Todo]()
                    for list: Dictionary in json {
                        if let listId = list["id"] as? Int {
                            let newList = List(name: list["name"] as? String, listId: listId)
                            if let todos = list["todo"] as? [[String: AnyObject]] {
                                for todo: Dictionary in todos {
                                    if let todoId = todo["id"] as? Int {
                                        var person:Person?
                                        if let assignedToId = todo["assign_to_id"] as? Int {
                                            person = Person(name: todo["assign_to_name"] as? String, personId: assignedToId, avatar:"")
                                        }else{
                                            person = Person(name: nil, personId: 0, avatar:"")
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
                           // SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                            self.todos.removeAll()
                            self.calendarView.reloadData()
                            self.todoTableView.reloadData()
                            return;
                    }
                    self.todoTableView.es_stopPullToRefresh(completion: true)
                    SVProgressHUD.showError(withStatus: "\(message)")
                    
                    
                }
                
            case let .failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print(error.description)
                self.todoTableView.es_stopPullToRefresh(completion: true)
                SVProgressHUD.showError(withStatus: "\(error.description)")
               
                
            }
        }
        
    }
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let dateString = calendarView.currentPage.toString(.custom("YYYY-MM"))
        runListsInfoRequest(dateString)
    }
  
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        print(date)
    }
   
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]?{
        print("color")
      
        var set = Set<UIColor>()
        for todo:Todo in todos {
            if (todo.date != nil) {
                if Calendar.current.isDate(todo.date! as Date, inSameDayAs:date) {
                    if todo.assignedTo.personId == 0 {
                        set.insert(Helper.Colors.RGBCOLOR(167, green: 90, blue: 255))
                    }else if todo.assignedTo.personId == (Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kUserId) as? Int){
                        set.insert(Helper.Colors.RGBCOLOR(13, green: 218, blue: 157))
                    }else{
                        set.insert(Helper.Colors.RGBCOLOR(185, green: 212, blue: 214))
                    }
                }
            }
        }
        return Array(set)
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventOffsetFor date: Date) -> CGPoint{
        return CGPoint(x: 0, y: -5)
    }
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date) -> Bool{
        return false
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var events = [Todo]()
        for todo:Todo in todos {
            if (todo.date != nil) {
                if Calendar.current.isDate(todo.date! as Date, inSameDayAs:date) {
                    events.append(todo)
                }
            }
        }
        
        return events.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let todo: Todo = todos[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CalendarTodoTableViewCell
        cell.selectionStyle = .none
        cell.todoName.text = todo.name
        cell.todoName.delegate = self
        cell.todoName.indexPath = indexPath
        cell.assignPersonButton.setTitle(todo.assignedTo.name, for: UIControlState())
        cell.assignPersonButton.indexPath = indexPath
        cell.assignPersonButton.addTarget(self, action: #selector(assignTodoButtonTapped(_:)), for: .touchUpInside)
        
        if todo.assignedTo.personId == 0 {
            cell.dateButton.setTitleColor(Helper.Colors.RGBCOLOR(167, green: 90, blue: 255), for: UIControlState())
            cell.assignPersonButton.setTitleColor(Helper.Colors.RGBCOLOR(167, green: 90, blue: 255), for: UIControlState())
            cell.timeButton.setTitleColor(Helper.Colors.RGBCOLOR(167, green: 90, blue: 255), for: UIControlState())
        }else{
            cell.dateButton.setTitleColor(Helper.Colors.RGBCOLOR(135, green: 135, blue: 135), for: UIControlState())
            cell.assignPersonButton.setTitleColor(Helper.Colors.RGBCOLOR(135, green: 135, blue: 135), for: UIControlState())
            cell.timeButton.setTitleColor(Helper.Colors.RGBCOLOR(135, green: 135, blue: 135), for: UIControlState())
        }
        if todo.assignedTo.personId == (Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kUserId) as? Int){
            cell.syncButton.isHidden = false
        }else{
            cell.syncButton.isHidden = true
        }
        
        cell.syncButton.tag = (indexPath as NSIndexPath).row
        cell.syncButton.addTarget(self, action: #selector(syncButtonTapped(_:)), for: .touchUpInside)
        
        
        if todo.date == nil {
            cell.dateButton.setTitle("Anytime", for: UIControlState())
        }else{
            let selectedDate = cellDateFormatter.string(from: todo.date! as Date)
            
            var selectedTime:String?
            if todo.time == nil {
                selectedTime = "Any time"
            }else{
                selectedTime = cellTimeFormatter.string(from: todo.time! as Date)
            }
            cell.dateButton.setTitle(String(format: "%@", selectedDate), for: UIControlState())
            cell.timeButton.setTitle(String(format: "%@", selectedTime!), for: UIControlState())
        }

        cell.dateButton.indexPath = indexPath
        cell.dateButton.addTarget(self, action: #selector(dateButtonTapped(_:)), for: .touchUpInside)
        cell.timeButton.indexPath = indexPath
        cell.timeButton.addTarget(self, action: #selector(dateButtonTapped(_:)), for: .touchUpInside)
      
       
        
        return cell
    }
     func syncButtonTapped(_ sender: UIButton) {
        
        let optionMenu = UIAlertController(title: nil, message: "Create Event or Reminder in native Calendar or Reminders Apps", preferredStyle: .actionSheet)
        
        // 2
        let createEventAction = UIAlertAction(title: "Create Event", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.prepareForEventCreation(sender.tag)
           
        })
        let createReminderAction = UIAlertAction(title: "Create Reminder", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.prepareForReminderCreation(sender.tag)
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        // 4
        optionMenu.addAction(createEventAction)
        optionMenu.addAction(createReminderAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func prepareForReminderCreation(_ senderTag:Int){
        let todo:Todo = self.todos[senderTag]
        var newDate:Date?
        if ((todo.time) != nil) {
            let calendar = Calendar.current
            let timeComp = (calendar as NSCalendar).components([.hour, .minute, .second], from: (todo.time)! as Date)
            let dateComp = (calendar as NSCalendar).components([.year, .month, .day], from: (todo.date)! as Date)
            let date = calendar.date(from: dateComp)
            newDate = (calendar as NSCalendar).date(byAdding: timeComp, to: date!, options: NSCalendar.Options(rawValue: 0))
        }else{
            newDate = todo.date as Date?
        }
        let eventStore = EKEventStore()
    
        eventStore.requestAccess(to: EKEntityType.reminder, completion: {
            granted, error in

            
            if granted{
                
                let reminder = EKReminder(eventStore: eventStore)
                reminder.title = todo.name
                reminder.dueDateComponents = self.dateComponentFromNSDate(newDate!)
                reminder.calendar = eventStore.defaultCalendarForNewReminders()
                do {
                    try eventStore.save(reminder, commit: true)
                    SVProgressHUD.showSuccess(withStatus: "Done.\nPlease check native app.")
                }catch{
                    SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                }
  
            }else{
                SVProgressHUD.showError(withStatus: "The app is not permitted to access reminders, make sure to grant permission in the settings and try again")
            }
        })
    }
    
    func dateComponentFromNSDate(_ date: Date)-> DateComponents{
        
        let calendarUnit: NSCalendar.Unit = [.minute ,.hour, .day, .month, .year]
        let dateComponents = (Calendar.current as NSCalendar).components(calendarUnit, from: date)
        
        
        return dateComponents
    }

    func prepareForEventCreation(_ senderTag:Int){
        
        let todo:Todo = self.todos[senderTag]
        var newDate:Date?
        if ((todo.time) != nil) {
            let calendar = Calendar.current
            let timeComp = (calendar as NSCalendar).components([.hour, .minute, .second], from: (todo.time)! as Date)
            let dateComp = (calendar as NSCalendar).components([.year, .month, .day], from: (todo.date)! as Date)
            let date = calendar.date(from: dateComp)
            newDate = (calendar as NSCalendar).date(byAdding: timeComp, to: date!, options: NSCalendar.Options(rawValue: 0))
        }else{
            newDate = todo.date as Date?
        }
        let eventStore = EKEventStore()
        let startDate = newDate
        let endDate = newDate

        
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            granted, error in
            if granted{
               self.createEvent(eventStore, title: todo.name, startDate: startDate ?? Date(), endDate: endDate ?? Date())
            }else{
                SVProgressHUD.showError(withStatus: "The app is not permitted to access reminders, make sure to grant permission in the settings and try again")
            }
        })

        /*
        
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event, completion: {
                granted, error in
                self.createEvent(eventStore, title: todo.name, startDate: startDate ?? Date(), endDate: endDate ?? Date())
            })
        } else {
            SVProgressHUD.showError(withStatus: "The app is not permitted to access calendar, make sure to grant permission in the settings and try again")
        }
 */

    }
    
    // Creates an event in the EKEventStore. The method assumes the eventStore is created and
    // accessible
    func createEvent(_ eventStore: EKEventStore, title: String, startDate: Date, endDate: Date) {
        let event = EKEvent(eventStore: eventStore)
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            print(event)
            try eventStore.save(event, span: .thisEvent)
           SVProgressHUD.showSuccess(withStatus: "Done.\nPlease check native app.")
        } catch {
            SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
        }
    }

    
    
    func assignTodoButtonTapped(_ sender: ButtonWithIndexPath) {
        let row: Int = (sender.indexPath! as NSIndexPath).row
        currentTodo = todos[row]
        print(currentTodo)
        
        
        if let todo = currentTodo{
            
            let isUserGroupOwner = Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kIsUserGroupOwner) as? Bool ?? false
            if !isUserGroupOwner && todo.assignedTo.personId == 0 {
                todo.assignedTo = createCurrentUserModel()
                
                updateTodo(todo)
                return
            }
            if !isUserGroupOwner && todo.assignedTo.personId > 0 {
                return
            }

        
        performSegue(withIdentifier: Helper.SegueKey.kToAssignTodoViewController, sender: self)
        }
        
    }
    
    func createCurrentUserModel() -> Person {
        let myName = String(format: "%@ %@", (Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kUserFirstName) as? String) ?? "", (Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kUserLastName) as? String) ?? "")
        let userId = Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kUserId) as? Int ?? 0
        let avatar = Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kUserAvatar) as? String
        
        return Person(name: myName, personId: userId, avatar: avatar)
    }

    
    func dateButtonTapped(_ sender: ButtonWithIndexPath) {
        let row: Int = (sender.indexPath! as NSIndexPath).row
        currentTodo = todos[row]
        
        let isUserGroupOwner = Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kIsUserGroupOwner) as? Bool ?? false
        if !isUserGroupOwner{
            return
        }

        
        performSegue(withIdentifier: Helper.SegueKey.kToSelectTodoDateViewController, sender: self)
        
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField is TodoNameTextField  {
            let isUserGroupOwner = Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kIsUserGroupOwner) as? Bool ?? false
            
            if !isUserGroupOwner {
                return false
            }
            
        }
        return true
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let todoName = textField as? TodoNameTextField {
            
            todoName.resignFirstResponder()
            let row: Int = (todoName.indexPath! as NSIndexPath).row
            let todo = todos[row]
            var todoTitle:String?
            if todoName.hasText {
                todoTitle = todoName.text
            }else{
                todoTitle = "Untitled To Do"
            }
            
            
            runUpdateTodoRequest(todoTitle!, todoId: todo.todoId, assignToId: nil, assignToName: nil, date: nil, time: nil, status: nil,todo: todo)
            
        }
        
        return false
    }

    func runUpdateTodoRequest(_ todoName: String, todoId: Int, assignToId: Int?,assignToName: String?, date:String?, time:String?, status:String?, todo:Todo) {
        
        SVProgressHUD.show()
        provider.request(.updateTodo(todoId: todoId, name: todoName, assign_to: assignToId, date: date, time: time, status:status)) { result in
            switch result {
            case let .success(moyaResponse):
                
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject] else {
                        print("wrong json format")
                        SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                        return;
                    }
                    if let todoId = json["id"] as? Int {
                        var person:Person?
                        if let assignedToId = json["assign_to_id"] as? Int {
                            person = Person(name: json["assign_to_name"] as? String, personId: assignedToId, avatar:"")
                            
                        }else{
                            
                            person = Person(name: nil, personId: 0, avatar:"")
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
                                if let index = self.todos.index(where: {$0.todoId == todo.todoId}) {
                                    self.todos.remove(at: index)
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
                            SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                            return;
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
    
    func stringCreateUpdateToDate(_ stringDate: String) -> Date {
        return Date(fromString: stringDate, format: .custom("yyyy-MM-dd HH:mm:ss"))
    }
    
    func stringDateToDate(_ stringDate: String) -> Date {
        return Date(fromString: stringDate, format: .custom("yyyy-MM-dd"))
    }
    func stringTimeToDate(_ stringDate: String) -> Date {
        return Date(fromString: stringDate, format: .custom("HH:mm:ss"))
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == Helper.SegueKey.kToSelectTodoDateViewController {
            let viewController:SelectTodoDateViewController = segue.destination as! SelectTodoDateViewController
            
            if (currentTodo != nil) {
                viewController.currentTodo = currentTodo
            }
 
            viewController.senderViewController = self
            
            
        }
        
        if segue.identifier == Helper.SegueKey.kToAssignTodoViewController {
            let viewController:AssignTodoViewController = segue.destination as! AssignTodoViewController
            
            if (currentTodo != nil) {
                viewController.currentTodo = currentTodo
            }
 
             viewController.senderViewController = self
            
            
        }
        
        
    }

}
