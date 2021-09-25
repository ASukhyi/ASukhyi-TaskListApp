//
//  TasksListViewController.swift
//  TasksList
//
//  Created by Андрей on 22.09.2021.
//

import UIKit
import RealmSwift

class TasksListViewController: UITableViewController {
    
    private enum SortType: String {
        case name
        case date
    }
    
    // MARK: Outlets
    
    @IBOutlet private weak var sortSegmentedControl: UISegmentedControl!
    
    // MARK: Properties
    
    private var tasksLists: Results<TasksList>!
    private var sortType: SortType = .name
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasksLists = realm.objects(TasksList.self)
        navigationItem.leftBarButtonItem = editButtonItem
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
        navigationItem.largeTitleDisplayMode = .always
        sortList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let tasksList = tasksLists[indexPath.row]
            let tasksVC = segue.destination as! TasksViewController
            tasksVC.currentTasksList = tasksList
        }
    }
    
    // MARK: Private Methods
    
    private func sortList() {
        tasksLists = tasksLists.sorted(byKeyPath: sortType.rawValue)
        tableView.reloadData()
    }
    
    // MARK: Actions
    
    @IBAction private func addButton(_ sender: Any) {
        alertForAddAndUpdateList()
    }
    
    @IBAction private func sortingList(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        sortType = selectedIndex == 0 ? .name : .date
        sortList()
    }
    
    // MARK: Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        
        let tasksList = tasksLists[indexPath.row]
        cell.configure(with: tasksList)
        
        return cell
    }
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt
                                indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentList = tasksLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { _, _,_  in StorageManager.deleteList(currentList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal,
                                            title: "Edit") { _, _, _ in
            self.alertForAddAndUpdateList(currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        let doneAction = UIContextualAction(style: .normal,
                                            title: "Done") { _, _, _ in StorageManager.makeAllDone(currentList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [deleteAction, doneAction, editAction])
    }
}

extension TasksListViewController {
    
    private func alertForAddAndUpdateList(_ listName: TasksList? = nil,
                                          completion: (() -> Void)? = nil) {
        var title = "New List"
        var doneButton = "Save"
        
        if listName !== nil {
            title = "Edit List"
            doneButton = "Update"
        }
        let alert = UIAlertController(title: title, message: "Please insert new value", preferredStyle: .alert)
        var alertTextField: UITextField!
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { [weak self] _ in
            guard let newList = alertTextField.text, !newList.isEmpty, let self = self else { return }
            
            if let listName = listName {
                StorageManager.editList(listName, newListName: newList)
                if completion != nil { completion!() }
            } else {
                let tasksList = TasksList()
                tasksList.name = newList
                StorageManager.saveTasksList(tasksList)
                let indexPath = IndexPath(row: self.tasksLists.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            alertTextField = textField
            alertTextField.placeholder = "List Name"
        }
        
        if let listName = listName {
            alertTextField.text = listName.name
        }
        
        present(alert, animated: true)
    }
}



