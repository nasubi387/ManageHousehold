//
//  GraphXAxisCell.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/15.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit

class GraphXAxisCell: UICollectionViewCell {
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(_ value: String) {
        valueLabel.text = value
    }
}
