//
//  setReminderDelegate.swift
//  JOCELYNTANLIANSZE-A4-FinalApplication
//
//  Created by Lian Sze Jocelyn Tan on 17/05/2024.
//

import Foundation

protocol setReminderDelegate: AnyObject{
    func reminderSetUp(id: String, reminder: String, shouldRepeat: String, date: Date)
}
