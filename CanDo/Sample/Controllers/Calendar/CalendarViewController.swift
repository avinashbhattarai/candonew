//
//  CalendarViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: BaseViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var todoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      
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
        
    }
    
  
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        print(date)
    }
   
    func calendar(calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsForDate date: NSDate) -> [UIColor]?{
        print("color")
        return [UIColor.redColor()]
    }
    func calendar(calendar: FSCalendar, numberOfEventsForDate date: NSDate) -> Int {
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 74
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CalendarTodoTableViewCell
        
        cell.assignPersonButton.indexPath = indexPath
        cell.dateButton.indexPath = indexPath
        cell.dateButton.addTarget(self, action: #selector(dateButtonTapped(_:)), forControlEvents: .TouchUpInside)
        cell.assignPersonButton.addTarget(self, action: #selector(assignTodoButtonTapped(_:)), forControlEvents: .TouchUpInside)
       
        
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
