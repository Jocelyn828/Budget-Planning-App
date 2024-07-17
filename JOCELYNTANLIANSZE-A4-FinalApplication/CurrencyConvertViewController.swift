//
//  CurrencyConvertViewController.swift
//  JOCELYNTANLIANSZE-A4-FinalApplication
//
//  Created by Lian Sze Jocelyn Tan on 20/04/2024.
//

import UIKit

class CurrencyConvertViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    var defaultCurrency = "AUD"
    var conversionRate: Double?
    var rates = [String:Double]()
    
    let REQUEST_STRING = "https://v6.exchangerate-api.com/v6/affce48bf6ae0b92acdf4a7f/latest/"

    // MARK: - Outlets
    
    @IBOutlet weak var convertButton: UIButton!
    @IBOutlet weak var convertFromLabel: UILabel!
    @IBOutlet weak var convertFromButton: UIButton!
    @IBOutlet weak var convertFromTextField: UITextField!
    @IBOutlet weak var currencySourceButton: UIButton!
    
    weak var databaseController: DatabaseProtocol?
    weak var delegate: CurrencySelectedDelegate?
    
    // MARK: - Actions
    
    @IBAction func dismissTextField(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    /// online resource: https://stackoverflow.com/questions/39546856/how-to-open-a-url-in-swift
    @IBAction func currencySourceLink(_ sender: Any) {
        if let url = URL(string: "https://www.exchangerate-api.com/") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
    }
    
    /// Convert currency action
    @IBAction func convertCurrency(_ sender: Any) {
        // Ensure both amount and selected country are provided
        guard let amount = convertFromTextField.text, let country = convertFromButton.titleLabel?.text else {
            return
        }
        
        // Check if amount is empty or not a valid number
        if amount.isEmpty || Double(amount) == nil{
            var errorMsg = ""
            if amount.isEmpty {
                errorMsg += "- Must provide amount\n"
            }
            else if Double(amount) == nil {
                errorMsg += "- Amount must be number\n"
            }
            
            // Display error message if any field is missing or invalid
            displayMessage(title: "Please ensure all fields are filled correctly",message: errorMsg)
            return
        }
        
        // Encode the selected country string for URL
        guard let query_string = country.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Query String can't be encoded.")
            displayMessage(title: "Error", message: "Invalid query string encoding.")
            return
        }
        
        // Construct the URL request
        guard let requestURL = URL(string: REQUEST_STRING + query_string) else {
            print("Invalid URL")
            displayMessage(title: "Error", message: "Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        // Fetch conversion rate from the API
        Task {
            do {
                let (data,response) = try await URLSession.shared.data(for: urlRequest)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    displayMessage(title: "Error", message: "Invalid response from server.")
                    return
                }
                
                // Check for HTTP status code
                if httpResponse.statusCode != 200 {
                    let errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                    displayMessage(title: "Error", message: errorMessage)
                    return
                }
                
                let decoder = JSONDecoder()
                let currencyData = try decoder.decode(CurrencyData.self, from: data)
                
                // Extract conversion rates from the response
                if let exchangeRate = currencyData.conversion_rates {
                    rates = exchangeRate
                } else {
                    displayMessage(title: "Error", message: "Conversion rates not found.")
                    return
                }
              
                // Filter rates for the selected default currency
                let filteredRates = rates.filter({ (currency: (key: String, value: Double)) -> Bool in
                    return (currency.key.lowercased().contains(defaultCurrency.lowercased() ?? "AUD"))})
                
                // Get the conversion rate
                self.conversionRate = filteredRates.first?.value
                
                // Calculate and display the converted amount
                calculateConvertedAmount(amount: amount)
                navigationController?.popViewController(animated: true)
                
            } catch let error {
                // Handle any errors occurred during the API call
                print("Error: \(error)")
                displayMessage(title: "Error", message: "An error occurred while fetching the conversion rate. Please check your network connection.")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setFromButton()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Configure convert from text field
        convertFromTextField.rightView = convertFromButton
        convertFromTextField.rightViewMode = .always
        
        ///online reference: https://stackoverflow.com/questions/26076054/changing-placeholder-text-color-with-swift
        // Set placeholder text if convert from text field is empty
        convertFromTextField.attributedPlaceholder = NSAttributedString(
            string: "00.00",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        convertFromTextField.backgroundColor = UIColor(named: "TextFieldWhiteColor")
        convertFromTextField.textColor = .black
        
        ///online reference: https://stackoverflow.com/questions/49044028/how-to-enable-only-numeric-digit-keyboard-ios-swift
        convertFromTextField.keyboardType = .decimalPad
        convertFromTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load the saved currency setting
        let setting = databaseController?.loadSettings().first
        if let savedCurrency = setting?.currency {
            defaultCurrency = savedCurrency
        }
        
        // Highlight the default currency in the menu
        for item in convertFromButton.menu?.children ?? [] {
            if let action = item as? UIAction, action.title == defaultCurrency {
                // If the title matches the current currency, set its state to .on
                action.state = .on
            }
        }
    }
    
    /// Calculate converted amount
    func calculateConvertedAmount(amount: String){
        let result = (Double(amount) ?? 0) * (self.conversionRate ?? 1.0)
        delegate?.currencyResult(result)
    }
    
    /// online references: https://www.youtube.com/watch?v=4yZR6AC1PIU
    /// Sets up the pop-up button menu for selecting the currency
    func setFromButton() {
        // Pop-up button
        let optionClosure = {(action: UIAction) in
                    print(action.title)
                }

        convertFromButton.menu = UIMenu(children: [
            UIAction(title: "AUD", handler: optionClosure),
            UIAction(title: "NZD", handler: optionClosure),
            UIAction(title: "USD", handler: optionClosure),
            UIAction(title: "EUR", handler: optionClosure),
            UIAction(title: "GBP", handler: optionClosure),
            UIAction(title: "CNY", handler: optionClosure),
            UIAction(title: "KRW", handler: optionClosure),
            UIAction(title: "JPY", handler: optionClosure),
            UIAction(title: "MYR", handler: optionClosure),
            UIAction(title: "SGD", handler: optionClosure)
        ])

        convertFromButton.showsMenuAsPrimaryAction = true
        convertFromButton.changesSelectionAsPrimaryAction = true
    }
    
    /// Dismiss keyboard when return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
     */
    

}
