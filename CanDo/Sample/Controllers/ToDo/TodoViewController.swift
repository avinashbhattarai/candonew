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
    
    var cellDateFormatter = DateFormatter()
    var cellTimeFormatter = DateFormatter()

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
		toDoTableView.separatorStyle = UITableViewCellSeparatorStyle.none

		let nib = UINib(nibName: "TodoSectionFooter", bundle: nil)
		toDoTableView.register(nib, forHeaderFooterViewReuseIdentifier: "TodoSectionFooter")
        
        cellDateFormatter.dateStyle = DateFormatter.Style.medium
        cellTimeFormatter.timeStyle = DateFormatter.Style.short

        
		_ = toDoTableView.es_addPullToRefresh {

			/// Do anything you want...
			/// ...
			self.runListsInfoRequest()
			/// Stop refresh when your job finished, it will reset refresh footer if completion is true

		}

		
        toDoTableView.es_startPullToRefresh()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataTodo(_:)), name:NSNotification.Name(rawValue: "reloadDataTodo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reDownloadDataTodo(_:)), name:NSNotification.Name(rawValue: "reDownloadDataTodo"), object: nil)
       
	}
    override func viewWillAppear(_ animated: Bool) {
       
    }
    func reDownloadDataTodo(_ n: Foundation.Notification) {
        toDoTableView.es_startPullToRefresh()
    }
    func reloadDataTodo(_ n: Foundation.Notification) {
        toDoTableView.reloadData()
        if ((n as NSNotification).userInfo != nil) {
            if let todo = (n as NSNotification).userInfo!["todo"] as? Todo{
                
                
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

        }
    }
    
	func runListsInfoRequest() {

		
        provider.request(.listsInfo(date:nil)) { result in
			switch result {
			case let .success(moyaResponse):

				do {
					try _ = moyaResponse.filterSuccessfulStatusCodes()
					guard let json = moyaResponse.data.nsdataToJSON() as? [[String: AnyObject]] else {
						print("wrong json format")
                        self.toDoTableView.es_stopPullToRefresh(completion: true)
						SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
						return;
					}
                    self.lists = [List]()
					for list: Dictionary in json {
						if let listId = list["id"] as? Int {
							let newList = List(name: list["name"] as? String, listId: listId)
							var todosArray = [Todo]()
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
							SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
							self.toDoTableView.es_stopPullToRefresh(completion: true)
							return;
					}
					SVProgressHUD.showError(withStatus: "\(message)")
					self.toDoTableView.es_stopPullToRefresh(completion: true)

				}

			case let .failure(error):
				guard let error = error as? CustomStringConvertible else {
					break
				}
				print(error.description)
				SVProgressHUD.showError(withStatus: "\(error.description)")
				self.toDoTableView.es_stopPullToRefresh(completion: true)

			}
		}

	}
    func cleanFooterView(_ footer: TodoTableSectionFooter){
        
        footer.addTodoView.isHidden = true
        footer.titleTextField.text=""
        footer.assignTodoButton.setTitle("Assign to do", for: UIControlState())
        footer.dateButton.setTitle("Date", for: UIControlState())
        footer.addTodoButton.isHidden = false
        footer.newTodo = nil

    }
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return lists.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return lists[section].todos!.count
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 60
	}
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 90
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 90
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let contentView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
		contentView.backgroundColor = Helper.Colors.RGBCOLOR(250, green: 255, blue: 254)
		let listTitle: TodoListSectionTextField = TodoListSectionTextField(frame: CGRect(x: 20, y: 0, width: self.view.frame.width - 40, height: 29))
		listTitle.center = CGPoint(x: listTitle.center.x, y: contentView.frame.size.height / 2)
		listTitle.text = lists[section].name
		listTitle.placeholder = "List title"
		listTitle.tag = section
		listTitle.delegate = self
		listTitle.returnKeyType = .done
		contentView.addSubview(listTitle)
		return contentView
	}
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

		// Dequeue with the reuse identifier
		let cell = toDoTableView.dequeueReusableHeaderFooterView(withIdentifier: "TodoSectionFooter")
		let footer = cell as! TodoTableSectionFooter
		footer.addTodoButton.tag = section
		footer.dateButton.tag = section
        footer.assignTodoButton.tag = section
		footer.addNewTodoButton.tag = section
		footer.titleTextField.tag = section
		footer.titleTextField.delegate = self
		footer.dateButton.addTarget(self, action: #selector(dateNewTodoButtonTapped(_:)), for: .touchUpInside)
		footer.assignTodoButton.addTarget(self, action: #selector(assignNewTodoButtonTapped(_:)), for: .touchUpInside)
		footer.addNewTodoButton.addTarget(self, action: #selector(addNewTodoButtonTapped(_:)), for: .touchUpInside)
		footer.addTodoButton.addTarget(self, action: #selector(addTodoTapped(_:)), for: .touchUpInside)
        
        cleanFooterView(footer)
        
        return footer
    }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let todo: Todo = lists[(indexPath as NSIndexPath).section].todos![(indexPath as NSIndexPath).row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TodoTableViewCell

		if todo.status == Helper.TodoStatusKey.kActive {
            cell.selectedButton .setImage(UIImage(), for: UIControlState())
		} else {
			cell.selectedButton .setImage(UIImage(named: "iconHelpAssignTickCopy"), for: UIControlState())
		}

		cell.titleTextField.text = todo.name
		cell.titleTextField.indexPath = indexPath
		cell.titleTextField.delegate = self
		cell.selectedButton.indexPath = indexPath
		cell.dateButton.indexPath = indexPath
		cell.assignedPersonButton.indexPath = indexPath
        
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
            cell.dateButton.setTitle(String(format: "%@, %@", selectedTime!, selectedDate), for: UIControlState())
        }

		cell.dateButton.addTarget(self, action: #selector(dateButtonTapped(_:)), for: .touchUpInside)
		cell.selectedButton.addTarget(self, action: #selector(selectedButtonTapped(_:)), for: .touchUpInside)
		cell.assignedPersonButton.setTitle(todo.assignedTo.name, for: UIControlState())
		cell.assignedPersonButton.addTarget(self, action: #selector(assignTodoButtonTapped(_:)), for: .touchUpInside)
        if todo.assignedTo.personId == 0 {
            cell.dateButton.setTitleColor(Helper.Colors.RGBCOLOR(167, green: 90, blue: 255), for: UIControlState())
            cell.assignedPersonButton.setTitleColor(Helper.Colors.RGBCOLOR(167, green: 90, blue: 255), for: UIControlState())
            cell.selectedButton.layer.borderColor = Helper.Colors.RGBCOLOR(167, green: 90, blue: 255).cgColor
        }else{
            cell.dateButton.setTitleColor(Helper.Colors.RGBCOLOR(135, green: 135, blue: 135), for: UIControlState())
            cell.assignedPersonButton.setTitleColor(Helper.Colors.RGBCOLOR(135, green: 135, blue: 135), for: UIControlState())
            cell.selectedButton.layer.borderColor = Helper.Colors.RGBCOLOR(228, green: 241, blue: 240).cgColor
        }
        

		return cell
	}

	func assignNewTodoButtonTapped(_ sender: DateUnderlineButton) {
         print(sender.tag)
        if  let footer = toDoTableView.footerView(forSection: sender.tag) as? TodoTableSectionFooter {
		    currentTodo = footer.newTodo
            performSegue(withIdentifier: Helper.SegueKey.kToAssignTodoViewController, sender: self)
            
        }

	}

	func assignTodoButtonTapped(_ sender: ButtonWithIndexPath) {
		let section: Int = (sender.indexPath! as NSIndexPath).section
		let row: Int = (sender.indexPath! as NSIndexPath).row
		let list = lists[section]
		currentTodo = list.todos![row]
		print(currentTodo)
		performSegue(withIdentifier: Helper.SegueKey.kToAssignTodoViewController, sender: self)

	}

	func dateNewTodoButtonTapped(_ sender: DateUnderlineButton) {

        if let footer = toDoTableView.footerView(forSection: sender.tag) as? TodoTableSectionFooter {
           
            currentTodo = footer.newTodo
            performSegue(withIdentifier: Helper.SegueKey.kToSelectTodoDateViewController, sender: self)
        }
	}
  
	func dateButtonTapped(_ sender: ButtonWithIndexPath) {
		let section: Int = (sender.indexPath! as NSIndexPath).section
		let row: Int = (sender.indexPath! as NSIndexPath).row
		let list = lists[section]
		currentTodo = list.todos![row]
		print(currentTodo)
		performSegue(withIdentifier: Helper.SegueKey.kToSelectTodoDateViewController, sender: self)

	}

	func selectedButtonTapped(_ sender: ButtonWithIndexPath) {
		let section: Int = (sender.indexPath! as NSIndexPath).section
		let row: Int = (sender.indexPath! as NSIndexPath).row
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

	func addNewTodoButtonTapped(_ sender: UIButton) {

		if let footer = toDoTableView.footerView(forSection: sender.tag) as? TodoTableSectionFooter {
			
            
            let section: Int = sender.tag
            let list = lists[section]

            
            var todoTitle:String?
            if footer.titleTextField.hasText {
                todoTitle = footer.titleTextField.text
            }else{
                todoTitle = "Untitled To Do"
            }
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let timeFormatter: DateFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            // get the date string applied date format
            var selectedDate:String?
            var selectedTime:String?
            if footer.newTodo != nil {
                if footer.newTodo!.date != nil {
                     selectedDate = dateFormatter.string(from: footer.newTodo!.date! as Date)
                }else{
                     selectedDate = nil
                }
                if footer.newTodo!.time != nil {
                    selectedTime = timeFormatter.string(from: footer.newTodo!.time! as Date)
                }else{
                    selectedTime = nil
                }

            }else{
                SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                return
            }
            
            if footer.newTodo?.assignedTo.personId != 0 {
                runAddTodoRequest(todoTitle!, listId: (footer.newTodo?.list.listId)!, assignTo: (footer.newTodo?.assignedTo.personId)!, date:selectedDate, time:selectedTime, section: section, list: list)
            }else{
                runAddTodoRequest(todoTitle!, listId: (footer.newTodo?.list.listId)!, assignTo:nil, date:selectedDate, time:selectedTime, section: section, list: list)
            }
            
            
           
		}
	}

    func runAddTodoRequest(_ todoName: String, listId: Int, assignTo: Int?, date:String?, time:String?, section:Int, list: List) {

		SVProgressHUD.show()
        provider.request(.addTodo(listId: listId, name: todoName, assign_to :assignTo, date: date, time: time)) { result in
			switch result {
			case let .success(moyaResponse):

				do {
					try _ = moyaResponse.filterSuccessfulStatusCodes()
					guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject] else {
						print("wrong json format")
						SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
						return;
					}
					print(json)
					SVProgressHUD.dismiss()
					
                    if let todoId = json["id"] as? Int {
                        var person:Person?
                        if let assignedToId = json["assign_to_id"] as? Int {
                            person = Person(name: json["assign_to_name"] as? String, personId: assignedToId, avatar:"")
                            
                        }else{
                            
                            person = Person(name: nil, personId: 0, avatar:"")
                        }
                        let newTodo = Todo(name: json["todo"] as? String, list: list, updatedAt: json["updated_at"] as? String , createdAt: json["created_at"] as? String, date: json["date"] as? String, time:json["time"] as? String, status: json["status"] as? String, todoId: todoId, assignedTo: person!)
                        list.todos?.append(newTodo)
                        

                        self.toDoTableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
                        
                        
                        let lastRow: Int = self.toDoTableView.numberOfRows(inSection: section)-1
                        self.toDoTableView.scrollToRow(at: IndexPath(row: lastRow, section: section), at: .bottom, animated: true)

                        
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
                        
                        self.toDoTableView.reloadData()
                        
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

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No todos"
        let attrs = [NSFontAttributeName: UIFont(name: "MuseoSansRounded-300", size: 18)!, NSForegroundColorAttributeName:Helper.Colors.RGBCOLOR(104, green: 104, blue: 104)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func runUpdateListRequest(_ listName: String, section:Int, list:List) {
        
        SVProgressHUD.show()
        provider.request(.updateList(listId:list.listId, name: listName)) { result in
            switch result {
            case let .success(moyaResponse):
                
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject] else {
                        print("wrong json format")
                        SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
                        return;
                    }
                    if let listName = json["name"] as? String {
                       list.name = listName
                        self.toDoTableView.reloadSections(IndexSet(integer:section), with: .automatic)
                    }
                    SVProgressHUD.dismiss()
                    
                    
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



	func addTodoTapped(_ sender: UIButton) {
		print(sender.superview)
		sender.isHidden = true

		if let footer = sender.superview as? TodoTableSectionFooter {
			footer.addTodoView.isHidden = false
            let section: Int = sender.tag
            let list = lists[section]
			footer.titleTextField.becomeFirstResponder()
            let person:Person = Person(name: nil, personId: 0, avatar:"")
            let newTodo:Todo = Todo(name: "", list: list, updatedAt: nil, createdAt: nil, date: nil, time: nil, status: "", todoId: 0, assignedTo: person)
            footer.newTodo = newTodo
            newTodo.footer = footer
           
		}

	}

	func textFieldDidBeginEditing(_ textField: UITextField) {

		if let todoName = textField as? TodoNameTextField {
			print("show \(todoName.indexPath)")
			toDoTableView.footerView(forSection: (todoName.indexPath! as NSIndexPath).section)?.isHidden = true

		}

	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		if let todoName = textField as? TodoNameTextField {
			print("hide \(todoName.indexPath)")
			toDoTableView.footerView(forSection: (todoName.indexPath! as NSIndexPath).section)?.isHidden = false
            
        }
        if let newTodoName = textField as? AddTodoTitleTextField {
          if let footer = toDoTableView.footerView(forSection: newTodoName.tag) as? TodoTableSectionFooter {
            footer.newTodo?.name = textField.text
            }
        }
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		if textField is TodoListSectionTextField {
			if textField.hasText {
				textField.resignFirstResponder()
				let section: Int = textField.tag
                let list = lists[section]
                runUpdateListRequest(textField.text!, section: section, list: list)
			}
		}

		if let todoName = textField as? TodoNameTextField {
			
				todoName.resignFirstResponder()
				let section: Int = (todoName.indexPath! as NSIndexPath).section
				let row: Int = (todoName.indexPath! as NSIndexPath).row
				let list = lists[section]
				let todo = list.todos![row]
				
                
                var todoTitle:String?
                if todoName.hasText {
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
	@IBAction func addNewListTapped(_ sender: AnyObject) {

		if !listTextField.hasText {
			SVProgressHUD.showError(withStatus: "List field is empty")
			return
		}

		runAddListRequest(listTextField.text!)
	}

	func runAddListRequest(_ listName: String) {

		SVProgressHUD.show()
		provider.request(.addList(name: listName)) { result in
			switch result {
			case let .success(moyaResponse):

				do {
					try _ = moyaResponse.filterSuccessfulStatusCodes()
					guard let json = moyaResponse.data.nsdataToJSON() as? [String: AnyObject] else {
						print("wrong json format")
						SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
						return;
					}
					print(json)

					guard let listId = json["id"] as? Int else {
						print("wrong list id")
						SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
						return;
					}

					SVProgressHUD.dismiss()

					let newList = List(name: self.listTextField.text!, listId: listId)
					newList.todos = [Todo]()
					self.lists.insert(newList, at: 0)

					self.listTextField.text = ""
					self.toDoTableView.reloadData()
					self.addLIstButtonTaped(UIButton())

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

	@IBAction func addLIstButtonTaped(_ sender: AnyObject) {

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
		UIView.animate(withDuration: 0.2, animations: { () -> Void in
			tblHeaderView?.frame = newRect!
			self.toDoTableView.tableHeaderView = tblHeaderView

		})

	}
	@IBAction func suggestionButtonTapped(_ sender: AnyObject) {
		performSegue(withIdentifier: Helper.SegueKey.kToSuggestionsViewController, sender: self)
	}

	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.

		if segue.identifier == Helper.SegueKey.kToSelectTodoDateViewController {
			let viewController: SelectTodoDateViewController = segue.destination as! SelectTodoDateViewController
			if (currentTodo != nil) {
				viewController.currentTodo = currentTodo
			}
			viewController.senderViewController = self

		}

		if segue.identifier == Helper.SegueKey.kToAssignTodoViewController {
			let viewController: AssignTodoViewController = segue.destination as! AssignTodoViewController
			if (currentTodo != nil) {
				viewController.currentTodo = currentTodo
			}
			viewController.senderViewController = self

		}

	}

}


