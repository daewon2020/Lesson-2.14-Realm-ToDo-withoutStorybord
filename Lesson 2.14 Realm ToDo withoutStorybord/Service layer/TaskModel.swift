//
//  TaskModel.swift
//  Lesson 2.14 Realm ToDo withoutStorybord
//
//  Created by Константин Андреев on 19.04.2022.
//
import RealmSwift

class TaskList: Object {
    @Persisted var name = ""
    @Persisted var createDate = Date()
    @Persisted var tasks = List<Task>()
}

class Task: Object {
    @Persisted var taskName = ""
    @Persisted var note = ""
    @Persisted var createDate = Date()
    @Persisted var deadline: Date? = nil
    @Persisted var isCompleted = false
    @Persisted var myDay = false
    @Persisted var isFavorite = false
}
