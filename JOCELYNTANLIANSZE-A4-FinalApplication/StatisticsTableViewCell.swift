//
//  StatisticsTableViewCell.swift
//  JOCELYNTANLIANSZE-A4-FinalApplication
//
//  Created by Lian Sze Jocelyn Tan on 08/05/2024.
//

import UIKit

class StatisticsTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
