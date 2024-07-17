//
//  TransactionsRecordsViewController.swift
//  JOCELYNTANLIANSZE-A4-FinalApplication
//
//  Created by Lian Sze Jocelyn Tan on 19/04/2024.
//

import UIKit

class TransactionsRecordsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatabaseListener {

    // MARK: - Properties

    var currentViewedDate = Date()
    let dateFormatter = DateFormatter()
    var currency = "AUD"
    var categoriesCost: [String:Double] = [:]
    let CATEGORIES = ["Groceries","Transport","Entertainment","Meals","Shopping","Household","Income","Salary"]
    let EXPENSE_CAT = ["Groceries","Transport","Entertainment","Meals","Shopping","Household"]
    let INCOME_CAT = ["Income","Salary"]
    var totalExpense = 0.0
    var totalIncome = 0.0
    
    let SECTION_TRANS = 0
    let CELL_TRANS = "transactionCell"
    
    // MARK: - Outlets
    
    @IBOutlet weak var addTransactionButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var totalExpenseLabel: UILabel!
    @IBOutlet weak var totalIncomeLabel: UILabel!
    @IBOutlet weak var summaryView: UIView!
    
    // timeSegmentStatus = 0 for daily transaction records
    // timeSegmentStatus = 1 for monthly transaction records
    var timeSegmentStatus = 0
    var dailyTransactions: [Transaction] = []
    var monthlyTransactions: [Transaction] = []
    
    var listenerType: ListenerType = .dailyTrans
    weak var databaseController: DatabaseProtocol?
    
    // MARK: - IBActions

    /// Adjust the current date backward by a day or a month depending on the time segment status
    @IBAction func backwardButton(_ sender: Any) {
        if timeSegmentStatus == 0 {
            // One day backward
            currentViewedDate = Calendar.current.date(byAdding: .day, value: -1, to: currentViewedDate)!
            dateLabel.text = dateFormatter.string(from: currentViewedDate)
        } else {
            // One month backward
            currentViewedDate = Calendar.current.date(byAdding: .month, value: -1, to: currentViewedDate)!
            let monthFormatter = DateFormatter()
            
            // Format the date to show month initial and year
            monthFormatter.dateFormat = "MMM yyyy"
            dateLabel.text = monthFormatter.string(from: currentViewedDate)
        }
        
        databaseController?.currentDate = currentViewedDate
        databaseController?.addListener(listener: self)
    }
    
    /// Adjust the current date forward by a day or a month depending on the time segment status
    @IBAction func forwardButton(_ sender: Any) {
        let now = Date()
        
        if timeSegmentStatus == 0 {
            let day: Set<Calendar.Component> = [.day]
            // calculate difference in days
            let days = Calendar.current.dateComponents(day,from: currentViewedDate, to: now)
            
            // Prevent going future date
            if days.day == 0 {return}
            
            // One day forward
            currentViewedDate = Calendar.current.date(byAdding: .day, value: 1, to: currentViewedDate)!
            dateLabel.text = dateFormatter.string(from: currentViewedDate)
        } else {
            
            let month: Set<Calendar.Component> = [.month]
            let months = Calendar.current.dateComponents(month,from: currentViewedDate, to: now)
            
            // Avoid going to future date
            if months.month == 0 {return}
            
            // One month forward
            currentViewedDate = Calendar.current.date(byAdding: .month, value: 1, to: currentViewedDate)!
            let monthFormatter = DateFormatter()
            
            // Format the date to show month initial and year
            monthFormatter.dateFormat = "MMM yyyy"
            dateLabel.text = monthFormatter.string(from: currentViewedDate)
        }
        
        databaseController?.currentDate = currentViewedDate
        databaseController?.addListener(listener: self)
    }
    
