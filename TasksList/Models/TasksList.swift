//
//  TasksList.swift
//  TasksList
//
//  Created by Андрей on 22.09.2021.
//

import RealmSwift

class TasksList: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    let tasks = List<Task>()
    
}
