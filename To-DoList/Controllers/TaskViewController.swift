//
//  CategoryViewController.swift
//  To-DoList
//
//  Created by Sujata on 25/11/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class TaskViewController: UITableViewController
{
    var tasks = [Task]()
    var ref: DatabaseReference!
    
    let formatter = DateFormatter()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ref = Database.database().reference(withPath: "Task")
        
        setDateFomatter()
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressedTableView))
        
        tableView.addGestureRecognizer(longPressRecognizer)
        
        
//        self.tableView.estimatedRowHeight = 600
//        self.tableView.rowHeight = UITableView.automaticDimension

        loadTasks()
    }
    
    //MARK: - LongPress methods
    @objc func longPressedTableView(sender:UILongPressGestureRecognizer)
    {
        if(sender.state == .began)
        {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint)
            {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                performSegue(withIdentifier: "goToNotes", sender: tableView)
            }
        }
    }
    
    //MARK: - TableView Datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? taskTableViewCell
        
        //cell?.layer.borderColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        //cell?.layer.borderWidth = 1.0
        //cell?.layer.cornerRadius = 2
        
        cell?.lblTitle.text = tasks[indexPath.row].name
        cell?.lblCreationDate?.text = tasks[indexPath.row].creationDate
        cell?.lblPriority.backgroundColor = setPriorityColor(index: indexPath.row)
        
        //cell?.accessoryType = tasks[indexPath.row].done ? .checkmark : .none

        return cell!
    }
    
