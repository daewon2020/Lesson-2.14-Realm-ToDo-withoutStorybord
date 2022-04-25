//
//  DetailTaskViewController.swift
//  Lesson 2.14 Realm ToDo withoutStorybord
//
//  Created by Константин Андреев on 23.04.2022.
//

import UIKit


class DetailTaskViewController: UIViewController {
    
    var task: Task!
    
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Name"
        return nameLabel
    }()
    
    lazy var noteLabel: UILabel = {
        let noteLabel = UILabel()
        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        noteLabel.text = "Note"
        return noteLabel
    }()
    
    lazy var deadlineLabel: UILabel = {
        let deadlineLabel = UILabel()
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        deadlineLabel.text = "Deadline"
        return deadlineLabel
    }()
    
    lazy var taskNameTextField: UITextField = {
        let taskNameTextField = UITextField()
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressed))
        toolbar.setItems([doneButton], animated: true)
        taskNameTextField.placeholder = "Task header"

        return taskNameTextField
    }()
    
    lazy var deadlineTexField: UITextField = {
        let deadlineTexField = UITextField()
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressed))
        toolbar.setItems([doneButton], animated: true)
        
        deadlineTexField.placeholder = "Add deadline"
        deadlineTexField.inputView = deadlineDatePicker
        deadlineTexField.inputAccessoryView = toolbar
        deadlineTexField.delegate = self
        
        
        return deadlineTexField
    }()
    
    lazy var noteTextView: UITextView = {
        let noteTextView = UITextView()
        noteTextView.font = .boldSystemFont(ofSize: 12)
        noteTextView.heightAnchor.constraint(equalToConstant: 90.0).isActive = true
        return noteTextView
    }()

    
    
    lazy var deadlineDatePicker: UIDatePicker = {
        let deadlineDatePicker = UIDatePicker()
        deadlineDatePicker.preferredDatePickerStyle = .inline
        deadlineDatePicker.datePickerMode = .date
        deadlineDatePicker.date = .now

        return deadlineDatePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit task"
        view.backgroundColor = .white
        
        setupCustomTextView(noteTextView)
        setupCustomTextField(deadlineTexField, taskNameTextField)
        
        for subView in [taskNameTextField, noteTextView, deadlineTexField, nameLabel, noteLabel, deadlineLabel] {
            view.addSubview(subView)
        }

        setConstraints()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        taskNameTextField.text = task.taskName
        noteTextView.text = task.note
        if task.deadline == nil {
            deadlineTexField.text = ""
        } else {
            deadlineDatePicker.date = task.deadline!
            deadlineTexField.text = "Deadline: " + deadlineDatePicker.date.formatted(date: .abbreviated, time: .omitted)
        }
    }
}

//----------
//MARK:- UITextFieldDelegate and private methods
//----------

extension DetailTaskViewController: UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        deadlineTexField.text = ""
        return false
    }
    
    private func setupCustomTextField(_ customTextFields: UITextField...) {
        for customTextField in customTextFields {
            customTextField.layer.borderWidth = 1
            customTextField.layer.cornerRadius = DefaultConfig.shared.cornerRadius
            customTextField.layer.masksToBounds = true
            customTextField.leftViewMode = .always
            customTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 2))
            customTextField.layer.borderColor = UIColor.black.cgColor
            customTextField.clearButtonMode = .always
            customTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
            customTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 40).isActive = true
            customTextField.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupCustomTextView(_ customTextViews: UITextView...) {
        for customTextView in customTextViews {
            customTextView.translatesAutoresizingMaskIntoConstraints = false
            customTextView.widthAnchor.constraint(equalToConstant: view.frame.width - 40).isActive = true
            customTextView.sizeToFit()
            customTextView.layer.borderWidth = 1
            customTextView.layer.borderColor = UIColor.black.cgColor
            customTextView.layer.cornerRadius = DefaultConfig.shared.cornerRadius
            customTextView.textColor = .black
            customTextView.backgroundColor = .white
            customTextView.isScrollEnabled = true
        }
    }
    
    private func setConstraints() {
        nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        taskNameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
        taskNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        noteLabel.topAnchor.constraint(equalTo: taskNameTextField.bottomAnchor, constant: 10).isActive = true
        noteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        noteTextView.topAnchor.constraint(equalTo: noteLabel.bottomAnchor, constant: 5).isActive = true
        noteTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        deadlineLabel.topAnchor.constraint(equalTo: noteTextView.bottomAnchor, constant: 10).isActive = true
        deadlineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        deadlineTexField.topAnchor.constraint(equalTo: deadlineLabel.bottomAnchor, constant: 5).isActive = true
        deadlineTexField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

    }
    
    @objc private func saveButtonTapped() {
        if taskNameTextField.text!.isEmpty {
            return
        }
        if deadlineTexField.text == "" {
            StorageManager.shared.updateFor(task, name: taskNameTextField.text!, note: noteTextView.text, daeadline: nil)
        }else {
            StorageManager.shared.updateFor(task, name: taskNameTextField.text!, note: noteTextView.text, daeadline: deadlineDatePicker.date)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func doneButtonPressed() {
        deadlineTexField.text = "Deadline: " + deadlineDatePicker.date.formatted(date: .abbreviated, time: .omitted)
        deadlineTexField.endEditing(true)
    }
}
