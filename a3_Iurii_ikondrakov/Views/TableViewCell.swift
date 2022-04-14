//
//  TableViewCell.swift
//  a3_Iurii_ikondrakov
//
//  Created by Iurii Kondrakov on 2022-03-11.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var windLabel:     UILabel!
    @IBOutlet weak var citytimeLabel: UILabel!
    @IBOutlet weak var tempLabel:     UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
