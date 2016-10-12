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
    var selectedDate: Date?
    var selectedTime: Date?
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
        }else{
            todoTitle.text = "Untitled To Do"
        }
       
        if ((currentTodo?.time) == nil) {
            anyTimeButton.isSelected = true
            datePicker.datePickerMode = .date
            
            
        }
        if ((currentTodo?.date) != nil) {
            datePicker.date = currentTodo?.date as Date? ?? Date()
            if ((currentTodo?.time) != nil) {
                let calendar = Calendar.current
                let timeComp = (calendar as NSCalendar).components([.hour, .minute, .second], from: (currentTodo?.time)! as Date)
                let dateComp = (calendar as NSCalendar).components([.year, .month, .day], from: (currentTodo?.date)! as Date)
                let date = calendar.date(from: dateComp)
                let newDate = (calendar as NSCalendar).date(byAdding: timeComp, to: date!, options: NSCalendar.Options(rawValue: 0))
                datePicker.date = newDate!
                
            }
        }
        
        
        anyTimeButton.backgroundColor = UIColor.clear
        anyTimeButton.layer.cornerRadius = 5
        anyTimeButton.layer.borderWidth = 1
        anyTimeButton.layer.borderColor = Helper.Colors.RGBCOLOR(228, green: 241, blue: 240).cgColor

        anyTimeButton.setImage(UIImage(), for: UIControlState())
        anyTimeButton.setImage(UIImage(named: "iconHelpAssignTickCopy"), for: .selected)
        
        
        // add an event called when value is changed.
        datePicker.addTarget(self, action: #selector(pickerDidChangeDate(_:)), for: .valueChanged)

        
        // Do any additional setup after loading the view.
    }
  
    
       // called when the date picker called.
    func pickerDidChangeDate(_ sender: UIDatePicker){
        
        // date format
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "MM/dd/yyyy hh:mm"
        
        // get the date string applied date format
        let mySelectedDate: NSString = myDateFormatter.string(from: sender.date) as NSString
        selectedDate = sender.date
        selectedTime = sender.date
        print(mySelectedDate)
        print(selectedDate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func anyTimeButtonTapped(_ sender: ButtonWithIndexPath) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            datePicker.datePickerMode = .date
        }else{
            datePicker.datePickerMode = .dateAndTime
        }
    
    }
    
    
    @IBAction func setDateButtonTapped(_ sender: AnyObject) {
        currentTodo?.date = datePicker.date
        let dateFormatter = DateFormatter()
        let timeFormater = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        timeFormater.timeStyle = DateFormatter.Style.short
        let dateInFormat = dateFormatter.string(from: datePicker.date)
        var timeInFormat:String?
       
        if anyTimeButton.isSelected {
            currentTodo?.time = nil
            timeInFormat = "Any time"
        }else{
            currentTodo?.time = datePicker.date
            timeInFormat = timeFormater.string(from: datePicker.date)
            
        }
        print(timeInFormat)
        print(dateInFormat)
        
        if currentTodo?.footer != nil {
            currentTodo?.footer?.dateButton.setTitle(String(format: "%@, %@",timeInFormat!,dateInFormat), for: UIControlState())
            currentTodo?.footer?.dateButton.setImage(nil, for: UIControlState())
            currentTodo?.footer?.undelineImage.isHidden = true
        }else{
            if currentTodo != nil {
                if senderViewController is TodoViewController {
                     NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "reloadDataTodo"), object: nil, userInfo: ["todo":currentTodo!])
                }else if senderViewController is CalendarViewController{
                     NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "reloadDataCalendar"), object: nil, userInfo: ["todo":currentTodo!])
                }
            }
            
        }
        
        _ = self.navigationController?.popViewController(animated: true)
        
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
