//
//  CalenderViewModel.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/20.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

class CalenderViewModel {
    struct Dependency {
        let wireframe: CalenderFireframe
        let paymentService: BehaviorRelay<PaymentService>
    }
    
    struct Input {
        let viewDidAppear: Observable<Bool>
        let itemSelected: ControlEvent<Date>
        let paymentItemDeleted: ControlEvent<IndexPath>
    }
    
    struct Output {
        let cellModels: Observable<[CalenderCellViewModel]>
        let itemSelected: Observable<PaymentItem>
    }
    
    private let dependency: Dependency
    private let input: Input
    let output: Output
    
    private let repository = PaymentRepository()
    private let disposeBag = DisposeBag()
    
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
                     paymentService: dependency.paymentService.value)
    }
    
    init(input: Input, dependency: Dependency) {
        self.dependency = dependency
        self.input = input
        
        _cellModels = BehaviorRelay<[CalenderCellViewModel]>(value: [])
        let cellModels = _cellModels.asObservable()
        
        let itemSelected = input.itemSelected
            .map { date -> PaymentItem? in
                guard Calendar.current.component(.year, from: date) == dependency.paymentService.value.currentState.year
                    && Calendar.current.component(.month, from: date) == dependency.paymentService.value.currentState.month else {
                        return nil
                }
                return PaymentItem(date: date)
            }
            .filterNil()
        
        output = Output(cellModels: cellModels,
                        itemSelected: itemSelected)
        
        dependency.paymentService
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
        
        input.viewDidAppear
            .subscribe(onNext: { [weak self] _ in
                self?.fetchPayments()
            })
            .disposed(by: disposeBag)
        
        input.paymentItemDeleted
            .subscribe(onNext: { [weak self] _ in
                self?.fetchPayments()
            })
            .disposed(by: disposeBag)
        
        fetchPayments()
    }
    
    func fetchPayments() {
        dependency.paymentService.value.fetchPayments()
    }
    
    func updatePayment(_ payment: Payment) {
        dependency.paymentService.value.updatePayment(payment)
    }
}
