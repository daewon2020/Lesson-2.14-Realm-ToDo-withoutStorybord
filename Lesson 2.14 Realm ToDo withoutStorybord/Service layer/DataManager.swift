//
//  DataManager.swift
//  Lesson 2.14 Realm ToDo withoutStorybord
//
//  Created by Константин Андреев on 20.04.2022.
//
import Foundation

class DataManager {
    static var shared = DataManager()
    
    private init() {}
    
    func createTempData(_ completion: @escaping() -> Void) {
        if !UserDefaults.standard.bool(forKey: "done") {
            UserDefaults.standard.set(true, forKey: "done")
            
            let shoppingList = TaskList()
            shoppingList.name = "Продукты"
            
            let bread = Task(value: ["Хлеб", "Без глютена"])
            let apples = Task(value: ["Яблоки","Красные"])
            shoppingList.tasks.append(bread)
            shoppingList.tasks.append(apples)
            
            let reconstruction = TaskList()
            reconstruction.name = "Ремонт"
            let nails = Task(value: ["Гвозди","",Date.now,Date.now, false, true, true])
            reconstruction.tasks.append(nails)
            DispatchQueue.main.async {
                StorageManager.shared.save([shoppingList,reconstruction])
                
                completion()
            }
        }
    }
}
