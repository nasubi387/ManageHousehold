//
//  InputPaymentViewModel.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/27.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxSwift
import RxCocoa
import RealmSwift

class InputPaymentViewModel {
    private let paymentItemRepository = PaymentItemRepository()
    private let paymentRepository = PaymentRepository()
    
    private let disposeBag = DisposeBag()
    
    private var _paymentItem: BehaviorRelay<PaymentItem>
    private var _cellModels: BehaviorRelay<[InputPaymentCellViewModel]>
    
    var paymentItem: Observable<PaymentItem> {
        return _paymentItem.asObservable()
    }
    var segmentControl: Observable<Int>
    
    var currentStatus: (paymentItem: PaymentItem, cellModels: [InputPaymentCellViewModel]) {
        return (paymentItem: _paymentItem.value,
                cellModels: _cellModels.value)
    }
    
    init(paymentItem: PaymentItem) {
        _paymentItem = BehaviorRelay<PaymentItem>(value: paymentItem)
        segmentControl = _paymentItem
            .map { $0.paymentItemType.rawValue }
            .distinctUntilChanged()
        var cellModels: [InputPaymentCellViewModel] = []
        InputPaymentSectionType.allCases.forEach { sectionType in
            switch sectionType {
            case .price:
                InputPaymentPriceCellType.allCases.forEach { cellType in
                    let indexPath = IndexPath(row: cellType.rawValue, section: sectionType.rawValue)
                    cellModels.append(InputPaymentCellViewModel(paymentItem: paymentItem, indexPath: indexPath))
                }
            case .detail:
                InputPaymentDetailCellType.allCases.forEach { cellType in
                    let indexPath = IndexPath(row: cellType.rawValue, section: sectionType.rawValue)
                    cellModels.append(InputPaymentCellViewModel(paymentItem: paymentItem, indexPath: indexPath))
                }
            }
        }
        _cellModels = BehaviorRelay<[InputPaymentCellViewModel]>(value: cellModels)
        _cellModels.value.forEach { cellModel in
            cellModel.paymentItem
                .distinctUntilChanged()
                .bind(to: _paymentItem)
                .disposed(by: disposeBag)
        }
    }
    
    func didChange(_ segment: Int) {
        guard let paymentItemType = PaymentItemType(rawValue: segment) else {
            return
        }
        _cellModels.value.forEach {
            $0.didChange(paymentItemType)
        }
    }
    
    func didChange(_ paymentItem: PaymentItem) {
        _cellModels.value.forEach {
            $0.didChange(paymentItem)
        }
    }
    
    func writePaymentItem() {
        let paymentItem = _paymentItem.value
        paymentRepository.fetch(paymentItem.date)
            .subscribe(onNext: { [weak self] payment in
                guard let self = self else { return }
                let newPayment = Payment(value: payment)
                let index = newPayment.paymentItems.firstIndex { $0.id == paymentItem.id}
                if let index = index {
                    newPayment.paymentItems.replace(index: index, object: paymentItem)
                } else {
                    newPayment.paymentItems.append(paymentItem)
                }
                self.paymentRepository
                    .update(newPayment)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}
