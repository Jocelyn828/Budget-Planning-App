//
//  CoreDataController.swift
//  JOCELYNTANLIANSZE-A4-FinalApplication
//
//  Created by Lian Sze Jocelyn Tan on 26/04/2024.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var dailyTransactionsFetchedResultsController: NSFetchedResultsController<Transaction>?
    var allTransactionsFetchedResultsController: NSFetchedResultsController<Transaction>?
    var monthlyTransactionsFetchedResultsController: NSFetchedResultsController<Transaction>?
    var allRemindersFetchedResultsController: NSFetchedResultsController<Reminder>?
    
    var currentDate: Date?
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "A4-DataModel")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                print("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
    }
    
    /// Saves changes to Core Data
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                print("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    func deleteTransaction(transaction: Transaction) {
        persistentContainer.viewContext.delete(transaction)
    }
    
    func deleteReminder(reminder: Reminder) {
        persistentContainer.viewContext.delete(reminder)
    }
    
    /// Fetch daily transaction records
    func fetchDailyTransactions() -> [Transaction] {
        // Create a calendar instance
        let calendar = Calendar.current
        
        // Get the start and end of today
        let startDate = calendar.startOfDay(for: currentDate!)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        // Create a predicate to filter records for current date
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", argumentArray: [startDate, endDate]);

        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = predicate
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [dateSortDescriptor]
        
        // Initialise Fetched Results Controller
        dailyTransactionsFetchedResultsController = NSFetchedResultsController<Transaction>(fetchRequest: request,managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Set this class to be the results delegate
        dailyTransactionsFetchedResultsController?.delegate = self
        
        do {
            try dailyTransactionsFetchedResultsController?.performFetch()
        } catch {
            print("Fetch Request Failed: \(error)")
        }
            
        if let transactions = dailyTransactionsFetchedResultsController?.fetchedObjects {
            return transactions
        }
        return [Transaction]()
    }
    
    /// Fetch monthly transaction records
    func fetchMonthlyTransactions() -> [Transaction] {
        // Create a calendar instance
        let calendar = Calendar.current
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate!))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        // Create a predicate to filter records for current date
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [startOfMonth, endOfMonth]);

        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = predicate
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [dateSortDescriptor]
        
        // Initialise Fetched Results Controller
        monthlyTransactionsFetchedResultsController = NSFetchedResultsController<Transaction>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Set this class to be the results delegate
        monthlyTransactionsFetchedResultsController?.delegate = self
        
        do {
            try monthlyTransactionsFetchedResultsController?.performFetch()
        } catch {
            print("Fetch Request Failed: \(error)")
        }
            
        if let transactions = monthlyTransactionsFetchedResultsController?.fetchedObjects {
            return transactions
        }
        return [Transaction]()
    }
    
    /// Fetch all reminders
    func fetchAllReminders() -> [Reminder] {
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [dateSortDescriptor]
        
        // Initialise Fetched Results Controller
        allRemindersFetchedResultsController = NSFetchedResultsController<Reminder>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Set this class to be the results delegate
        allRemindersFetchedResultsController?.delegate = self
        
        do {
            try allRemindersFetchedResultsController?.performFetch()
        } catch {
            print("Fetch Request Failed: \(error)")
            // Display error message if error occurs
            displayMessage(title: "Error",message: "Failed to retrieve reminder records. Please try again later.")
        }
            
        if let reminders = allRemindersFetchedResultsController?.fetchedObjects {
            return reminders
        }
        return [Reminder]()
    }
    
    /// Fetch all transaction records
    func fetchAllTransactions() -> [Transaction] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [dateSortDescriptor]
        
        // Initialise Fetched Results Controller
        allTransactionsFetchedResultsController = NSFetchedResultsController<Transaction>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Set this class to be the results delegate
        allTransactionsFetchedResultsController?.delegate = self
        
        do {
            try allTransactionsFetchedResultsController?.performFetch()
        } catch {
            print("Fetch Request Failed: \(error)")
            // Display error message if error occurs
            displayMessage(title: "Error",message: "Failed to retrieve transaction records. Please try again later.")
        }
            
        if let transactions = allTransactionsFetchedResultsController?.fetchedObjects {
            return transactions
        }
        return [Transaction]()
    }
    
    /// Add transaction into Core Data
    func addTransaction(amount: Double?, category: String?, notes: String?, date: Date?) -> Transaction {
        let transaction = NSEntityDescription.insertNewObject(forEntityName: "Transaction", into: persistentContainer.viewContext) as! Transaction
        transaction.amount = amount!
        transaction.category = category
        transaction.notes = notes
        transaction.date = date
        return transaction
    }
    
    /// Add reminder into Core Data
    func addReminder(id: String?, content: String?, shouldRepeat: String, date: Date?) -> Reminder {
        let reminder = NSEntityDescription.insertNewObject(forEntityName: "Reminder", into: persistentContainer.viewContext) as! Reminder
        reminder.id = id
        reminder.content = content
        reminder.shouldRepeat = shouldRepeat
        reminder.date = date
        return reminder
    }
    
    /// Retrieve settings from Core Data
    func loadSettings() -> [Settings] {
        let request: NSFetchRequest<Settings> = Settings.fetchRequest()
        var setting = [Settings]()
        do {
            try setting = persistentContainer.viewContext.fetch(request)
            if (setting.first != nil) {
                return setting
            } else {
                let settings = NSEntityDescription.insertNewObject(forEntityName: "Settings", into: persistentContainer.viewContext) as! Settings
            }
        } catch {
            print("Fetch Request failed with error: \(error)")
            // Display error message if error occurs
            displayMessage(title: "Error",message: "Failed to retrieve preference settings. Please try again later.")
        }
        return [Settings]()
    }
    
    /// Save theme preference into Core Data
    func saveTheme(index: Int32) {
        let request: NSFetchRequest<Settings> = Settings.fetchRequest()
        var setting = [Settings]()
        do {
            try setting = persistentContainer.viewContext.fetch(request)
            setting.first?.theme = index
        } catch {
            print("Fetch Request failed with error: \(error)")
            // Display error message if error occurs
            displayMessage(title: "Error",message: "Failed to save theme setting. Please try again later.")
        }
    }
    
    /// Save currency preference into Core Data
    func saveCurrency(currency: String) {
        let request: NSFetchRequest<Settings> = Settings.fetchRequest()
        var setting = [Settings]()
        do {
            try setting = persistentContainer.viewContext.fetch(request)
            setting.first?.currency = currency
        } catch {
            print("Fetch Request failed with error: \(error)")
            // Display error message if error occurs
            displayMessage(title: "Error",message: "Failed to save currency setting. Please try again later.")
        }
    }
    
    // MARK: - Fetched Results Controller Protocol methods
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if controller == dailyTransactionsFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .dailyTrans {
                    listener.onDailyTransactionsChange(change: .update,
                                               transactions: fetchDailyTransactions())
                }
            }
        } else if controller == allTransactionsFetchedResultsController{
            listeners.invoke() { listener in
                if listener.listenerType == .stats {
                    listener.onStatisticsChange(change: .update,
                                                transactions: fetchAllTransactions())
                }
            }
        } else if controller == monthlyTransactionsFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .monthlyTrans {
                    listener.onMonthlyTransactionsChange(change: .update, transactions: fetchMonthlyTransactions())
                }
            }
        } else if controller == allRemindersFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .reminder {
                    listener.onRemindersChange(change: .update, reminders: fetchAllReminders())
                }
            }
        }
    }
    
    func addListener(listener: any DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .dailyTrans {
            listener.onDailyTransactionsChange(change: .update, transactions: fetchDailyTransactions())
        }

        if listener.listenerType == .stats {
            listener.onStatisticsChange(change: .update, transactions: fetchAllTransactions())
        }
        
        if listener.listenerType == .monthlyTrans {
            listener.onMonthlyTransactionsChange(change: .update, transactions: fetchMonthlyTransactions())
        }
        
        if listener.listenerType == .reminder {
            listener.onRemindersChange(change: .update, reminders: fetchAllReminders())
        }
    }
    
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    /// online reference: https://stackoverflow.com/questions/30052299/show-uialertcontroller-outside-of-viewcontroller
    func displayMessage(title: String, message: String) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            rootVC.present(alertController, animated: true, completion: nil)
        }
    }
    
}
