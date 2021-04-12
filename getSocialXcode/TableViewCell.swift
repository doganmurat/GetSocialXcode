//
//  TableViewCell.swift
//  getSocialXcode
//
//  Created by murat on 11.04.2021.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventVenueName: UILabel!
    @IBOutlet weak var eventVenueCity: UILabel!
    @IBOutlet weak var eventPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
