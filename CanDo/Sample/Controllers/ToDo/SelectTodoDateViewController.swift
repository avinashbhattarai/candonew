//
//  SelectTodoDateViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 02.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class SelectTodoDateViewController: UIViewController {

    var currentTodo: Todo?
    var selectedDate: NSDate = NSDate()
    
    @IBOutlet weak var todoTitle: UILabel!
    @IBOutlet weak var anyTimeButton: SelectSuggestionButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "To Do List"
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "iconChevronRightWhite-1"), forState: .Normal)
        backButton.frame = CGRectMake(0, 0, 11, 16)
        backButton.addTarget(self, action: #selector(self.backButtonTapped(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: backButton), animated: true);
        
        if (currentTodo != nil) {
             self.todoTitle.text = currentTodo?.name
        }
       
        
        self.anyTimeButton.backgroundColor = UIColor.clearColor()
        self.anyTimeButton.layer.cornerRadius = 5
        self.anyTimeButton.layer.borderWidth = 1
        self.anyTimeButton.layer.borderColor = Helper.Colors.RGBCOLOR(228, green: 241, blue: 240).CGColor

        self.anyTimeButton.setImage(UIImage(), forState: .Normal)
        self.anyTimeButton.setImage(UIImage(named: "iconHelpAssignTickCopy"), forState: .Selected)
        
        
        // add an event called when value is changed.
        self.datePicker.addTarget(self, action: #selector(SelectTodoDateViewController.pickerDidChangeDate(_:)), forControlEvents: .ValueChanged)

        
        // Do any additional setup after loading the view.
    }
    func backButtonTapped(sender: AnyObject) {
        
        self.navigationController!.popViewControllerAnimated(true)
    }

    
       // called when the date picker called.
    func pickerDidChangeDate(sender: UIDatePicker){
        
        // date format
        let myDateFormatter: NSDateFormatter = NSDateFormatter()
        myDateFormatter.dateFormat = "MM/dd/yyyy hh:mm"
        
        // get the date string applied date format
        let mySelectedDate: NSString = myDateFormatter.stringFromDate(sender.date)
        
        selectedDate = sender.date
       
        print(mySelectedDate)
        print(selectedDate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func anyTimeButtonTapped(sender: SelectSuggestionButton) {
        sender.selected = !sender.selected
        if sender.selected {
            self.datePicker.datePickerMode = .Date
        }else{
            self.datePicker.datePickerMode = .DateAndTime
        }
    
    }
    
    
    @IBAction func setDateButtonTapped(sender: AnyObject) {
        currentTodo?.date = selectedDate
        self.navigationController?.popViewControllerAnimated(true)
        
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