    /// Update the status, refresh the listener and table view based on the selected time segment
    @IBAction func timeSegmentValueChanged(_ sender: Any) {
        switch timeSegmentedControl.selectedSegmentIndex {
        case 0:
            timeSegmentStatus = 0
            dateLabel.text = dateFormatter.string(from: currentViewedDate)
            databaseController?.removeListener(listener: self)
            listenerType = .dailyTrans
            databaseController?.addListener(listener: self)
            
        case 1:
            timeSegmentStatus = 1
            let monthFormatter = DateFormatter()
            
            // Format the date to show month initial and year
            monthFormatter.dateFormat = "MMM yyyy"
            dateLabel.text = monthFormatter.string(from: currentViewedDate)
            
            databaseController?.removeListener(listener: self)
            listenerType = .monthlyTrans
            databaseController?.addListener(listener: self)
            
        default:
            timeSegmentStatus = 0
        }
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        // Initialize the database controller and set the current date
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        databaseController?.currentDate = currentViewedDate
        
        // Apply initial settings theme and currency if no preferences set before
        if databaseController?.loadSettings().first == nil {
            let userTheme = traitCollection.userInterfaceStyle
            switch userTheme {
            case .light:
                databaseController?.saveTheme(index: Int32(0))
            case .dark:
                databaseController?.saveTheme(index: Int32(1))
            case .unspecified:
                databaseController?.saveTheme(index: Int32(0))
            @unknown default:
                databaseController?.saveTheme(index: Int32(0))
            }
            databaseController?.saveCurrency(currency: currency)
        }
        
        // Update date label to display currentViewedDate
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateLabel.text = dateFormatter.string(from: currentViewedDate)
        
        summaryView.layer.cornerRadius = 20
        
        addTransactionButton.backgroundColor = UIColor(named:"AddButtonColor")
        addTransactionButton.layer.cornerRadius = 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    /// Calculate the total cost for the given transactions and update the labels
    func calculateCost(transactions: [Transaction]) {
        categoriesCost = [:]
        totalExpense = 0
        totalIncome = 0
        
        for category in CATEGORIES {
            var cost = 0.0
            for transaction in transactions {
                if transaction.category == category {
                    cost += transaction.amount
                }
            }
            categoriesCost[category] = cost
            
            if EXPENSE_CAT.contains(category) {
                totalExpense += cost
            } else if INCOME_CAT.contains(category) {
                totalIncome += cost
            }
            
        }
        
        totalIncomeLabel.text = String(format: "%.2f", totalIncome)
        totalIncomeLabel.textColor = UIColor(named:"GreenColor")
        
        totalExpenseLabel.text = String(format: "%.2f", totalExpense)
        totalExpenseLabel.textColor = UIColor(named:"RedColor")
    }

    // MARK: - DatabaseListener Methods

    func onDailyTransactionsChange(change: DatabaseChange, transactions: [Transaction]) {
        dailyTransactions = transactions
        calculateCost(transactions: dailyTransactions)
        tableView.reloadData()
    }
    
    func onMonthlyTransactionsChange(change: DatabaseChange, transactions: [Transaction]) {
        monthlyTransactions = transactions
        calculateCost(transactions: monthlyTransactions)
        
        tableView.reloadData()
    }

    func onStatisticsChange(change: DatabaseChange, transactions: [Transaction]) {
        //do nothing
    }
    
    func onRemindersChange(change: DatabaseChange, reminders: [Reminder]) {
        // do nothing
    }
    
    // MARK: - Table view data source
    
    /// Setup the table view with delegate and data source
    func setupTableView() {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.layer.cornerRadius = 10
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if timeSegmentStatus == 0 {
            return dailyTransactions.count
        }
        return categoriesCost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transCell = tableView.dequeueReusableCell(withIdentifier: CELL_TRANS, for: indexPath) as! TransactionTableViewCell
        
        if let currency = databaseController?.loadSettings().first?.currency {
            self.currency = currency
        }
        // Daily page
        if timeSegmentStatus == 0 {
            let transaction = dailyTransactions[indexPath.row]
            
            transCell.categoryLabel.text = transaction.category
            transCell.notesLabel.text = transaction.notes
            if EXPENSE_CAT.contains(transaction.category!) {
                transCell.amountLabel.text = "- " + String(format: "%.2f %@", transaction.amount, self.currency)
            } else {
                transCell.amountLabel.text = "+ " + String(format: "%.2f %@", transaction.amount, self.currency)
            }
        
        // Monthly page
        } else {
            // Retrieve the category and its cost
            let category = CATEGORIES[indexPath.row]
            let amount = categoriesCost[category] ?? 0.00
            
            transCell.categoryLabel.text = category
            transCell.amountLabel.text = String(format: "%.2f %@", amount, self.currency)
            transCell.notesLabel.text = ""
        }
        
        // Display icon based on category
        let categoryText =  transCell.categoryLabel.text?.lowercased()
        if categoryText == "groceries" {
            transCell.categoryImage.image = UIImage(systemName: "cart")
        } else if categoryText == "entertainment" {
            transCell.categoryImage.image = UIImage(systemName: "movieclapper")
        } else if categoryText == "meals" {
            transCell.categoryImage.image = UIImage(systemName: "takeoutbag.and.cup.and.straw")
        } else if categoryText == "transport" {
            transCell.categoryImage.image = UIImage(systemName: "car")
        } else if categoryText == "household" {
            transCell.categoryImage.image = UIImage(systemName: "house")
        } else if categoryText == "shopping" {
            transCell.categoryImage.image = UIImage(systemName: "bag")
        } else if categoryText == "income" {
            transCell.categoryImage.image = UIImage(systemName: "dollarsign.square")
        } else if categoryText == "salary" {
            transCell.categoryImage.image = UIImage(systemName: "briefcase")
        }
        transCell.categoryImage.layer.cornerRadius = 9
        
        // Expense - red color
        // Income - green color
        if categoryText != "income", categoryText != "salary" {
            transCell.amountLabel.textColor = UIColor(named:"RedColor")
            transCell.categoryImage.backgroundColor = UIColor(named: "ImageRedColor")
        } else {
            transCell.amountLabel.textColor = UIColor(named:"GreenColor")
            transCell.categoryImage.backgroundColor = UIColor(named: "GreenColor")
        }
        
        /// online reference: https://stackoverflow.com/questions/190908/how-can-i-disable-the-uitableview-selection
        transCell.selectionStyle = .none
    
        return transCell

    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Only daily transaction records are editable
        if timeSegmentStatus == 0 {
            return true
        }
        return false
    }
    

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            databaseController?.deleteTransaction(transaction: dailyTransactions[indexPath.row])
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_TRANS {
            return "TRANSACTIONS"
        }
        return ""
    }

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

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addTransSegue" {
            let _ = segue.destination as! AddTransactionViewController
            
        } else if segue.identifier == "dailyToStatsSegue" {
            let destination = segue.destination as! StatisticsViewController
            destination.currency = currency
        }
    }


}
