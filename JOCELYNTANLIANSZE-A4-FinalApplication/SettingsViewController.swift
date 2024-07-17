//
//  SettingsViewController.swift
//  JOCELYNTANLIANSZE-A4-FinalApplication
//
//  Created by Lian Sze Jocelyn Tan on 19/04/2024.
//

import UIKit
import SwiftUI

class SettingsViewController: UIViewController {
    
    // MARK: - Properties

    weak var databaseController: DatabaseProtocol?
    var settings: Settings?
    var currency = "AUD"
    
    // MARK: - Outlets

    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var themeSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Load user preferences from the database
        let preference = databaseController?.loadSettings().first
        
        // Update theme and currency based on the loaded preferences
        themeSegmentedControl.selectedSegmentIndex = Int(preference!.theme)
        currency = (preference?.currency)!
        themeSegmentValueChanged(self)
        
        setPopUpButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update the state of the currency button menu items
        for item in currencyButton.menu?.children ?? [] {
            if let action = item as? UIAction, action.title == currency {
                
                // If the title matches the current currency, set its state to .on
                action.state = .on
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Actions

    /// Called when the save button is tapped to save the settings
    @IBAction func saveSettings(_ sender: Any) {
        // Get the selected currency
        currency = (currencyButton.titleLabel?.text)!
        
        // Save theme and currency settings to the database
        databaseController?.saveTheme(index: Int32(themeSegmentedControl.selectedSegmentIndex))
        databaseController?.saveCurrency(currency: currency)
        
        // Update the interface style based on the selected theme
        switch themeSegmentedControl.selectedSegmentIndex {
        case 0:
            navigationController?.overrideUserInterfaceStyle = .light
        case 1:
            navigationController?.overrideUserInterfaceStyle = .dark
        default:
            navigationController?.overrideUserInterfaceStyle = .unspecified
        }
        navigationController?.popViewController(animated: true)
    }
    
    /// Called when the theme segmented control value is changed.
    @IBAction func themeSegmentValueChanged(_ sender: Any) {
        // Update the interface style based on the selected theme
        switch themeSegmentedControl.selectedSegmentIndex {
        case 0:
            self.overrideUserInterfaceStyle = .light
        case 1:
            self.overrideUserInterfaceStyle = .dark
        default:
            self.overrideUserInterfaceStyle = .unspecified
        }

    }
    
    /// online references: https://www.youtube.com/watch?v=4yZR6AC1PIU
    /// Sets up the pop-up button menu for selecting the currency
    func setPopUpButton() {
        // Pop-up button
        let optionClosure = {(action: UIAction) in
            print(action.title)
        }
        
        currencyButton.menu = UIMenu(children: [
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
        
        currencyButton.showsMenuAsPrimaryAction = true
        currencyButton.changesSelectionAsPrimaryAction = true
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
