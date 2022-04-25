//
//  TaskListTableViewController.swift
//  Lesson 2.14 Realm ToDo
//
//  Created by Константин Андреев on 19.04.2022.
//

import UIKit
import RealmSwift

class TaskListTableViewController: UITableViewController {

    private var taskLists: Results<TaskList>!
    private var appTaskLists: [AppTableCell]!
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = Realm.Configuration(
            schemaVersion: 9)
        Realm.Configuration.defaultConfiguration = config
        
        view.backgroundColor = DefaultConfig.shared.backgroundcolor
        taskLists = StorageManager.shared.realm.objects(TaskList.self).sorted(byKeyPath: "createDate", ascending: false)
        
        appTaskLists = AppTableCell.getAppTaskLists()
        DataManager.shared.createTempData {
            self.tableView.reloadData()
        }
    
        setupTableView()
        setupNavigationController()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "TaskListTableViewCell", bundle: nil), forCellReuseIdentifier: "customTaskListID")
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupNavigationController() {
        title = "Lists"
        DefaultConfig.shared.setDefaults(for: navigationController)
        
        let addBarButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTaskListAlert)
        )
        let sortBarButton = UIBarButtonItem(title: "Sort", image: nil, primaryAction: nil, menu: getSortMenu())
        
        navigationItem.rightBarButtonItems = [addBarButton, sortBarButton]
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    //----------
    // MARK: - Table view data source and delegate
    //----------
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return appTaskLists.count
        } else {
            return taskLists.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "customTaskListID", for: indexPath) as? TaskListTableViewCell else { return UITableViewCell()}
        if indexPath.section == 0 {
            let image = appTaskLists[indexPath.row].icon
            let taskListName = appTaskLists[indexPath.row].name
            cell.listName.text = taskListName.rawValue
            cell.taskListIcon.setImage(UIImage(named: image), for: .normal)
            
            switch taskListName {
            case .myDayVC: cell.tasksCount.text = "\(StorageManager.shared.getMyDayTasksCount())"
            case .favoriteVC: cell.tasksCount.text = "\(StorageManager.shared.getFavoriteTasksCount())"
            default: cell.tasksCount.text = "0"
            }
        } else {
            let list = taskLists[indexPath.row]
            cell.listName.text = list.name
            cell.taskListIcon.setImage(UIImage(named: "list"), for: .normal)
            cell.tasksCount.text = "\(list.tasks.count)"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0 {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            let list = self.taskLists[indexPath.row]
            
            StorageManager.shared.delete(list, list.tasks)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .destructive, title: "Edit") { _, _, isDone in
            let taskList = self.taskLists[indexPath.row]
            self.showAlert(taskList: taskList) { newValue in
                StorageManager.shared.edit(taskList, newValue: newValue)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
            isDone(true)
        }
        
        deleteAction.image = getSwipeActionImage(systemImageName: "delete.left", color: DefaultConfig.shared.deleteColor)
        editAction.image = getSwipeActionImage(systemImageName: "square.and.pencil", color: DefaultConfig.shared.editColor)
        deleteAction.backgroundColor = DefaultConfig.shared.backgroundcolor
        editAction.backgroundColor = DefaultConfig.shared.backgroundcolor
        
        let actions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
       
        return actions
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskVC: TasksTableViewController
        if indexPath.section == 1 {
            taskVC = TasksTableViewController(viewControllerType: .taskListVC)
            let tasklist = taskLists[indexPath.row]
            taskVC.taskList = tasklist
            
        }else {
            taskVC = TasksTableViewController(viewControllerType: appTaskLists[indexPath.row].name)
        }
        navigationController?.pushViewController(taskVC, animated: true)
    }
}

//----------
//MARK: - Private methods
//----------

extension TaskListTableViewController {
    private func getSwipeActionImage(systemImageName: String, color: UIColor) -> UIImage? {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17.0, weight: .bold, scale: .large)
        return UIImage(systemName: systemImageName, withConfiguration: largeConfig)?.withTintColor(.white, renderingMode: .alwaysTemplate).addBackgroundCircle(color) ?? nil
    }
    
    @objc private func addTaskListAlert() {
        showAlert { newValue in
            let list = TaskList(value: [newValue])
            StorageManager.shared.save(list)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        }
    }
    
    private func showAlert(taskList: TaskList? = nil, complition: @escaping (String) -> ()) {
        let titleAC = taskList == nil ? "New task list" : "Edit list"
        let messageAC = taskList == nil ? "Please set name for new list" : "Please edit name for task list"
        let titleAction = taskList == nil ? "Add" : "Edit"
        let textForTextField = taskList == nil ? "" : taskList?.name
        
        let alertController = UIAlertController(title: titleAC, message: messageAC, preferredStyle: .alert)
        let okAction = UIAlertAction(title: titleAction, style: .default) { _ in
            guard let newValue = alertController.textFields?.first?.text, !newValue.isEmpty else { return }
            complition(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.addTextField { textField in
            textField.placeholder = "List name"
            textField.text = textForTextField
        }
        
        present(alertController, animated: true)
    }
    
    private func getSortMenu() -> UIMenu {
        let sortName = UIAction(title: "Task list name") { action in
            self.taskLists = StorageManager.shared.getSortedByNameTaskList()
            self.tableView.reloadData()
        }
        let sortDate = UIAction(title: "Task create date") { action in
            self.taskLists = StorageManager.shared.getSortedByDateTaskList()
            self.tableView.reloadData()
        }
        
        let menu = UIMenu(title: "Sort by", options: .displayInline, children: [sortName, sortDate])
        
        return menu
    }
}

//----------
//MARK: - UIImage extension
//----------
extension UIImage {

    func addBackgroundCircle(_ color: UIColor?) -> UIImage? {

        let circleDiameter = max(size.width * 2, size.height * 2)
        let circleRadius = circleDiameter * 0.5
        let circleSize = CGSize(width: circleDiameter, height: circleDiameter)
        let circleFrame = CGRect(x: 0, y: 0, width: circleSize.width, height: circleSize.height)
        let imageFrame = CGRect(x: circleRadius - (size.width * 0.5), y: circleRadius - (size.height * 0.5), width: size.width, height: size.height)

        let view = UIView(frame: circleFrame)
        view.backgroundColor = color ?? .systemRed
        view.layer.cornerRadius = circleDiameter * 0.5

        UIGraphicsBeginImageContextWithOptions(circleSize, false, UIScreen.main.scale)

        let renderer = UIGraphicsImageRenderer(size: circleSize)
        let circleImage = renderer.image { ctx in
            view.drawHierarchy(in: circleFrame, afterScreenUpdates: true)
        }

        circleImage.draw(in: circleFrame, blendMode: .normal, alpha: 1.0)
        draw(in: imageFrame, blendMode: .normal, alpha: 1.0)

        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image
    }
}


