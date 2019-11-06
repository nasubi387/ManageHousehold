//
//  CalenderCellViewModel.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/02.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class CalenderCellViewModel {
    private let disposeBag = DisposeBag()
    
    private let _payment: BehaviorRelay<Payment>
    private let _isDummy: BehaviorRelay<Bool>
    
    var dayText: Observable<String>
    var incomeText: Observable<String>
    var expenseText: Observable<String>
    var isHiddenIncome: Observable<Bool>
    var isHiddenExpense: Observable<Bool>
    var backgroundColor: Observable<UIColor>
    var isDummy: Observable<Bool> {
        return _isDummy.asObservable()
    }
    
    var currentStatus: Payment {
        return _payment.value
    }
    
    init(payment: Payment, isDummy: Bool = false) {
        _payment = BehaviorRelay<Payment>(value: payment)
        _isDummy = BehaviorRelay<Bool>(value: isDummy)
        
        dayText = _payment.map {
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            formatter.locale = Locale(identifier: "ja_JP")
            return formatter.string(from: $0.date)
        }
        incomeText = _payment.map { "\($0.income)" }
        expenseText = _payment.map { "\($0.expense)" }
        isHiddenIncome = _payment.map { $0.income == 0 }
        isHiddenExpense = _payment.map { $0.expense == 0 }
        backgroundColor = _isDummy.map {
            guard UITraitCollection.isDarkMode == true else {
                return $0 ? #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) : UIColor.clear
            }
            return $0 ? #colorLiteral(red: 0.1144889817, green: 0.1227323487, blue: 0.1346289814, alpha: 1) : UIColor.clear
        }
    }
}
