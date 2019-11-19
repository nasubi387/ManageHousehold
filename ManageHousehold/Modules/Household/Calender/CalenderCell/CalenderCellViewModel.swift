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
    struct Dependency {
        
    }
    
    struct Input {
        
    }
    
    struct Output {
        let dayText: Observable<String>
        let incomeText: Observable<String>
        let expenseText: Observable<String>
        let isHiddenIncome: Observable<Bool>
        let isHiddenExpense: Observable<Bool>
        let backgroundColor: Observable<UIColor>
        let isDummy: Observable<Bool>
    }
    
    private let dependency: Dependency
    let input: Input
    let output: Output
    
    private let disposeBag = DisposeBag()
    
    private let _payment: BehaviorRelay<Payment>
    private let _isDummy: BehaviorRelay<Bool>
    
    var currentStatus: Payment {
        return _payment.value
    }
    
    init(input: Input, dependency: Dependency, payment: Payment, isDummy: Bool = false) {
        self.input = input
        self.dependency = dependency
        
        _payment = BehaviorRelay<Payment>(value: payment)
        _isDummy = BehaviorRelay<Bool>(value: isDummy)
        
        let dayText = _payment.map { payment -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            formatter.locale = Locale(identifier: "ja_JP")
            return formatter.string(from: payment.date)
        }
        
        let incomeText = _payment.map { "\($0.income)" }
        
        let expenseText = _payment.map { "\($0.expense)" }
        
        let isHiddenIncome = _payment.map { $0.income == 0 }
        
        let isHiddenExpense = _payment.map { $0.expense == 0 }
        
        let backgroundColor = _isDummy.map { isDummy -> UIColor in
            guard UITraitCollection.isDarkMode == true else {
                return isDummy ? #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) : UIColor.clear
            }
            return isDummy ? #colorLiteral(red: 0.1144889817, green: 0.1227323487, blue: 0.1346289814, alpha: 1) : UIColor.clear
        }
        
        let isDummy = Observable.just(isDummy)
        
        output = Output(dayText: dayText,
                        incomeText: incomeText,
                        expenseText: expenseText,
                        isHiddenIncome: isHiddenIncome,
                        isHiddenExpense: isHiddenExpense,
                        backgroundColor: backgroundColor,
                        isDummy: isDummy)
    }
}
