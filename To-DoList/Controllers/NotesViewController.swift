//
//  NotesViewController.swift
//  To-DoList
//
//  Created by Sujata on 29/11/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class NotesViewController: UIViewController
{
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var switchRemind: UISwitch!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var segmentPriority: UISegmentedControl!
    @IBOutlet weak var noteTextView: UITextView!
    
    var ref: DatabaseReference!

    var globalNote:Notes? = nil
    var globalNoteText:String? = nil
    var isNew = true
    
    var selectedTask:Task? = nil //Value passed from prev. View Controller
    
    let formatter = DateFormatter()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ref = Database.database().reference(withPath: "Task")

        setDateFomatter()
        
        updateTextView()
        
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        noteTextView.addGestureRecognizer(swipe)
        
        updateYearConstraints()
    }
    
    func setDateFomatter()
    {
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
    }
    
    func updateTextView()
    {
        if selectedTask != nil
        {
            titleTextView.text = selectedTask?.name
            noteTextView.text = selectedTask?.note
            segmentPriority.selectedSegmentIndex = selectedTask!.priority
            switchRemind.isOn = selectedTask!.remind
            lblDate.text = selectedTask?.dueDate
            
            if(selectedTask?.dueDate != "")
            {
                checkIfdue()
                
//                let tempDate = formatter.date(from: selectedTask!.dueDate!)
//                datePicker.setDate(tempDate!, animated: true)
            
            }
//            else
//            {
//                lblDate.text = ""
//            }
        }
    }
    
    func checkIfdue()
    {
        if let tempDate = formatter.date(from: selectedTask!.dueDate!)
        {
            if(Date() > tempDate)
            {
                lblDate.textColor = #colorLiteral(red: 1, green: 0.09992860631, blue: 0.1151061647, alpha: 1)
                titleTextView.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            }
            datePicker.setDate(tempDate, animated: true)
            //lblDate.text = selectedTask?.dueDate
        }
    }
    
    func updateYearConstraints()
    {
        datePicker.minimumDate = Date()
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        
        if(lblDate.text!.isEmpty)
        {
            updateDatePickerLabel()
        }
        
//        TESTING CODE
//        let date = Date()
//        let calendar = Calendar.current
//        let hour = calendar.component(.hour, from: date)
//        let minute = calendar.component(.minute, from: date)
//        print("hour: \(hour)")
//        print("minute: \(minute)")
//        datePicker.minimumDate =
//        datePicker.maximumDate=
    }
    
    func updateDatePickerLabel()
    {
        //let currentDateTime = Date() //Get current date and time
//        let formatter = DateFormatter()
//
//        formatter.timeStyle = .short
//        formatter.dateStyle = .medium
        
        lblDate.text = formatter.string(from: datePicker.date)
        
        //lblDate.text = currentDate
    }
    
    //MARK: - Remind Switch Functions
    @IBAction func priorityChanged(_ sender: UISegmentedControl)
    {
        switch sender.selectedSegmentIndex
        {
            case 0:
                print("None")
            case 1:
                print("Imp")
            case 2:
                print("Very Imp")
            default:
                print("default")
        }
    }
    
    //MARK: - Date Picker Function
    @IBAction func datePickerUpdated(_ sender: UIDatePicker)
    {
        updateDatePickerLabel()
    }
    
    
    //MARK: - Remind Switch Functions
    @IBAction func switchFlipped(_ sender: UISwitch)
    {        
        datePicker.isUserInteractionEnabled = sender.isOn ? true : false
    }
    
    //MARK: - UIbutton functions
    
    @IBAction func btnSaveTapped(_ sender: UIButton)
    {
        saveDetails()
    }
    
    @IBAction func btnCancelTapped(_ sender: UIButton)
    {
        noteTextView.text = selectedTask?.note
    }
    
    @IBAction func btnDeleteTapped(_ sender: UIButton)
    {
        let alert = UIAlertController(title: "", message: "Are you sure you want to delete the note", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Yes", style: .default) { (action) in
            
            //Delete the row from the data source
            self.selectedTask?.ref!.updateChildValues(["note": ""])
            self.noteTextView.text = nil
        }
        
        let cancel = UIAlertAction(title: "No", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnExitTapped(_ sender: UIButton)
    {
        //Delete the row from the data source
//        if globalNote != nil
//        {
//            context.delete(globalNote!)
//            saveDetails()
//        }
        navigationController?.popViewController(animated: true)
    }
    //MARK: - Model Manipulation Methods
    
    func saveDetails()
    {
        if(!noteTextView.text.isEmpty)
        {
            selectedTask?.ref!.updateChildValues(["note": noteTextView.text!])
        }
        
        if(segmentPriority.selectedSegmentIndex > 0 )
        {
            selectedTask?.ref!.updateChildValues(["priority": segmentPriority.selectedSegmentIndex])
        }
        
        if(switchRemind.isOn)
        {
            selectedTask?.ref!.updateChildValues(["remind": true])
            //selectedTask?.ref!.updateChildValues(["remind": switchRemind.isOn ? true : false])
        }
        
        if(!lblDate.text!.isEmpty)
        {
            selectedTask?.ref!.updateChildValues(["dueDate": lblDate.text ?? ""])
        }
    }
    
    //MARK: - Dismiss the keyboard
    @objc func DismissKeyboard()
    {
        //Causes the view to resign from the status of first responder.
        noteTextView.resignFirstResponder()
    }
}
