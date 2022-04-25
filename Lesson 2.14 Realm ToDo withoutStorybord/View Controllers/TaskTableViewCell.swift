//
//  TaskTableViewCell.swift
//  Lesson 2.14 Realm ToDo withoutStorybord
//
//  Created by Константин Андреев on 19.04.2022.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet var isCompleted: UIButton!
    @IBOutlet var taskTitle: UIButton!
    @IBOutlet var isFavorite: UIButton!
    @IBOutlet var customView: UIView!
    
    var delegate: TasksTableViewControlDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = DefaultConfig.shared.backgroundcolor
        customView.layer.cornerRadius = DefaultConfig.shared.cornerRadius
    }
    
    @IBAction func isCompletedButtonPressed() {
        delegate?.isCompletedButtonPressed(cell: self)
    }
    
    @IBAction func isFavoriteButtonPressed() {
        delegate?.isFavoriteButtonPressed(cell: self)
    }
    
    @IBAction func taskNameButtomPressed() {
        delegate?.taskNameButtomPressed(cell: self)
    }
}
