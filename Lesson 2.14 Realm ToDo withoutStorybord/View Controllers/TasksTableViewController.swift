//
//  TasksTableViewController.swift
//  Lesson 2.14 Realm ToDo
//
//  Created by Константин Андреев on 18.04.2022.
//

import UIKit
import RealmSwift
import SwiftUI

protocol TasksTableViewControlDelegate {
    func isCompletedButtonPressed(cell: TaskTableViewCell)
    func isFavoriteButtonPressed(cell: TaskTableViewCell)
    func taskNameButtomPressed(cell: TaskTableViewCell)
}

class TasksTableViewController: UITableViewController {
    
    var taskList: TaskList!
    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!
    private var viewControllerType: ViewControllerType?
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = DefaultConfig.shared.backgroundcolor
        fetchData()
        setupTableView()
        setupNavigationController()
    }
    
    //----------
    // MARK: - Table view data source
    //----------
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Current tasks" : "Completed tasks"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        var content = header.defaultContentConfiguration()
        content.text = section == 0 ? "Current tasks" : "Completed tasks"
        content.textProperties.font = .boldSystemFont(ofSize: 24)
        content.textProperties.color = .white
        header.contentConfiguration = content
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "customCellID", for: indexPath) as? TaskTableViewCell else { return UITableViewCell()}
        
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        let taskName = task.taskName
                
        var subtitle = task.myDay ? "My Day" : ""
        cell.taskTitle.setTitle(taskName, for: .normal)
        cell.taskTitle.setAttributedTitle(nil, for: .normal)
        cell.delegate = self
        
        if indexPath.section == 1 {
            let attributeTitle = NSAttributedString(
                string: taskName,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            cell.taskTitle.setAttributedTitle(attributeTitle, for: .normal)
        }
        
        if task.deadline == nil {
            cell.taskTitle.configuration?.subtitle = "\(subtitle)"
            
        } else {
            if subtitle != "" {
                subtitle += " |"
            }
    
            let firstPartString = AttributedString("\(subtitle) Deadline: ")
            var secondPartString = AttributedString(task.deadline?.formatted(date: .abbreviated, time: .omitted) ?? "")
            if let deadline = task.deadline, deadline < Date.now {
                secondPartString.setAttributes(AttributeContainer([NSAttributedString.Key.foregroundColor : UIColor.red]))
            }
            
            cell.taskTitle.configuration?.attributedSubtitle = firstPartString
            cell.taskTitle.configuration?.attributedSubtitle?.append(secondPartString)
        }
        
        let isCompletedImage = task.isCompleted ? UIImage(named: "checkboxChecked") : UIImage(named: "checkboxUnchecked")
        let isFavoriteImage = task.isFavorite ? UIImage(named: "bookmarkChecked") : UIImage(named: "bookmarkUnchecked" )
        
        cell.isCompleted.setImage(isCompletedImage, for: .normal)
        cell.isFavorite.setImage(isFavoriteImage, for: .normal)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0 ? self.currentTasks[indexPath.row] : self.completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
        
            StorageManager.shared.delete(task)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        deleteAction.image = getSwipeActionImage(systemImageName: "delete.left", color: DefaultConfig.shared.deleteColor)
        deleteAction.backgroundColor = DefaultConfig.shared.backgroundcolor
        
        let actions = UISwipeActionsConfiguration(actions: [deleteAction])
       
        return actions
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0 ? self.currentTasks[indexPath.row] : self.completedTasks[indexPath.row]
        let myDayAction = UIContextualAction(style: .normal, title: "") { _, _, isDone in
            StorageManager.shared.myDayToggle(task: task)
            switch self.viewControllerType {
            case .myDayVC:
                tableView.deleteRows(at: [indexPath], with: .automatic)
            case .taskListVC, .favoriteVC:
                tableView.reloadRows(at: [indexPath], with: .automatic)
            case .none:
                return
            }
            
            
            isDone(true)
        }
        
        myDayAction.image = getSwipeActionImage(systemImageName: "sun.max", color: DefaultConfig.shared.myDayColor)
    
        myDayAction.backgroundColor = DefaultConfig.shared.backgroundcolor
        let actions = UISwipeActionsConfiguration(actions: [myDayAction])
        actions.performsFirstActionWithFullSwipe = false
       
        return actions
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && currentTasks.count == 0 {
            return 0
        }
        if section == 1 && completedTasks.count == 0 {
            return 0
        }
        return 30
    }
}
//----------
//MARK: - Private methods
//----------
extension TasksTableViewController {
    convenience init(viewControllerType: ViewControllerType) {
        self.init()
        self.viewControllerType = viewControllerType
    }
    
