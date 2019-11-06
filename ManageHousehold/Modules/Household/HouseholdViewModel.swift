//
//  HouseholdViewModel.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/01.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

class HouseholdViewModel {
    private let repository = PaymentRepository()
    private let disposeBag = DisposeBag()
    
    private let _calenderViewModel: BehaviorRelay<CalenderViewModel?>
    private let _paymentItemsViewModel: BehaviorRelay<PaymentItemsViewModel>
    private let _lineGraphViewModel: BehaviorRelay<LineGraphViewModel>
    private let _paymentService: BehaviorRelay<PaymentService>
    
    var calenderTitleText: Observable<String>
    var incomeText: Observable<String>
    var expenseText: Observable<String>
    var totalText: Observable<String>
    
    struct State {
        let payments: [Payment]
        let year: Int
        let month: Int
        let dayCount: Int
        let paymentItemsViewModel: PaymentItemsViewModel
        let lineGraphViewModel: LineGraphViewModel
        let paymentService: PaymentService
    }
    var currentStatus: State {
        return State(payments: _paymentService.value.currentState.payments,
                     year: _paymentService.value.currentState.year,
                     month: _paymentService.value.currentState.month,
                     dayCount: _paymentService.value.currentState.dayCount,
                     paymentItemsViewModel: _paymentItemsViewModel.value,
                     lineGraphViewModel: _lineGraphViewModel.value,
                     paymentService: _paymentService.value)
    }
    
    init(paymentService: PaymentService) {
        _paymentService = BehaviorRelay<PaymentService>(value: paymentService)
        
        let paymentItemsViewModel = PaymentItemsViewModel(paymentService: _paymentService)
        _paymentItemsViewModel = BehaviorRelay<PaymentItemsViewModel>(value: paymentItemsViewModel)
        
        let lineGraphViewModel = LineGraphViewModel(paymentService: _paymentService)
        _lineGraphViewModel = BehaviorRelay<LineGraphViewModel>(value: lineGraphViewModel)
        
        _calenderViewModel = BehaviorRelay<CalenderViewModel?>(value: nil)
        _calenderViewModel
            .filterNil()
            .map { $0.currentStatus.paymentService }
            .bind(to: _paymentService)
            .disposed(by: disposeBag)
        
        calenderTitleText = _paymentService.flatMap { $0.calender }
            .map { (year, month, dayCount) in
                "\(year)年\(month)月"
            }
            .distinctUntilChanged()
        
        incomeText = _paymentService.flatMap { $0.payments }
            .map { String($0.reduce(0) { $0 + $1.income }) }
            .distinctUntilChanged()
        
        expenseText = _paymentService.flatMap { $0.payments }
            .map { String($0.reduce(0) { $0 + $1.expense }) }
            .distinctUntilChanged()
        
        totalText = _paymentService.flatMap { $0.payments }
            .map { String($0.reduce(0) { $0 + $1.total }) }
            .distinctUntilChanged()
    }
    
    func update(_ calenderViewModel: CalenderViewModel) {
        calenderViewModel.fetchPayments()
        _calenderViewModel.accept(calenderViewModel)
    }
    
    func updatePayment(_ payment: Payment) {
        _paymentService.value.updatePayment(payment)
        _calenderViewModel.value?.fetchPayments()
    }
    
    func fetchPayments() {
        _paymentService.value.fetchPayments()
        _calenderViewModel.value?.fetchPayments()
    }
}
