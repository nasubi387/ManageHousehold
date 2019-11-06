//
//  WeekdayCell.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/05.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit

class WeekdayCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(with weekDay: Weekday) {
        nameLabel.textColor = weekDay.textColor
        nameLabel.text = weekDay.name
    }
}
