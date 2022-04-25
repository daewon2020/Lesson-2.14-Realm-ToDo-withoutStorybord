//
//  StorageManager.swift
//  Lesson 2.14 Realm ToDo withoutStorybord
//
//  Created by Константин Андреев on 19.04.2022.
//

import RealmSwift

class StorageManager {
    static var shared = StorageManager()

    let realm = try! Realm()
    
    private init() {}
    
    private func write(completion: ()->()){
        do{
            try realm.write {
                completion()
            }
        } catch let error{
            print(error)
        }
    }
    
    func save(_ taskLists: [TaskList]) {
        write {
            realm.add(taskLists)
        }
    }
    
    func save(_ newlist: TaskList) {
        write {
            realm.add(newlist)
        }
    }
    
    func save(_ newTask: Task) {
        write {
            realm.add(newTask)
        }
    }
    
    func save(_ task: Task, to taskList: TaskList) {
        write {
            taskList.tasks.append(task)
        }
    }
    
    func delete(_ laskList: TaskList, _ tasks: RealmSwift.List<Task>) {
        write {
            realm.delete(tasks)
            realm.delete(laskList)
        }
    }
    
    func delete(_ task: Task) {
        write {
            realm.delete(task)
        }
    }
    
    func edit(_ taskList: TaskList, newValue: String) {
        write {
            taskList.name = newValue
        }
    }
    
    func myDayToggle(task: Task) {
        write {
            task.myDay.toggle()
        }
    }
    
    func isCompletedToggle(task: Task) {
        write {
            task.isCompleted.toggle()
            task.setValue(Date.now, forKey: "createDate")
        }
    }
    
    func isFavoriteToggle(task: Task) {
        write {
            task.isFavorite.toggle()
        }
    }
    
    func getCurrentTaskForList(_ taskList: TaskList) -> Results<Task> {
        taskList.tasks.where { $0.isCompleted ==  false }.sorted(byKeyPath: "createDate", ascending: false)        
    }
    
    func getCompletedTaskForList(_ taskList: TaskList) -> Results<Task> {
        taskList.tasks.where { $0.isCompleted ==  true }.sorted(byKeyPath: "createDate", ascending: false)
    }
    
    func getFavoriteCurrentTasks() -> Results<Task> {
        StorageManager.shared.realm.objects(Task.self).where { $0.isFavorite == true && $0.isCompleted == false }.sorted(byKeyPath: "createDate", ascending: false)
    }
    
    func getFavoriteCompletedTasks() -> Results<Task> {
        StorageManager.shared.realm.objects(Task.self).where { $0.isFavorite == true && $0.isCompleted == true }.sorted(byKeyPath: "createDate", ascending: false)
    }
    
    func getMyDayCurrentTasks() -> Results<Task> {
        StorageManager.shared.realm.objects(Task.self).where { $0.myDay == true && $0.isCompleted == false }.sorted(byKeyPath: "createDate", ascending: false)
    }
    
    func getMyDayCompletedTasks() -> Results<Task> {
        StorageManager.shared.realm.objects(Task.self).where { $0.myDay == true && $0.isCompleted == true }.sorted(byKeyPath: "createDate", ascending: false)
    }
    
    func getFavoriteTasksCount() -> Int {
        StorageManager.shared.realm.objects(Task.self).where { $0.isFavorite == true && $0.isCompleted == false } .count
    }
    
    func getMyDayTasksCount() -> Int {
        StorageManager.shared.realm.objects(Task.self).where { $0.myDay == true && $0.isCompleted == false } .count
    }
    
    func updateFor(_ task: Task, name: String, note: String, daeadline: Date? ) {
        write {
            task.setValue(name, forKey: "taskName")
            task.setValue(daeadline, forKey: "deadline")
            task.setValue(note, forKey: "note")
        }
    }
    
    func getSortedByNameTaskList() -> Results<TaskList> {
        StorageManager.shared.realm.objects(TaskList.self).sorted(byKeyPath: "name", ascending: true)
    }
    
    func getSortedByDateTaskList() -> Results<TaskList> {
        StorageManager.shared.realm.objects(TaskList.self).sorted(byKeyPath: "createDate", ascending: false)
        
    }
}
