//
//  AddTransactionViewController.swift
//  JOCELYNTANLIANSZE-A4-FinalApplication
//
//  Created by Lian Sze Jocelyn Tan on 19/04/2024.
//

import UIKit

class AddTransactionViewController: UIViewController, UITextFieldDelegate, CurrencySelectedDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var transactionTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var conversionButton: UIButton!
    
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    
    // MARK: - Properties
    
    let EXPENSE_CAT = ["Groceries","Transport","Entertainment","Meals","Shopping","Household"]
    let INCOME_CAT = ["Income","Salary"]
    
    weak var databaseController: DatabaseProtocol?
    var result: String?
    
    // MARK: - IBActions
    
    /// Called when the transaction type segmented control value is changed
    @IBAction func transactionTypeSegmentValueChanged(_ sender: Any) {
        setPopUpButton()
    }
    
    /// Called when the save button is tapped
    @IBAction func saveButton(_ sender: Any) {
        
        // Ensure that amount, note, and category fields are filled correctly
        guard let amount = amountTextField.text, let note = notesTextField.text, let category = categoryButton.titleLabel?.text else {
            return
        }
        
        // Check if the amount is empty or not a valid number.
        if amount.isEmpty || Double(amount) == nil{
            var errorMsg = ""
            if amount.isEmpty {
                errorMsg += "- Must provide amount\n"
            }
            else if Double(amount) == nil {
                errorMsg += "- Amount must be number\n"
            }
            
            displayMessage(title: "Please ensure all fields are filled correctly",message: errorMsg)
            return
        }
        
        // Add the transaction to the database
        let date = datePicker.date
        let _ = databaseController?.addTransaction(amount: Double(amount), category: category, notes: note, date: date)
        navigationController?.popViewController(animated: true)
    }
    
    /// Dismiss the number pad when the view is tapped outside of the text fields
    @IBAction func dismissNumberPad(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Perform initial setup
        setPopUpButton()
        transactionTypeSegmentValueChanged(self)
        currencyLabel.text = "AUD"
        
        // Users are not allowed to select future date
        let currentDate = Date()
        datePicker.maximumDate = currentDate
        datePicker.date = currentDate
        
        // Configure amount text field
        amountTextField.rightView = conversionButton
        amountTextField.rightViewMode = .always
        
        ///online reference: https://stackoverflow.com/questions/26076054/changing-placeholder-text-color-with-swift
        // Set placeholder text if amount text field is empty
        if amountTextField.text == "" {
            amountTextField.attributedPlaceholder = NSAttributedString(
                string: "00.00",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
            )
        }
        amountTextField.backgroundColor = UIColor(named: "TextFieldWhiteColor")
        amountTextField.textColor = .black
        
        ///online reference: https://stackoverflow.com/questions/49044028/how-to-enable-only-numeric-digit-keyboard-ios-swift
        amountTextField.keyboardType = .decimalPad
        
        // Configure notes text field
        notesTextField.textColor = .black
        notesTextField.backgroundColor = UIColor(named: "TextFieldWhiteColor")
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        amountTextField.delegate = self
        notesTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Update currency label from database settings
        currencyLabel.text = databaseController?.loadSettings().first?.currency
    }
    
    /// Sets up the pop-up button for selecting a transaction category
    func setPopUpButton() {
        let optionClosure = {(action: UIAction) in
                    print(action.title)
                }

        var menuActions: [UIAction] = []
        
        // Generate the menu based on the selected transaction type
        switch transactionTypeSegmentedControl.selectedSegmentIndex {
        
        // Generate expense categories
        case 0:
            for category in EXPENSE_CAT {
                let action = UIAction(title: category, handler: optionClosure)
                menuActions.append(action)
            }
        
        // Generate income categories
        case 1:
            for category in INCOME_CAT {
                let action = UIAction(title: category, handler: optionClosure)
                menuActions.append(action)
            }
        
        // Default to expense categories
        default:
            for category in EXPENSE_CAT {
                let action = UIAction(title: category, handler: optionClosure)
                menuActions.append(action)
            }
        }
        
        categoryButton.menu = UIMenu(children: menuActions)

        categoryButton.showsMenuAsPrimaryAction = true
        categoryButton.changesSelectionAsPrimaryAction = true

    }
    
    /// Display the result from the currency conversion
    func currencyResult(_ result: Double) {
        self.result = String(result)
        amountTextField.text = String(format: "%.2f", result)
        amountTextField.textColor = .black
    }
    
    ///online reference: https://stackoverflow.com/questions/27878732/how-to-dismiss-number-keyboard-after-tapping-outside-of-the-textfield
    /// Dismiss the keyboard when the return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "currencyConversionSegue"{
            let destination = segue.destination as! CurrencyConvertViewController
            destination.delegate = self
        }
    }
    

}