    @objc private func addTaskAlert() {
        showAlert { newValue in
            let task = Task(value: [newValue])
            switch self.viewControllerType {
            case .myDayVC:
                task.myDay = true
                StorageManager.shared.save(task)
            case .favoriteVC:
                task.isFavorite = true
                StorageManager.shared.save(task)
            case .taskListVC:
                StorageManager.shared.save(task, to: self.taskList)
            case .none:
                return
            }
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
    
    private func getSwipeActionImage(systemImageName: String, color: UIColor) -> UIImage? {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17.0, weight: .bold, scale: .large)
        return UIImage(systemName: systemImageName, withConfiguration: largeConfig)?.withTintColor(.white, renderingMode: .alwaysTemplate).addBackgroundCircle(color) ?? nil
    }
    
    private func showAlert(complition: @escaping (String) -> ()) {
        
        let alertController = UIAlertController(title: "New task", message: "Please set name for new task", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let newValue = alertController.textFields?.first?.text, !newValue.isEmpty else { return }
            complition(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.addTextField { textField in
            textField.placeholder = "Task name"
        }
        
        present(alertController, animated: true)
    }
    
    private func fetchData() {
        switch viewControllerType {
        case .favoriteVC:
            currentTasks = StorageManager.shared.getFavoriteCurrentTasks()
            completedTasks = StorageManager.shared.getFavoriteCompletedTasks()
        case .myDayVC:
            currentTasks = StorageManager.shared.getMyDayCurrentTasks()
            completedTasks = StorageManager.shared.getMyDayCompletedTasks()
        case .taskListVC:
            currentTasks = StorageManager.shared.getCurrentTaskForList(taskList)
            completedTasks = StorageManager.shared.getCompletedTaskForList(taskList)
        case .none:
            return
        }
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "customCellID")
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigationController() {
        
        if viewControllerType != .taskListVC {
            title = viewControllerType?.rawValue
        } else {
            title = taskList.name
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = DefaultConfig.shared.backgroundcolor
        
        DefaultConfig.shared.setDefaults(for: navigationController)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTaskAlert)
        )
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
}

//----------
//MARK: - TasksTableViewControlDelegate
//----------

extension TasksTableViewController: TasksTableViewControlDelegate {
    
    func isCompletedButtonPressed(cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        if indexPath.section == 0 {
            
            StorageManager.shared.isCompletedToggle(task: currentTasks[indexPath.row])
            tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 1))
            tableView.reloadRows(at: [indexPath,IndexPath(row: 0, section: 1)], with: .automatic)
            
            return
        }
        StorageManager.shared.isCompletedToggle(task: completedTasks[indexPath.row])
        
        tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
        tableView.reloadRows(at: [indexPath,IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    func isFavoriteButtonPressed(cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        StorageManager.shared.isFavoriteToggle(task: task)
        if viewControllerType == .favoriteVC {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func taskNameButtomPressed(cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let task = indexPath.section == 0 ? self.currentTasks[indexPath.row] : self.completedTasks[indexPath.row]
        let taskVC = DetailTaskViewController()
        taskVC.task = task
        navigationController?.pushViewController(taskVC, animated: true)
    }
    
    
}
