//
//  Task.swift
//  TasksList
//
//  Created by Андрей on 22.09.2021.
//

import RealmSwift

class Task: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var note = ""
    @objc dynamic var date = Date()
    @objc dynamic var IsComplete = false
}
