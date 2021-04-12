//
//  EventTableViewCell.swift
//  getSocialXcode
//
//  Created by murat on 11.04.2021.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet var eventName: UILabel!
    @IBOutlet var eventDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
