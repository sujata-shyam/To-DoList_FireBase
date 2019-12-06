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
            let note = value["note"] as? String else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.name = snapshot.key
        self.done = done
        self.note = note
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "done": done,
            "note": note 
        ]
    }
}
