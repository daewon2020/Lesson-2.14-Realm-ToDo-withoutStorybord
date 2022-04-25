//
//  AppListsModel.swift
//  Lesson 2.14 Realm ToDo withoutStorybord
//
//  Created by Константин Андреев on 24.04.2022.
//

struct AppTableCell {
    let name: ViewControllerType
    let icon: String
    
    static func getAppTaskLists() -> [AppTableCell] {
        [
            AppTableCell(name: .myDayVC, icon: "myDay"),
            AppTableCell(name: .favoriteVC, icon: "bookmarkUnchecked"),
        ]
    }
}

enum ViewControllerType: String {
    case favoriteVC = "Favorite"
    case myDayVC = "My day"
    case taskListVC = "Task List View Controller"
}
