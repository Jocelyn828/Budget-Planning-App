//
//  StatisticsTableViewController.swift
//  JOCELYNTANLIANSZE-A4-FinalApplication
//
//  Created by Lian Sze Jocelyn Tan on 19/04/2024.
//

import UIKit
import SwiftUI

class StatisticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatabaseListener {
    
    // MARK: - Properties

    var allTransactions: [Transaction] = []
    var categoriesCost: [String:Double] = [:]
    var categories: [String] = []
    var currency: String?
    
    let SECTION_CATEGORY = 0
    let CELL_CATEGORY = "categoryCell"
    let EXPENSE_CAT = ["Groceries","Transport","Entertainment","Meals","Shopping","Household"]
    let INCOME_CAT = ["Income","Salary"]

    var chartController: UIHostingController<ChartUIView>?
    var listenerType: ListenerType = .stats
    weak var databaseController: DatabaseProtocol?

    // MARK: - Outlets
    
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Setup table view
        setupTableView()
        
        // Initial categories are expenses categories
        categories = EXPENSE_CAT
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        // Add chart view
        let controller = UIHostingController(rootView: ChartUIView(categoriesCost: categoriesCost))
        guard let chartView = controller.view else {
            return
        }
        
        view.addSubview(chartView)
        addChild(controller)
        
        // Set constraints for chart view
        chartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            chartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20.0),
            chartView.heightAnchor.constraint(equalToConstant: 180.0),
        ])
        
        // Set constraints for segmented control
        categorySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categorySegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categorySegmentedControl.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 20.0),
        ])
        
        // Set constraints for table view
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
            tableView.topAnchor.constraint(equalTo: categorySegmentedControl.bottomAnchor, constant: 20.0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        chartController = controller
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    /// Called when the transaction type segmented control value is changed
    @IBAction func transactionTypeSegmentValueChanged(_ sender: Any) {
        // Update categories based on segmented control value
        switch categorySegmentedControl.selectedSegmentIndex {
        case 0:
            categories = EXPENSE_CAT
        case 1:
            categories = INCOME_CAT
        default:
            categories = EXPENSE_CAT
        }
        
        // Recalculate costs and update views
        calculateCost()
        tableView.reloadData()
        updateChartView()
    }
    
    /// Update the chart view with new data
    func updateChartView() {
        let updatedController = UIHostingController(rootView: ChartUIView(categoriesCost: categoriesCost))
        guard let updatedChartView = updatedController.view else {
            return
        }
        
        updatedChartView.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove existing chart view
        chartController?.view.removeFromSuperview()
        chartController?.removeFromParent()
        
        // Add updated chart view
        view.addSubview(updatedChartView)
        addChild(updatedController)
        
        NSLayoutConstraint.activate([
            updatedChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            updatedChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            updatedChartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20.0), // Use safe area top anchor
            updatedChartView.heightAnchor.constraint(equalToConstant: 180.0),
        ])
        
        // Set constraints for segmented control
        categorySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categorySegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categorySegmentedControl.topAnchor.constraint(equalTo: updatedChartView.bottomAnchor, constant: 20.0), // Adjust the constant as needed
        ])
        
        // Update chart controller reference
        chartController = updatedController
    }
    
    func setupTableView() {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.layer.cornerRadius = 10
    }
    
    /// Calculate the total cost for all transactions
    func calculateCost() {
        categoriesCost = [:]
        for category in categories {
            var cost = 0.0
            for transaction in allTransactions {
                if transaction.category == category {
                    cost += transaction.amount
                }
            }
            categoriesCost[category] = cost
        }
    }
    
    // MARK: - DatabaseListener Methods
    
    func onDailyTransactionsChange(change: DatabaseChange, transactions: [Transaction]) {
        // do nothing
    }
    
    func onMonthlyTransactionsChange(change: DatabaseChange, transactions: [Transaction]) {
        // do nothing
    }
    
    func onStatisticsChange(change: DatabaseChange, transactions: [Transaction]) {
        allTransactions = transactions
        calculateCost()
    }
    
    func onRemindersChange(change: DatabaseChange, reminders: [Reminder]) {
        //do nothing
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoriesCost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryCell = tableView.dequeueReusableCell(withIdentifier: CELL_CATEGORY, for: indexPath) as! StatisticsTableViewCell
        
        // Sort the dictionary keys
        let sortedCategories = categoriesCost.keys.sorted()
        
        // Get the category and amount for the current row
        let category = sortedCategories[indexPath.row]
        let amount = categoriesCost[category] ?? 0.00
        
        categoryCell.categoryLabel.text = category
        categoryCell.amountLabel.text = String(format: "%.2f %@", amount, currency!)

        /// online reference: https://stackoverflow.com/questions/190908/how-can-i-disable-the-uitableview-selection
        categoryCell.selectionStyle = .none
        
        return categoryCell
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