//    override func numberOfSections(in tableView: UITableView) -> Int
//    {
//        return 1
//    }
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        //self.tableView.estimatedRowHeight = 100
//        return UITableView.automaticDimension
//    }
//
//    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return 100.0
//    }
//
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
//    {
//        return 10.0
//    }
    
    
    
    func setPriorityColor(index:Int)->UIColor
    {
        switch tasks[index].priority {
        case 1:
           return #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        case 2:
            return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        default:
            return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        }
        
    }
    
    //MARK: - TableView Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        let taskItem = tasks[indexPath.row]
        taskItem.done = !taskItem.done

        toggleCellCheckbox(cell as! taskTableViewCell, isDone: taskItem.done)

        taskItem.ref?.updateChildValues([
            "done": taskItem.done
            ])
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func toggleCellCheckbox(_ cell: taskTableViewCell, isDone: Bool)
    {
        if !isDone
        {
            cell.accessoryType = .none
            cell.lblTitle.textColor = .black
        }
        else
        {
            cell.accessoryType = .checkmark
            cell.lblTitle.textColor = .gray
        }
    }
    
    //MARK: - Segue methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let notesVC = segue.destination as? NotesViewController
        {
            if let indexPath = tableView.indexPathForSelectedRow
            {
                notesVC.selectedTask = tasks[indexPath.row]
            }
        }
    }
    
    //MARK: - Data manipulation methods

    func loadTasks()
    {
        ref.observe(.value, with: { snapshot in
            var newTasks: [Task] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let tempTask = Task(snapshot: snapshot) {
                    newTasks.append(tempTask)
                }
            }
            
//            let temp34 = newTasks.sorted{self.formatter.date(from: $0.creationDate!)!.compare(self.formatter.date(from: $1.creationDate!)!) == .orderedAscending}
//            self.tasks = temp34
            
            self.tasks = newTasks.sorted{self.formatter.date(from: $0.creationDate!)!.compare(self.formatter.date(from: $1.creationDate!)!) == .orderedAscending}
            
            self.tableView.reloadData()
//            self.view.layoutIfNeeded()
        })
    }
    
    //MARK: - Add New Categories

    func saveInFIRdb(_ name: String)
    {
        let taskRef = self.ref.child(name)
        
        let doneRef = taskRef.child("done")
        doneRef.setValue(false)
        
        let noteRef = taskRef.child("note")
        noteRef.setValue("")
        
        let priorityRef = taskRef.child("priority")
        priorityRef.setValue(0)
        
        let remindRef = taskRef.child("remind")
        remindRef.setValue(false)
        
        let dueDateRef = taskRef.child("dueDate")
        dueDateRef.setValue("")
        
        let creationDateRef = taskRef.child("creationDate")
        creationDateRef.setValue(formatter.string(from: Date()))
    }
    
    func createAddAlertAction()
    {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            self.saveInFIRdb(textField.text!)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        alert.addAction(cancel)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Create new task"
        }
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func barButtonPressed(_ sender: UIBarButtonItem)
    {
        createAddAlertAction()
    }
    
    //MARK: - Cell Swipe Action DELETE
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let taskTitle = tasks[indexPath.row].name
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, actionPerformed:@escaping (Bool)->() ) in
            
            let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this task: \(taskTitle)", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
                actionPerformed(false)
            }))
        
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alertAction) in
                
                self.deleteTask(index: indexPath.row)
                actionPerformed(true)
            }))
            self.present(alert, animated: true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    //MARK: - Cell Swipe Action EDIT

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let edit = UIContextualAction(style: .normal, title: "Edit") { (contextualAction, view, actionPerformed:@escaping (Bool)->Void)
            in
            
            let alert = UIAlertController(title: "Edit", message: "Are you sure you want to edit this task?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
                actionPerformed(false)
            }))
            
            var textField =  UITextField()
            
            alert.addTextField(configurationHandler: { (field) in
                textField = field
                textField.text = self.tasks[indexPath.row].name
            })
            
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alertAction) in
                self.tasks[indexPath.row].name = textField.text!
                self.updateTask(index: indexPath.row)
                actionPerformed(true)
            }))
            
            self.present(alert, animated: true)
        }
        edit.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        return UISwipeActionsConfiguration(actions: [edit])
    }
    
    //MARK: - Delete and Update Fns
    func deleteTask(index:Int)
    {
        let taskItem = tasks[index]
        taskItem.ref?.removeValue()
        tasks.remove(at: index)
    }
    
    func updateTask(index:Int)
    {
        let taskItem = self.tasks[index]
        let newtaskRef = self.ref.child(taskItem.name)
        
        let doneRef = newtaskRef.child("done")
        doneRef.setValue(taskItem.done)
        
        let noteRef = newtaskRef.child("note")
        noteRef.setValue(taskItem.note)
        
        let remindRef = newtaskRef.child("remind")
        remindRef.setValue(taskItem.remind)
        
        let priorityRef = newtaskRef.child("priority")
        priorityRef.setValue(taskItem.priority)
        
        let dueDateRef = newtaskRef.child("dueDate")
        dueDateRef.setValue(taskItem.dueDate)
        
        let creationDateRef = newtaskRef.child("creationDate")
        creationDateRef.setValue(taskItem.creationDate)
        
        taskItem.ref?.removeValue()
        self.tasks.remove(at: index)
    }
    
    func setDateFomatter()
    {
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
    }
}

//extension TaskViewController: UISearchBarDelegate
//{
//    func createRequest(searchText:String)->(NSFetchRequest<Category>,NSPredicate)
//    {
//        let request : NSFetchRequest<Category> = Category.fetchRequest()
//
//        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
//        return (request,predicate)
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
//    {
//        let result = createRequest(searchText:searchBar.text!)
//        loadCategories(with: result.0, predicate: result.1)
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
//    {
//        if(searchBar.text?.count == 0)
//        {
//            loadCategories()
//            DispatchQueue.main.async
//            {
//                searchBar.resignFirstResponder()
//            }
//        }
//        else
//        {
//            let result = createRequest(searchText:searchBar.text!)
//            loadCategories(with: result.0, predicate: result.1)
//        }
//    }
//
//        func findUsers(text: String)->Void
//        {
//            ref.child("Users").queryOrderedByChild("name").queryStartingAtValue(text).queryEnding(atValue: text+"\u{f8ff}").observe(.Value, with: { snapshot in
//            var user = Task()
//            var users = [Task]()
//            for u in snapshot.children{
//                user.name = u.value!["name"] as? String
//                    ...
//                    users.append(user)
//            }
//            self.users = users
//            })
//        }
//}


