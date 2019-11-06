//
//  LineGraphViewModel.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/14.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxSwift
import RxCocoa

class LineGraphViewModel {
    private let disposeBag = DisposeBag()
    
    private let _paymentService: BehaviorRelay<PaymentService>
    var payments: Observable<[Payment]>!
    
    struct State {
        let paymentService: PaymentService
        let payments: [Payment]
    }
    var currentStatus: State {
        return State(paymentService: _paymentService.value,
                     payments: _paymentService.value.currentState.payments)
    }
    
    init(paymentService: BehaviorRelay<PaymentService>) {
        _paymentService = paymentService
        payments = _paymentService
            .flatMap { $0.payments }
            .map { [weak self] in
                return $0.filter { [weak self] in
                    let year = self?.currentStatus.paymentService.currentState.year
                    let month = self?.currentStatus.paymentService.currentState.month
                    return Calendar.current.component(.year, from: $0.date) == year
                        && Calendar.current.component(.month, from: $0.date) == month
                }
            }
    }
}
