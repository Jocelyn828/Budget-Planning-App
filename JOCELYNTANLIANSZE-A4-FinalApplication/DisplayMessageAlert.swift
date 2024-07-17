//
//  DisplayMessageAlert.swift
//  JOCELYNTANLIANSZE-A4-FinalApplication
//
//  Created by Lian Sze Jocelyn Tan on 06/06/2024.
//

import Foundation
import UIKit

extension UIViewController {
    /// Display alert message
    func displayMessage(title:String, message:String){
        let alertController = UIAlertController(title:title,message: message,preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController,animated: true,completion: nil)
    }
}
