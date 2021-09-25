//
//  TasksViewController.swift
//  TasksList
//
//  Created by Андрей on 22.09.2021.
//

import UIKit
import RealmSwift

class TasksViewController: UITableViewController {
    
    private enum Sections: Int, CaseIterable {
        
        case current = 0
        case completed = 1
        
        public var title: String {
            switch self {
            case .current: return "Current tasks"
            case .completed: return "Completed tasks"
            }
        }
    }
    
    // MARK: Properties
    
    public var currentTasksList: TasksList!
    
    private var currentTasks: Results<Task>!
    private var completeTasks: Results<Task>!
    private var isEditingMode = false
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = currentTasksList.name
        filteringTasks()
        navigationItem.largeTitleDisplayMode = .always
    }
    
    // MARK: Actions
    
    @IBAction private func editButtonPressed(_ sender: Any) {
        isEditingMode.toggle()
        tableView.setEditing(isEditingMode, animated: true)
    }
    
    @IBAction private func addButtonPressed(_ sender: Any) {
        alertForAddAndUpdateList()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .current:
            return currentTasks.count
        case .completed:
            return completeTasks.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Sections(rawValue: section)?.title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        let task: Task!
        task = indexPath.section == 0 ? currentTasks[indexPath.row] : completeTasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt
                                indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var task: Task!
        task = indexPath.section == 0 ? currentTasks[indexPath.row] : completeTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { _, _, _ in StorageManager.deleteTask(task)
            self.filteringTasks()
        }
        
        let editAction = UIContextualAction(style: .normal,
                                            title: "Edit") { _, _, _ in self.alertForAddAndUpdateList(task)
            self.filteringTasks()
        }
        let doneTitle = Sections(rawValue: indexPath.section) == .completed ? "Undone" : "Done"
        let doneAction = UIContextualAction(style: .normal,
                                            title: doneTitle) { _, _, _ in StorageManager.makeDone(task)
            self.filteringTasks()
        }
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        return UISwipeActionsConfiguration(actions: [deleteAction, doneAction, editAction])
    }
    
    private func filteringTasks() {
        currentTasks = currentTasksList.tasks.filter("IsComplete = false")
        completeTasks = currentTasksList.tasks.filter("IsComplete = true")
        tableView.reloadData()
    }
}

extension TasksViewController {
    
    private func alertForAddAndUpdateList(_ taskName: Task? = nil) {
        
        var title = "New Task"
        var doneButton = "Save"
        
        if taskName != nil {
            title = "Edit Task"
            doneButton = "Update"
        }
        let alert = UIAlertController(title: title, message: "Please insert task value", preferredStyle: .alert)
        var taskTextField: UITextField!
        var noteTaskField: UITextField!
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            
            guard let newTask = taskTextField.text, !newTask.isEmpty else { return }
            
            if let taskName = taskName {
                if let newNote = noteTaskField.text, !newNote.isEmpty {
                    StorageManager.editTask(taskName, newTask: newTask, newNote: newNote)
                } else {
                    StorageManager.editTask(taskName, newTask: newTask, newNote: "")
                }
                self.filteringTasks()
                
            } else {
                let task = Task()
                task.name = newTask
                if let note = noteTaskField.text, !note.isEmpty {
                    task.note = note
                }
                StorageManager.saveTask(self.currentTasksList, task: task)
                self.filteringTasks()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            taskTextField = textField
            taskTextField.placeholder = "New Task"
            
            if let taskName = taskName {
                taskTextField.text = taskName.name
            }
        }
        
        alert.addTextField { textField in
            noteTaskField = textField
            noteTaskField.placeholder = "Note"
            
            if let taskName = taskName {
                noteTaskField.text = taskName.note
            }
        }
        present(alert, animated: true)
    }
}
