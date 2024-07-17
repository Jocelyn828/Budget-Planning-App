//
//  RemindersTableViewController.swift
//  JOCELYNTANLIANSZE-A4-FinalApplication
//
//  Created by Lian Sze Jocelyn Tan on 17/05/2024.
//

import UIKit
import UserNotifications

class RemindersTableViewController: UITableViewController, setReminderDelegate, DatabaseListener {
    
    // MARK: - Properties
    
    var allReminders: [Reminder] = []
    
    let dateFormatter = DateFormatter()
    let calendar = Calendar.current
    let center = UNUserNotificationCenter.current()
    var deliveredNotifications: [UNNotification] = []
    
    var listenerType: ListenerType = .reminder
    weak var databaseController: DatabaseProtocol?
    
    lazy var appDelegate = {
            guard let appDelegate =  UIApplication.shared.delegate as? AppDelegate else {
                fatalError("No AppDelegate")
            }
            return appDelegate
        }()

    // MARK: - Outlets
    
    @IBOutlet weak var addReminderButton: UIButton!
    
    // MARK: - Actions
    
    /// Called when the add reminder button is tapped
    @IBAction func addReminderAction(_ sender: Any) {
        guard appDelegate.notificationsEnabled else {
            print("Notifications not enabled")
            // Display error message if the notification is not permitted
            displayMessage(title: "Permission Denied",message: "Notifications are not enabled. Please enable notifications and restart the app.")
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reminders"
        databaseController = appDelegate.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    /// Sets up a reminder
    func reminderSetUp(id: String, reminder: String, shouldRepeat: String, date: Date) {
        let currentTime = Date()
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = reminder
        content.sound = .default
        
        // Define the target date for the reminder
        let targetDate = date
        
        // Initialize a flag to determine if the reminder should repeat
        var repeatStatus = false
        
        // Check if the reminder should repeat
        if shouldRepeat != "None" {
            repeatStatus = true
        }
        
        // If the reminder should repeat
        if repeatStatus {
            
            // Extract hour and minute components from the target dat
            dateComponents.hour = calendar.component(.hour, from: targetDate)
            dateComponents.minute = calendar.component(.minute, from: targetDate)
            
            // If the reminder repeats weekly
            if shouldRepeat == "Weekly" {
                // Extract weekday component from the target date
                dateComponents.weekday = calendar.component(.weekday, from: targetDate)
                
            // If the reminder repeats monthly
            } else if shouldRepeat == "Monthly" {
                // Extract day component from the target date
                dateComponents.day = calendar.component(.day, from: targetDate)
            }
        
        // If the reminder does not repeat
        } else {
            // Extract all necessary date components from the target date
            dateComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: targetDate)
        }
        
        // Create a notification trigger based on the configured date components and repeat status
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeatStatus)

        // Create a notification request with the provided ID, content, and trigger
        let request = UNNotificationRequest(identifier: id , content: content, trigger: trigger)
        
        // Add the notification request to the notification center
        self.center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
            }
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
        // do nothing
    }
    
    func onRemindersChange(change: DatabaseChange, reminders: [Reminder]) {
        allReminders = reminders
        
        // Ensure table view reload happens after notifications are fetched
        Task {
            self.deliveredNotifications = await self.center.deliveredNotifications()
            self.tableView.reloadData()
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allReminders.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath)
        let reminder = allReminders[indexPath.row]
        
        // Set the text of the cell's main label to the reminder content
        cell.textLabel?.text = reminder.content
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        // Set the detail text label of the cell based on the reminder's repeat status
        let targetDate = dateFormatter.string(from: reminder.date!)
        var repeatDisplay = reminder.shouldRepeat!
        
        // if no repeat action is needed
        if repeatDisplay == "None" {
            cell.detailTextLabel?.text = targetDate
        } else {
            cell.detailTextLabel?.text = "\(targetDate) Repeat \(repeatDisplay)"
        }
        
        cell.detailTextLabel?.textColor = .label
        
        // Delivered notification - red color
        for notification in self.deliveredNotifications {
            if notification.request.identifier == reminder.id {
                cell.detailTextLabel?.textColor = UIColor(named:"RedColor")
            }
        }
        
        /// online reference: https://stackoverflow.com/questions/190908/how-can-i-disable-the-uitableview-selection
        cell.selectionStyle = .none

        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let reminder = allReminders[indexPath.row]
            databaseController?.deleteReminder(reminder:reminder)
            let currentDate = Date()
            
            var deleteSuccess = false
            
            /// remove notifications: https://stackoverflow.com/questions/31951142/how-to-cancel-a-localnotification-with-the-press-of-a-button-in-swift
            /// get all delivered/pending notificaitions https://stackoverflow.com/questions/40270598/ios-10-how-to-view-a-list-of-pending-notifications-using-unusernotificationcente
            // Remove the associated notification
            self.center.getDeliveredNotifications(completionHandler: { notifications in
                for notification in notifications {
                    if reminder.id == notification.request.identifier {
                        self.center.removeDeliveredNotifications(withIdentifiers: [reminder.id!])
                        print("remove delivered notification")
                        deleteSuccess = true
                        break
                    }
                }
            })
            
            // If the notification was not delivered, remove the pending notification
            if deleteSuccess == false {
                self.center.removePendingNotificationRequests(withIdentifiers:  [reminder.id!])
                print("remove pending notification")
            }
        }
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
        if segue.identifier == "addReminderSegue"{
            let destination = segue.destination as! AddReminderViewController
            destination.delegate = self
        }
    }
    
}
