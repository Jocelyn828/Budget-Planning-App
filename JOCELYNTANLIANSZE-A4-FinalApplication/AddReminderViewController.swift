//
//  AddReminderViewController.swift
//  JOCELYNTANLIANSZE-A4-FinalApplication
//
//  Created by Lian Sze Jocelyn Tan on 17/05/2024.
//

import UIKit

class AddReminderViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var repeatButton: UIButton!
    
    // MARK: - Properties
    
    weak var delegate: setReminderDelegate?
    weak var databaseController: DatabaseProtocol?
    
    // MARK: - Actions
    
    /// Called when the save button is tapped to save the reminder
    @IBAction func saveAction(_ sender: Any) {
        guard let content = contentTextField.text else {
            return
        }
        
        let currentTime = Date()
        
        // Ensure that the content field is not empty
        if content.isEmpty {
            displayMessage(title: "Error",message: "Please ensure all fields are filled.")
            return
        }
        
        let targetDate = datePicker.date
        let uniqueID = UUID().uuidString
        let shouldRepeat = (repeatButton.titleLabel?.text)!
        
        // Check if the date is in the past
        if targetDate <= currentTime {
            // Display error message
            displayMessage(title: "Invalid Date", message: "You cannot set a reminder for a date in the past. Please select a future date.")
            return
        }
        
        // Add the reminder to the database and notify the delegate
        let _ = databaseController?.addReminder(id: uniqueID, content: content, shouldRepeat: shouldRepeat, date: targetDate)
        delegate?.reminderSetUp(id: uniqueID, reminder: content, shouldRepeat: shouldRepeat, date: targetDate)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        setPopUpButton()
    }
    
    /// online references: https://www.youtube.com/watch?v=4yZR6AC1PIU
    /// Set up pop up button menu for selecting repeat options
    func setPopUpButton() {
        repeatButton.setTitle("Repeat", for: .normal)
        // Pop-up button
        let optionClosure = {(action: UIAction) in
            print(action.title)
        }
        
        repeatButton.menu = UIMenu(children: [
            UIAction(title: "None", handler: optionClosure),
            UIAction(title: "Daily", handler: optionClosure),
            UIAction(title: "Weekly", handler: optionClosure),
            UIAction(title: "Monthly", handler: optionClosure)
        ])
        
        repeatButton.showsMenuAsPrimaryAction = true
        repeatButton.changesSelectionAsPrimaryAction = true
    }
    
}
    
