//
//  PaymentItemsViewModel.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/10.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxSwift
import RxCocoa

class PaymentItemsViewModel {
    private let repository = PaymentRepository()
    private let disposeBag = DisposeBag()
    
    private let _paymentService: BehaviorRelay<PaymentService>
    
    private let _sectionModels: BehaviorRelay<[PaymentItemTableViewSectionModel]>
    var sectionModels: Observable<[PaymentItemTableViewSectionModel]> {
        return _sectionModels.asObservable()
    }
    
    struct State {
        let payments: [Payment]
        let year: Int
        let month: Int
        let dayCount: Int
        let paymentService: PaymentService
        let sectionModels: [PaymentItemTableViewSectionModel]
    }
    var currentStatus: State {
        return State(payments: _paymentService.value.currentState.payments,
                     year: _paymentService.value.currentState.year,
                     month: _paymentService.value.currentState.month,
                     dayCount: _paymentService.value.currentState.dayCount,
                     paymentService: _paymentService.value,
                     sectionModels: _sectionModels.value)
    }
    
    init(paymentService: BehaviorRelay<PaymentService>) {
        _paymentService = paymentService
        _sectionModels = BehaviorRelay<[PaymentItemTableViewSectionModel]>(value: [])
        
        _paymentService
            .flatMap { $0.payments }
            .map {
                $0.filter { $0.paymentItems.count != 0 }
            }
            .bind { [weak self] payments in
                let sectionModels = payments.map { PaymentItemTableViewSectionModel(payment: $0) }
                self?._sectionModels.accept(sectionModels)
            }
            .disposed(by: disposeBag)
            
    }
    
    func update(_ paymentService: PaymentService) {
        _paymentService.accept(paymentService)
    }
    
    func delete(at indexPath: IndexPath) {
        let payment = currentStatus.sectionModels[indexPath.section].currentStatus.payment
        _paymentService.value.delete(from: payment, at: indexPath)
    }
}
