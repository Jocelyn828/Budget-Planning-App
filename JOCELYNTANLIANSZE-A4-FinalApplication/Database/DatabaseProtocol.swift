//
//  DatabaseProtocol.swift
//  JOCELYNTANLIANSZE-A4-FinalApplication
//
//  Created by Lian Sze Jocelyn Tan on 26/04/2024.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case dailyTrans
    case monthlyTrans
    case stats
    case reminder
}

protocol DatabaseListener: AnyObject {
    var listenerType : ListenerType {get set}
    func onDailyTransactionsChange(change: DatabaseChange, transactions: [Transaction])
    func onMonthlyTransactionsChange(change: DatabaseChange, transactions: [Transaction])
    func onStatisticsChange(change: DatabaseChange, transactions: [Transaction])
    func onRemindersChange(change: DatabaseChange, reminders: [Reminder])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addTransaction(amount: Double?, category: String?, notes: String?, date: Date?) -> Transaction
    func deleteTransaction(transaction: Transaction)
    
    func addReminder(id: String?, content: String?, shouldRepeat: String, date: Date?) -> Reminder
    func deleteReminder(reminder: Reminder)
    
    var currentDate: Date? { get set }

    func loadSettings() -> [Settings]
    func saveTheme(index: Int32)
    func saveCurrency(currency: String)
}
