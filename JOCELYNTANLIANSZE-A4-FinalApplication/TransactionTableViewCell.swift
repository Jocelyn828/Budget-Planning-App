//
//  TransactionTableViewCell.swift
//  JOCELYNTANLIANSZE-A4-FinalApplication
//
//  Created by Lian Sze Jocelyn Tan on 26/04/2024.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    // MARK: - Outlets

    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
