//
//  SelectTodoDateViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 02.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class SelectTodoDateViewController: BaseSecondLineViewController {

    var currentTodo: Todo?
    var selectedDate: NSDate?
    var selectedTime: NSDate?
    var senderViewController: UIViewController?
    var isUpdate: Bool = false
    
    
    @IBOutlet weak var todoTitle: UILabel!
    @IBOutlet weak var anyTimeButton: ButtonWithIndexPath!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if senderViewController is TodoViewController {
            self.title = "To Do List"
        }else if senderViewController is CalendarViewController{
            self.title = "Calendar"
        }

      
        
        if (currentTodo?.name != "") {
             todoTitle.text = currentTodo?.name
        }
       
        
        anyTimeButton.backgroundColor = UIColor.clearColor()
        anyTimeButton.layer.cornerRadius = 5
        anyTimeButton.layer.borderWidth = 1
        anyTimeButton.layer.borderColor = Helper.Colors.RGBCOLOR(228, green: 241, blue: 240).CGColor

        anyTimeButton.setImage(UIImage(), forState: .Normal)
        anyTimeButton.setImage(UIImage(named: "iconHelpAssignTickCopy"), forState: .Selected)
        
        
        // add an event called when value is changed.
        datePicker.addTarget(self, action: #selector(pickerDidChangeDate(_:)), forControlEvents: .ValueChanged)

        
        // Do any additional setup after loading the view.
    }
  
    
       // called when the date picker called.
    func pickerDidChangeDate(sender: UIDatePicker){
        
        // date format
        let myDateFormatter: NSDateFormatter = NSDateFormatter()
        myDateFormatter.dateFormat = "MM/dd/yyyy hh:mm"
        
        // get the date string applied date format
        let mySelectedDate: NSString = myDateFormatter.stringFromDate(sender.date)
        selectedDate = sender.date
        selectedTime = sender.date
        print(mySelectedDate)
        print(selectedDate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func anyTimeButtonTapped(sender: ButtonWithIndexPath) {
        sender.selected = !sender.selected
        if sender.selected {
            datePicker.datePickerMode = .Date
        }else{
            datePicker.datePickerMode = .DateAndTime
        }
    
    }
    
    
    @IBAction func setDateButtonTapped(sender: AnyObject) {
        currentTodo?.date = datePicker.date
        let dateFormatter = NSDateFormatter()
        let timeFormater = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        timeFormater.timeStyle = NSDateFormatterStyle.ShortStyle
        let dateInFormat = dateFormatter.stringFromDate(datePicker.date)
        var timeInFormat:String?
       
        if anyTimeButton.selected {
            currentTodo?.time = nil
            timeInFormat = "Any time"
        }else{
            currentTodo?.time = datePicker.date
            timeInFormat = timeFormater.stringFromDate(datePicker.date)
            
        }
        print(timeInFormat)
        print(dateInFormat)
        
        if currentTodo?.footer != nil {
            currentTodo?.footer?.dateButton.setTitle(String(format: "%@, %@",timeInFormat!,dateInFormat), forState: .Normal)
            currentTodo?.footer?.dateButton.setImage(nil, forState: .Normal)
            currentTodo?.footer?.undelineImage.hidden = true
        }else{
            if currentTodo != nil {
                NSNotificationCenter.defaultCenter().postNotificationName("reloadDataTodo", object: nil, userInfo: ["todo":currentTodo!])
            }
            
        }
        
        
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
