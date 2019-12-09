//
//  Category.swift
//  To-DoList
//
//  Created by Sujata on 04/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import Foundation
import Firebase

class Task
{
    let ref: DatabaseReference?
    var name: String
    var done: Bool 
    var note: String? = nil
    
    var priority: Int = 0
    var remind: Bool = false
    var dueDate: String? = nil
    var creationDate: String? = nil
    
    init(name: String, done: Bool)
    {
        self.ref = nil
        self.name = name
        self.done = done
    }
    
    init?(snapshot: DataSnapshot)
    {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let done = value["done"] as? Bool,
            let note = value["note"] as? String,
            let priority = value["priority"] as? Int,
            let remind = value["remind"] as? Bool,
            let dueDate = value["dueDate"] as? String,
            let creationDate = value["creationDate"] as? String else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.name = snapshot.key
        self.done = done
        self.note = note
        self.priority = priority
        self.remind = remind
        self.dueDate = dueDate
        self.creationDate = creationDate
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "done": done,
            "note": note ?? "",
            "priority": priority,
            "remind": remind,
            "dueDate": dueDate ?? "",
            "creationDate": creationDate ?? ""
        ]
    }
}
