//
//  CalendarViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    @IBOutlet weak var calendarView: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "iconChevronRightWhite-1"), forState: .Normal)
        backButton.frame = CGRectMake(0, 0, 11, 16)
        backButton.addTarget(self, action: #selector(CalendarViewController.backButtonTapped(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: backButton), animated: true);
        
        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        self.calendarView.headerDateFormat = "MMMM"
        self.calendarView.headerHeight = 64
        self.calendarView.appearance.headerTitleFont = UIFont(name: "MuseoSansRounded-500", size: 24)
        self.calendarView.appearance.weekdayFont = UIFont(name: "MuseoSansRounded-300", size: 20)
        self.calendarView.appearance.titleFont = UIFont(name: "MuseoSansRounded-300", size: 20)
        self.calendarView.clipsToBounds = true
        self.calendarView.appearance.headerMinimumDissolvedAlpha = 0.0;
        
    }
    
    func backButtonTapped(sender: AnyObject) {
        let nc = (self.tabBarController?.navigationController)! as UINavigationController
        nc.popViewControllerAnimated(true)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
