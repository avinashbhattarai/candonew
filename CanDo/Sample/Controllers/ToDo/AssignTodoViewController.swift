//
//  AssignTodoViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 04.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class AssignTodoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var todoTitleLabel: UILabel!
    @IBOutlet weak var personsTableView: UITableView!
   
    var persons = [Person]()
    var currentTodo: Todo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "To Do List"
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "iconChevronRightWhite-1"), forState: .Normal)
        backButton.frame = CGRectMake(0, 0, 11, 16)
        backButton.addTarget(self, action: #selector(self.backButtonTapped(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: backButton), animated: true);
        
        for personIndex in 0...10 {
            
            var person:Person?
            
            if personIndex == 0 {
                 person = Person(name: "Anyone", selected: true, avatar: "")
            }else{
                 person = Person(name: String(format: "Person %d",personIndex), selected: false, avatar: "imageHelpAssignEstelleCopy")
            }
           
            persons.append(person!)
        }
        
        if (currentTodo != nil) {
            self.todoTitleLabel.text = currentTodo?.name
        }
        
        

        self.personsTableView.delegate = self;
        self.personsTableView.dataSource = self;
        
         self.personsTableView.contentInset = UIEdgeInsetsMake(0, 0, 94, 0)
        
        // Do any additional setup after loading the view.
    }
    func backButtonTapped(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
  

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let person : Person = persons[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! PersonTableViewCell
        
        if person.selected! {
            print(indexPath)
            cell.selectButton .setImage(UIImage(named:"iconHelpAssignTickCopy"), forState: .Normal)
        }else{
            cell.selectButton .setImage(UIImage(), forState: .Normal)
        }
        cell.selectButton.backgroundColor = UIColor.clearColor()
        cell.selectButton.layer.cornerRadius = cell.selectButton.frame.size.height/2
        cell.selectButton.layer.borderWidth = 1
        cell.selectButton.layer.borderColor = UIColor(red: 185/255.0, green: 212/255.0, blue: 214/255.0, alpha: 1.0).CGColor
        
        cell.personAvatar.layer.cornerRadius = 5

        cell.personTitle.text = person.name
        cell.personAvatar.image =  UIImage(named: person.avatar!)
        cell.selectButton.indexPath = indexPath
        cell.selectButton.addTarget(self, action: #selector(AssignTodoViewController.selectedButtonTapped(_:)), forControlEvents: .TouchUpInside)
      
        
        return cell
    }


    
  
    
    @IBAction func assignTodoButtonTapped(sender: AnyObject) {
        for person:Person in persons{
            if person.selected! {
                currentTodo?.assignedPerson = person
                break
            }
            
        }
        self.navigationController!.popViewControllerAnimated(true)
     }
    
    
    func selectedButtonTapped(sender: ButtonWithIndexPath) {
        
        
        for person:Person in persons{
            person.selected = false
        }
        
        let row: Int = sender.indexPath!.row
        let selectedPerson:Person = persons[row]
        selectedPerson.selected = true
        
        self.personsTableView.reloadData()
        

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
