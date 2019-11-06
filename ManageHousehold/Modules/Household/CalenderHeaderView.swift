//
//  CalenderHeaderView.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/26.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit

class CalenderHeaderView: UIView, NibLoadable {
    
    @IBOutlet weak var CalenderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadNib()
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
        setupView()
    }
    
    private func setupView() {
        
    }
}

extension CalenderHeaderView {
    func bind() {
        
    }
}
