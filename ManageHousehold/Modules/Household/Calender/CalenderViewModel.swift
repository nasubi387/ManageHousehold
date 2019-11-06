//
//  CalenderViewModel.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/20.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxSwift
import RxCocoa

class CalenderViewModel {
    private let repository = PaymentRepository()
    private let disposeBag = DisposeBag()
    
    private let _paymentService: BehaviorRelay<PaymentService>
    
    private let _cellModels: BehaviorRelay<[CalenderCellViewModel]>
    
    var cellModels: Observable<[CalenderCellViewModel]> {
        return _cellModels.asObservable()
    }
    
    struct State {
        let cellModels: [CalenderCellViewModel]
        let paymentService: PaymentService
    }
    var currentStatus: State {
        return State(cellModels: _cellModels.value,
                     paymentService: _paymentService.value)
    }
    
    init(paymentService: PaymentService) {
        _paymentService = BehaviorRelay<PaymentService>(value: paymentService)
        _cellModels = BehaviorRelay<[CalenderCellViewModel]>(value: [])
        _paymentService
            .flatMap { $0.payments }
            .map { [weak self] in
                $0.map {[weak self] in
                    let year = Calendar.current.component(.year, from: $0.date)
                    let month = Calendar.current.component(.month, from: $0.date)
                    let isDummy =
                        self?.currentStatus.paymentService.currentState.year != year ||
                        self?.currentStatus.paymentService.currentState.month != month
                    return CalenderCellViewModel(payment: $0, isDummy: isDummy)
                }
            }
            .bind(to: _cellModels)
            .disposed(by: disposeBag)
        
        fetchPayments()
    }
    
    func fetchPayments() {
        _paymentService.value.fetchPayments()
    }
    
    func updatePayment(_ payment: Payment) {
        _paymentService.value.updatePayment(payment)
    }
}
