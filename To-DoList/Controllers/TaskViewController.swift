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
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ref = Database.database().reference(withPath: "Task")
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressedTableView))
        
        tableView.addGestureRecognizer(longPressRecognizer)
        
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
        
        cell?.lblTitle.text = tasks[indexPath.row].name
        //cell?.accessoryType = tasks[indexPath.row].done ? .checkmark : .none

        //toggleCellCheckbox(cell, isCompleted: groceryItem.completed)

        return cell!
    }
    
    //MARK: - TableView Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //tasks[indexPath.row].done = !tasks[indexPath.row].done
        //saveCategories()
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
            print(newTasks)
            
            self.tasks = newTasks
            self.tableView.reloadData()
        })
    }


    
//    func loadCategories(with request:NSFetchRequest<Category> = Category.fetchRequest(), predicate: NSPredicate? = nil)
//    {
//        request.predicate = predicate
//
//        do
//        {
//            categories = try context.fetch(request)
//        }
//        catch
//        {
//            print("Error fetching data from context:\(error)")
//        }
//        tableView.reloadData()
//    }
    
    //MARK: - Add New Categories

    func saveInFIRdb(_ name: String)
    {
        let taskRef = self.ref.child(name)
        let doneRef = taskRef.child("done")
        doneRef.setValue(true)
        let noteRef = taskRef.child("note")
        noteRef.setValue("")
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
        
        taskItem.ref?.removeValue()
        self.tasks.remove(at: index)
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


