//
//  CalenderCell.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/02.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CalenderCell: UICollectionViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    
    var viewModel: CalenderCellViewModel!
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func bind(_ viewModel: CalenderCellViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.dayText
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.expenseText
            .bind(to: expenseLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.incomeText
            .bind(to: incomeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.isHiddenExpense
            .bind(to: expenseLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.output.isHiddenIncome
            .bind(to: incomeLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.output.backgroundColor
            .bind(to: self.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
}
