//
//  PaymentItemTableViewCell.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/04.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PaymentItemTableViewCell: UITableViewCell {
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bind(_ viewModel: PaymentItemTableViewCellViewModel) {
        viewModel.categoryText
            .bind(to: categoryLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.itemNameText
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.priceText
            .bind(to: priceLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.priceTextColor
            .bind { [weak self] in
                self?.priceLabel.textColor = $0
            }
            .disposed(by: disposeBag)
        
        viewModel.isHiddenBorder
            .bind(to: borderView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}
