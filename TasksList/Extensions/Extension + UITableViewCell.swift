//
//  Extension + UITableViewCell.swift
//  TasksList
//
//  Created by Андрей on 24.09.2021.
//

import UIKit

extension UITableViewCell {
    
    func configure(with tasksList: TasksList) {
        let currentTasks = tasksList.tasks.filter("IsComplete = false")
        let completedTasks = tasksList.tasks.filter("IsComplete = true")
        textLabel?.text = tasksList.name
        if !currentTasks.isEmpty {
            detailTextLabel?.text = "\(currentTasks.count)"
            detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
            detailTextLabel?.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        } else if !completedTasks.isEmpty {
            detailTextLabel?.text =  "✓"
            detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            detailTextLabel?.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        } else {
            detailTextLabel?.text = "0"
        }
    }
}
