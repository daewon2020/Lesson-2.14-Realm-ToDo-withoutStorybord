//
//  TaskListTableViewCell.swift
//  Lesson 2.14 Realm ToDo withoutStorybord
//
//  Created by Константин Андреев on 19.04.2022.
//

import UIKit

class TaskListTableViewCell: UITableViewCell {

    @IBOutlet var tasksCount: UILabel!
    @IBOutlet var listName: UILabel!
    @IBOutlet var taskListIcon: UIButton!
    @IBOutlet var customView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = DefaultConfig.shared.backgroundcolor
        customView.layer.cornerRadius = DefaultConfig.shared.cornerRadius
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
