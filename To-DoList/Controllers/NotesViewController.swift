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
    @IBOutlet weak var noteTextView: UITextView!
    
    var ref: DatabaseReference!

    var globalNote:Notes? = nil
    var globalNoteText:String? = nil
    var isNew = true
    
    var selectedTask:Task? = nil //Value passed from prev. View Controller
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ref = Database.database().reference(withPath: "Task")

        setContent()
        
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        noteTextView.addGestureRecognizer(swipe)
    }
    
    func setContent()
    {
        if selectedTask != nil
        {
            titleTextView.text = selectedTask?.name
            noteTextView.text = selectedTask?.note
        }
        
        //titleTextView.text = selectedCategory.name
//        if(globalNote != nil)
//        {
//            if let note = globalNote?.note
//            {
//                noteTextView.text = note
//            }
//        }
    }
    
    //MARK: - UIbutton functions
    
    @IBAction func btnSaveTapped(_ sender: UIButton)
    {
        if(!noteTextView.text.isEmpty)
        {
            saveNotes()
        }
//        let newNote = Notes(context: self.context)
//
//        if(isNew)
//        {
//            newNote.parentCategory = self.selectedCategory
//            newNote.note = noteTextView.text
//            isNew = false
//
//            self.saveNotes()
//        }
//        else
//        {
//            loadUpdateNotes(isUpdate:true)
//        }
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
//            saveNotes()
//        }
        navigationController?.popViewController(animated: true)
    }
    //MARK: - Model Manipulation Methods
    
    func saveNotes()
    {
        selectedTask?.ref!.updateChildValues(["note": noteTextView.text!])
    }
    
    //MARK: - Dismiss the keyboard
    
    @objc func DismissKeyboard()
    {
        //Causes the view to resign from the status of first responder.
        noteTextView.resignFirstResponder()
    }
}
