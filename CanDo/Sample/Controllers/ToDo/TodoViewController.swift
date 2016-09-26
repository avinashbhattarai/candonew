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
import Moya
import ESPullToRefresh


class TodoViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

	@IBOutlet weak var listTextField: UITextField!
	@IBOutlet weak var headerView: UIView!
	@IBOutlet weak var toDoTableView: UITableView!
    
    var cellDateFormatter = NSDateFormatter()
    var cellTimeFormatter = NSDateFormatter()

	var selectedIndex: NSInteger?
	var isHeaderOpened: Bool = false
	var currentTodo: Todo?
	var lists = [List]()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.tabBarController?.selectedIndex = selectedIndex!
		// IQKeyboardManager.sharedManager().toolbarDoneBarButtonItemText = "Hide"
		toDoTableView.delegate = self;
		toDoTableView.dataSource = self;
        toDoTableView.emptyDataSetSource = self;
        toDoTableView.emptyDataSetDelegate = self;
		toDoTableView.separatorStyle = UITableViewCellSeparatorStyle.None

		let nib = UINib(nibName: "TodoSectionFooter", bundle: nil)
		toDoTableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "TodoSectionFooter")
        
        cellDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        cellTimeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle

        
		toDoTableView.es_addPullToRefresh {

			/// Do anything you want...
			/// ...
			self.runListsInfoRequest()
			/// Stop refresh when your job finished, it will reset refresh footer if completion is true

		}

		
        toDoTableView.es_startPullToRefresh()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadDataTodo(_:)), name:"reloadDataTodo", object: nil)
       
	}
    override func viewWillAppear(animated: Bool) {
       
    }
    
    func reloadDataTodo(n: NSNotification) {
        toDoTableView.reloadData()
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
    
	func runListsInfoRequest() {

		
        provider.request(.ListsInfo(date:nil)) { result in
			switch result {
			case let .Success(moyaResponse):

				do {
					try moyaResponse.filterSuccessfulStatusCodes()
					guard let json = moyaResponse.data.nsdataToJSON() as? [[String: AnyObject]] else {
						print("wrong json format")
                        self.toDoTableView.es_stopPullToRefresh(completion: true)
						SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
						return;
					}
                    self.lists = [List]()
					for list: NSDictionary in json {
						if let listId = list["id"] as? Int {
							let newList = List(name: list["name"] as? String, listId: listId)
							var todosArray = [Todo]()
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
                                        todosArray.append(newTodo)
									}

								}
							}
                            newList.todos = todosArray
                            self.lists.append(newList)
						}
					}

                    self.toDoTableView.reloadData()
					SVProgressHUD.dismiss()
					self.toDoTableView.es_stopPullToRefresh(completion: true)

				}
				catch {

					guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
						let item = json[0] as? [String: AnyObject],
						let message = item["message"] as? String else {
							SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
							self.toDoTableView.es_stopPullToRefresh(completion: true)
							return;
					}
					SVProgressHUD.showErrorWithStatus("\(message)")
					self.toDoTableView.es_stopPullToRefresh(completion: true)

				}

			case let .Failure(error):
				guard let error = error as? CustomStringConvertible else {
					break
				}
				print(error.description)
				SVProgressHUD.showErrorWithStatus("\(error.description)")
				self.toDoTableView.es_stopPullToRefresh(completion: true)

			}
		}

	}
    func cleanFooterView(footer: TodoTableSectionFooter){
        
        footer.addTodoView.hidden = true
        footer.titleTextField.text=""
        footer.assignTodoButton.setTitle("Assign to do", forState: .Normal)
        footer.dateButton.setTitle("Date", forState: .Normal)
        footer.addTodoButton.hidden = false
        footer.newTodo = nil

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
		let contentView: UIView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 60))
		contentView.backgroundColor = Helper.Colors.RGBCOLOR(250, green: 255, blue: 254)
		let listTitle: TodoListSectionTextField = TodoListSectionTextField(frame: CGRectMake(20, 0, self.view.frame.width - 40, 29))
		listTitle.center = CGPointMake(listTitle.center.x, contentView.frame.size.height / 2)
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
		let cell = toDoTableView.dequeueReusableHeaderFooterViewWithIdentifier("TodoSectionFooter")
		let footer = cell as! TodoTableSectionFooter
		footer.addTodoButton.tag = section
		footer.dateButton.tag = section
		footer.addNewTodoButton.tag = section
		footer.titleTextField.tag = section
		footer.titleTextField.delegate = self
		footer.dateButton.addTarget(self, action: #selector(dateNewTodoButtonTapped(_:)), forControlEvents: .TouchUpInside)
		footer.assignTodoButton.addTarget(self, action: #selector(assignNewTodoButtonTapped(_:)), forControlEvents: .TouchUpInside)
		footer.addNewTodoButton.addTarget(self, action: #selector(addNewTodoButtonTapped(_:)), forControlEvents: .TouchUpInside)
		footer.addTodoButton.addTarget(self, action: #selector(addTodoTapped(_:)), forControlEvents: .TouchUpInside)
        
        cleanFooterView(footer)
        
        return footer
    }

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		let todo: Todo = lists[indexPath.section].todos![indexPath.row]
		let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TodoTableViewCell

		if todo.status == Helper.TodoStatusKey.kActive {
            cell.selectedButton .setImage(UIImage(), forState: .Normal)
		} else {
			cell.selectedButton .setImage(UIImage(named: "iconHelpAssignTickCopy"), forState: .Normal)
		}

		cell.titleTextField.text = todo.name
		cell.titleTextField.indexPath = indexPath
		cell.titleTextField.delegate = self
		cell.selectedButton.indexPath = indexPath
		cell.dateButton.indexPath = indexPath
		cell.assignedPersonButton.indexPath = indexPath
        
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
        }

		cell.dateButton.addTarget(self, action: #selector(dateButtonTapped(_:)), forControlEvents: .TouchUpInside)
		cell.selectedButton.addTarget(self, action: #selector(selectedButtonTapped(_:)), forControlEvents: .TouchUpInside)
		cell.assignedPersonButton.setTitle(todo.assignedTo.name, forState: .Normal)
		cell.assignedPersonButton.addTarget(self, action: #selector(assignTodoButtonTapped(_:)), forControlEvents: .TouchUpInside)
        if todo.assignedTo.personId == 0 {
            cell.dateButton.setTitleColor(Helper.Colors.RGBCOLOR(167, green: 90, blue: 255), forState: .Normal)
            cell.assignedPersonButton.setTitleColor(Helper.Colors.RGBCOLOR(167, green: 90, blue: 255), forState: .Normal)
            cell.selectedButton.layer.borderColor = Helper.Colors.RGBCOLOR(167, green: 90, blue: 255).CGColor
        }else{
            cell.dateButton.setTitleColor(Helper.Colors.RGBCOLOR(135, green: 135, blue: 135), forState: .Normal)
            cell.assignedPersonButton.setTitleColor(Helper.Colors.RGBCOLOR(135, green: 135, blue: 135), forState: .Normal)
            cell.selectedButton.layer.borderColor = Helper.Colors.RGBCOLOR(228, green: 241, blue: 240).CGColor
        }
        

		return cell
	}

	func assignNewTodoButtonTapped(sender: DateUnderlineButton) {

        if  let footer = toDoTableView.footerViewForSection(sender.tag) as? TodoTableSectionFooter {
		    currentTodo = footer.newTodo
            performSegueWithIdentifier(Helper.SegueKey.kToAssignTodoViewController, sender: self)
        }

	}

	func assignTodoButtonTapped(sender: ButtonWithIndexPath) {
		let section: Int = sender.indexPath!.section
		let row: Int = sender.indexPath!.row
		let list = lists[section]
		currentTodo = list.todos![row]
		print(currentTodo)
		performSegueWithIdentifier(Helper.SegueKey.kToAssignTodoViewController, sender: self)

	}

	func dateNewTodoButtonTapped(sender: DateUnderlineButton) {

        if let footer = toDoTableView.footerViewForSection(sender.tag) as? TodoTableSectionFooter {
           
            currentTodo = footer.newTodo
            performSegueWithIdentifier(Helper.SegueKey.kToSelectTodoDateViewController, sender: self)
        }
	}
  
	func dateButtonTapped(sender: ButtonWithIndexPath) {
		let section: Int = sender.indexPath!.section
		let row: Int = sender.indexPath!.row
		let list = lists[section]
		currentTodo = list.todos![row]
		print(currentTodo)
		performSegueWithIdentifier(Helper.SegueKey.kToSelectTodoDateViewController, sender: self)

	}

	func selectedButtonTapped(sender: ButtonWithIndexPath) {
		let section: Int = sender.indexPath!.section
		let row: Int = sender.indexPath!.row
		let list = lists[section]
		let todo = list.todos![row]
        var status:String?
        if todo.status == Helper.TodoStatusKey.kActive || todo.status == Helper.TodoStatusKey.kOverdue {
            status = Helper.TodoStatusKey.kDone
        }else{
            status = Helper.TodoStatusKey.kActive
        }
        
        runUpdateTodoRequest(todo.name, todoId: todo.todoId, assignToId: nil, assignToName: nil, date: nil, time: nil, status: status, todo: todo)
        
		

	}

	func addNewTodoButtonTapped(sender: UIButton) {

		if let footer = toDoTableView.footerViewForSection(sender.tag) as? TodoTableSectionFooter {
			
            
            let section: Int = sender.tag
            let list = lists[section]

            
            var todoTitle:String?
            if footer.titleTextField.hasText() {
                todoTitle = footer.titleTextField.text
            }else{
                todoTitle = "Untitled To Do"
            }
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let timeFormatter: NSDateFormatter = NSDateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            // get the date string applied date format
            var selectedDate:String?
            var selectedTime:String?
            if footer.newTodo != nil {
                if footer.newTodo!.date != nil {
                     selectedDate = dateFormatter.stringFromDate(footer.newTodo!.date!)
                }else{
                     selectedDate = nil
                }
                if footer.newTodo!.time != nil {
                    selectedTime = timeFormatter.stringFromDate(footer.newTodo!.time!)
                }else{
                    selectedTime = nil
                }

            }else{
                SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                return
            }
            
            
            runAddTodoRequest(todoTitle!, listId: (footer.newTodo?.list.listId)!, assignTo: (footer.newTodo?.assignedTo.personId)!, date:selectedDate, time:selectedTime, section: section, list: list)
           
		}
	}

    func runAddTodoRequest(todoName: String, listId: Int, assignTo: Int, date:String?, time:String?, section:Int, list: List) {

		SVProgressHUD.show()
        provider.request(.AddTodo(listId: listId, name: todoName, assign_to :assignTo, date: date, time: time)) { result in
			switch result {
			case let .Success(moyaResponse):

				do {
					try moyaResponse.filterSuccessfulStatusCodes()
					guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject] else {
						print("wrong json format")
						SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
						return;
					}
					print(json)
					SVProgressHUD.dismiss()
					
                    if let todoId = json["id"] as? Int {
                        var person:Person?
                        if let assignedToId = json["assign_to_id"] as? Int {
                            person = Person(name: json["assign_to_name"] as? String, personId: assignedToId)
                            
                        }else{
                            
                            person = Person(name: nil, personId: 0)
                        }
                        let newTodo = Todo(name: json["todo"] as? String, list: list, updatedAt: json["updated_at"] as? String , createdAt: json["created_at"] as? String, date: json["date"] as? String, time:json["time"] as? String, status: json["status"] as? String, todoId: todoId, assignedTo: person!)
                        list.todos?.append(newTodo)
                        

                        self.toDoTableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .Automatic)
                        
                        
                        let lastRow: Int = self.toDoTableView.numberOfRowsInSection(section)-1
                        self.toDoTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lastRow, inSection: section), atScrollPosition: .Bottom, animated: true)

                        
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
                        
                        self.toDoTableView.reloadData()
                        
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

    func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No todos"
        let attrs = [NSFontAttributeName: UIFont(name: "MuseoSansRounded-300", size: 18)!, NSForegroundColorAttributeName:Helper.Colors.RGBCOLOR(104, green: 104, blue: 104)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    func runUpdateListRequest(listName: String, section:Int, list:List) {
        
        SVProgressHUD.show()
        provider.request(.UpdateList(listId:list.listId, name: listName)) { result in
            switch result {
            case let .Success(moyaResponse):
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject] else {
                        print("wrong json format")
                        SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
                        return;
                    }
                    if let listName = json["name"] as? String {
                       list.name = listName
                       self.toDoTableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .Automatic)
                    }
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



	func addTodoTapped(sender: UIButton) {
		print(sender.superview)
		sender.hidden = true

		if let footer = sender.superview as? TodoTableSectionFooter {
			footer.addTodoView.hidden = false
            let section: Int = sender.tag
            let list = lists[section]
			footer.titleTextField.becomeFirstResponder()
            let person:Person = Person(name: nil, personId: 0)
            let newTodo:Todo = Todo(name: "", list: list, updatedAt: nil, createdAt: nil, date: nil, time: nil, status: "", todoId: 0, assignedTo: person)
            footer.newTodo = newTodo
            newTodo.footer = footer
            
            
            
		}

	}

	func textFieldDidBeginEditing(textField: UITextField) {

		if let todoName = textField as? TodoNameTextField {
			print("show \(todoName.indexPath)")
			toDoTableView.footerViewForSection(todoName.indexPath!.section)?.hidden = true

		}

	}

	func textFieldDidEndEditing(textField: UITextField) {
		if let todoName = textField as? TodoNameTextField {
			print("hide \(todoName.indexPath)")
			toDoTableView.footerViewForSection(todoName.indexPath!.section)?.hidden = false
            
        }
        if let newTodoName = textField as? AddTodoTitleTextField {
          if let footer = toDoTableView.footerViewForSection(newTodoName.tag) as? TodoTableSectionFooter {
            footer.newTodo?.name = textField.text
            }
        }
	}

	func textFieldShouldReturn(textField: UITextField) -> Bool {

		if textField is TodoListSectionTextField {
			if textField.hasText() {
				textField.resignFirstResponder()
				let section: Int = textField.tag
                let list = lists[section]
                runUpdateListRequest(textField.text!, section: section, list: list)
			}
		}

		if let todoName = textField as? TodoNameTextField {
			
				todoName.resignFirstResponder()
				let section: Int = todoName.indexPath!.section
				let row: Int = todoName.indexPath!.row
				let list = lists[section]
				let todo = list.todos![row]
				
                
                var todoTitle:String?
                if todoName.hasText() {
                    todoTitle = todoName.text
                }else{
                    todoTitle = "Untitled To Do"
                }
                
            
                runUpdateTodoRequest(todoTitle!, todoId: todo.todoId, assignToId: nil, assignToName: nil, date: nil, time: nil, status: nil,todo: todo)

		}
        
        if textField is AddTodoTitleTextField {
            textField.resignFirstResponder()
        }
      
		return false
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	@IBAction func addNewListTapped(sender: AnyObject) {

		if !listTextField.hasText() {
			SVProgressHUD.showErrorWithStatus("List field is empty")
			return
		}

		runAddListRequest(listTextField.text!)
	}

	func runAddListRequest(listName: String) {

		SVProgressHUD.show()
		provider.request(.AddList(name: listName)) { result in
			switch result {
			case let .Success(moyaResponse):

				do {
					try moyaResponse.filterSuccessfulStatusCodes()
					guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject] else {
						print("wrong json format")
						SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
						return;
					}
					print(json)

					guard let listId = json["id"] as? Int else {
						print("wrong list id")
						SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
						return;
					}

					SVProgressHUD.dismiss()

					let newList = List(name: self.listTextField.text!, listId: listId)
					newList.todos = [Todo]()
					self.lists.insert(newList, atIndex: 0)

					self.listTextField.text = ""
					self.toDoTableView.reloadData()
					self.addLIstButtonTaped(UIButton())

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

	@IBAction func addLIstButtonTaped(sender: AnyObject) {

		var height: CGFloat = 0
		if isHeaderOpened {
			height = 0
			isHeaderOpened = false
			listTextField.resignFirstResponder()
		} else {
			height = 100
			isHeaderOpened = true
			listTextField.becomeFirstResponder()
		}

		var newRect = toDoTableView.tableHeaderView?.frame
		newRect?.size.height = height
		// Get the reference to the header view
		let tblHeaderView = toDoTableView.tableHeaderView
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
			let viewController: SelectTodoDateViewController = segue.destinationViewController as! SelectTodoDateViewController
			if (currentTodo != nil) {
				viewController.currentTodo = currentTodo
			}
			viewController.senderViewController = self

		}

		if segue.identifier == Helper.SegueKey.kToAssignTodoViewController {
			let viewController: AssignTodoViewController = segue.destinationViewController as! AssignTodoViewController
			if (currentTodo != nil) {
				viewController.currentTodo = currentTodo
			}
			viewController.senderViewController = self

		}

	}

}


