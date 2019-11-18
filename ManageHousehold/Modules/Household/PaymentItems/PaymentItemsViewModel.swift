//
//  PaymentItemsViewModel.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/10.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PaymentItemsViewModel {
    struct Dependency {
        let wireframe: PaymentItemsWireFrame
        let paymentService: BehaviorRelay<PaymentService>
    }
    
    struct Input {
        let itemSelected: ControlEvent<IndexPath>
        let itemDeleted: ControlEvent<IndexPath>
    }
    
    struct Output {
        let sectionModels: Observable<[PaymentItemTableViewSectionModel]>
        let itemSelected: Observable<IndexPath>
    }
    
    private let dependency: Dependency
    private let input: Input
    let output: Output
    
    private let disposeBag = DisposeBag()
    
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
        return State(payments: dependency.paymentService.value.currentState.payments,
                     year: dependency.paymentService.value.currentState.year,
                     month: dependency.paymentService.value.currentState.month,
                     dayCount: dependency.paymentService.value.currentState.dayCount,
                     paymentService: dependency.paymentService.value,
                     sectionModels: _sectionModels.value)
    }
    
    init(input: Input, dependency: Dependency) {
        self.dependency = dependency
        self.input = input
        
        _sectionModels = BehaviorRelay<[PaymentItemTableViewSectionModel]>(value: [])
        let sectionModels = _sectionModels.asObservable()
        
        let itemSelected = input.itemSelected.asObservable()
        self.output = Output(sectionModels: sectionModels,
                             itemSelected: itemSelected)
        
        dependency.paymentService
            .flatMap { $0.payments }
            .map { payments -> [PaymentItemTableViewSectionModel] in
                let filterdPayments = payments.filter {
                    $0.paymentItems.count != 0
                }
                let sectionModels = filterdPayments.map {
                    PaymentItemTableViewSectionModel(payment: $0)
                }
                return sectionModels
            }
            .bind(to: _sectionModels)
            .disposed(by: disposeBag)
            
        self.input.itemSelected
            .map { [weak self] indexPath -> PaymentItem? in
                let payment = self?.currentStatus.sectionModels[indexPath.section].currentStatus.payment
                return payment?.paymentItems[indexPath.row]
            }
            .filterNil()
            .subscribe(onNext: { [weak self] in
                self?.dependency.wireframe.presentInputPaymentView(with: $0)
            })
            .disposed(by: disposeBag)
        
        self.input.itemDeleted
            .map { [weak self] indexPath -> (Payment, IndexPath)? in
                guard let payment = self?.currentStatus.sectionModels[indexPath.section].currentStatus.payment else {
                    return nil
                }
                return (payment, indexPath)
            }
            .filterNil()
            .subscribe(onNext: { [weak self] (payment, indexPath) in
                self?.dependency.paymentService.value.delete(from: payment, at: indexPath)
            })
            .disposed(by: disposeBag)
    }
}
