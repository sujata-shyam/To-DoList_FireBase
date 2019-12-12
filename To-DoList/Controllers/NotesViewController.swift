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
import UserNotifications

class NotesViewController: UIViewController
{
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var switchRemind: UISwitch!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var segmentPriority: UISegmentedControl!
    @IBOutlet weak var noteTextView: UITextView!
    
    var ref: DatabaseReference!

    //var globalNote:Notes? = nil
    //var globalNoteText:String? = nil
    //var isNew = true
    //var isAlertShown = false
    
    var selectedTask:Task? = nil //Value passed from prev. View Controller
    
    let formatter = DateFormatter()
    
    let center = UNUserNotificationCenter.current()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ref = Database.database().reference(withPath: "Task")

        setDateFomatter()
        setDatePicker()
        updateTextView()
        
        noteTextView.delegate = (self as UITextViewDelegate)
        
        let noteSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(noteDismissKeyboard))
        
        let titleSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(titleDismissKeyboard))
        
        noteTextView.addGestureRecognizer(noteSwipe)
        titleTextView.addGestureRecognizer(titleSwipe)
        
        //updateYearConstraints()
    }
    
    func setDateFomatter()
    {
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
    }
    
    func setDatePicker()
    {
        datePicker.backgroundColor = UIColor.clear
        datePicker.layer.cornerRadius = 5.0
        //datePicker.datePickerMode = .date
        //datePicker.maximumDate = Date()
        //datePicker.isHidden = true
        datePicker.tintColor = UIColor.white
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")

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
            }
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
            datePicker.isUserInteractionEnabled = true
            
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
    }
    
    func updateDatePickerLabel()
    {
        lblDate.text = formatter.string(from: datePicker.date)
    }
    
    //MARK: - Priority Segment Functions
//    @IBAction func priorityChanged(_ sender: UISegmentedControl)
//    {
//        switch sender.selectedSegmentIndex
//        {
//            case 0:
//                print("None")
//            case 1:
//                print("Imp")
//            case 2:
//                print("Very Imp")
//            default:
//                print("default")
//        }
//    }
    
    //MARK: - Date Picker Function
    @IBAction func datePickerUpdated(_ sender: UIDatePicker)
    {
        updateDatePickerLabel()
    }
    
    //MARK: - Remind Switch Functions
    @IBAction func switchFlipped(_ sender: UISwitch)
    {        
        datePicker.isUserInteractionEnabled = sender.isOn ? true : false
        
        if(sender.isOn)
        {
            enableNotification()
            updateYearConstraints()
        }
        else
        {
            lblDate.text = ""
        }
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
        navigationController?.popViewController(animated: true)
    }
    //MARK: - Model Manipulation Methods
    
    func saveDetails()
    {
        selectedTask?.ref!.updateChildValues(["note": noteTextView.text!])
        
        selectedTask?.ref!.updateChildValues(["priority": segmentPriority.selectedSegmentIndex])
        
        //        if(!noteTextView.text.isEmpty)
//        {
//            selectedTask?.ref!.updateChildValues(["note": noteTextView.text!])
//        }
        
//        if(segmentPriority.selectedSegmentIndex > 0 )
//        {
//            selectedTask?.ref!.updateChildValues(["priority": segmentPriority.selectedSegmentIndex])
//        }
        
        if(switchRemind.isOn)
        {
            if(!lblDate.text!.isEmpty)
            {
                selectedTask?.ref!.updateChildValues(["dueDate": lblDate.text ?? ""])
            }
            
            selectedTask?.ref!.updateChildValues(["remind": true])
            self.scheduleNotification()
        }
        else if(!switchRemind.isOn)
        {
            selectedTask?.ref!.updateChildValues(["dueDate": ""])
            selectedTask?.ref!.updateChildValues(["remind": false])
        }
        
    }
    
    //MARK: - Dismiss the keyboard
    @objc func titleDismissKeyboard()
    {
        //Causes the view to resign from the status of first responder.
        titleTextView.resignFirstResponder()
    }
    
    @objc func noteDismissKeyboard()
    {
        noteTextView.resignFirstResponder()
    }
    
    func showAlert(_ alertMessage:String)
    {
//        let alert = UIAlertController(title: "", message: "Task due-date passed", preferredStyle: .alert)

        let alert = UIAlertController(title: "", message: alertMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Notification Functions
    
    func enableNotification()
    {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay")
            } else {
                print("D'oh")
            }
        }
    }
    
    func scheduleNotification()
    {
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            
            if settings.alertSetting == .enabled
            {
                let content = UNMutableNotificationContent()
            
                content.title = "To-Do Reminder"
                content.body = self.selectedTask!.name
                content.sound = UNNotificationSound.default
            
                
//            DispatchQueue.main.async {
//                //content.badge = NSNumber(integerLiteral: UIApplication.shared.applicationIconBadgeNumber + 1)
//                content.badge = 1
//            }
            
                
                if let dateComponents = self.configureDateComponent()
                {
                    let trigger = UNCalendarNotificationTrigger(
                        dateMatching: dateComponents, repeats: false)
            
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    self.center.add(request)
                }
            }
        }
    }
    
    func configureDateComponent()->DateComponents?
    {
        var tempDate = Date()
        
        DispatchQueue.main.async
        {
            tempDate = self.datePicker.date
        }
        
        var dateComponents = DateComponents()
        
        dateComponents.calendar = Calendar.current
        
        dateComponents.hour = dateComponents.calendar!.component(.hour, from: tempDate)
        dateComponents.minute = dateComponents.calendar!.component(.minute, from: tempDate)
        
        dateComponents.year = dateComponents.calendar!.component(.year, from: tempDate)
        dateComponents.month = dateComponents.calendar!.component(.month, from: tempDate)
        dateComponents.day = dateComponents.calendar!.component(.day, from: tempDate)
        
        return dateComponents
    }
}

extension NotesViewController: UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        animateViewMoving(up: true, moveValue: 100)
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        animateViewMoving(up: false, moveValue: 100)
    }
    
    // Lifting the view up when keyboard is displayed
    func animateViewMoving (up:Bool, moveValue :CGFloat)
    {
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}
