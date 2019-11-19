//
//  InputPaymentViewModel.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/27.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class InputPaymentViewModel {
    struct Dependency {
        let paymentRepository = PaymentRepository()
        let wireframe: InputPaymentWireframe
    }
    
    struct Input {
        let tapGesture: SharedSequence<DriverSharingStrategy, UITapGestureRecognizer>
        let changePaymentSegmentControlValue: Driver<Int>
        let tapCloseButton: ControlEvent<()>
        let tapSaveButton: ControlEvent<()>
    }
    
    struct Output {
        let segmentControl: Observable<Int>
        let paymentItem: Observable<PaymentItem>
        let dismissKeybord: Observable<Bool>
        let dismissView: Observable<Bool>
    }
    
    private let dependency: Dependency
    private let input: Input
    let output: Output
    
    private let disposeBag = DisposeBag()
    
    private var _paymentItem: BehaviorRelay<PaymentItem>
    private var _cellModels: BehaviorRelay<[InputPaymentCellViewModel]>
    
    var currentStatus: (paymentItem: PaymentItem, cellModels: [InputPaymentCellViewModel]) {
        return (paymentItem: _paymentItem.value,
                cellModels: _cellModels.value)
    }
    
    init(input: Input, dependency: Dependency, paymentItem: PaymentItem) {
        self.input = input
        self.dependency = dependency
        
        _paymentItem = BehaviorRelay<PaymentItem>(value: paymentItem)
        
        let segmentControl = _paymentItem
            .map { $0.paymentItemType.rawValue }
            .distinctUntilChanged()
        
        let paymentItemObservable = _paymentItem.asObservable()
        
        let dismissKeybord = input.tapGesture
            .map { _ in true }
            .asObservable()
        
        let dismissView = Observable.merge([input.tapCloseButton.asObservable(),
                                            input.tapSaveButton.asObservable()]).map { true }
        
        output = Output(segmentControl: segmentControl,
                        paymentItem: paymentItemObservable,
                        dismissKeybord: dismissKeybord,
                        dismissView: dismissView)
        
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
        
        self.input.tapSaveButton
            .subscribe(onNext: { [weak self] in
                self?.writePaymentItem()
            })
            .disposed(by: disposeBag)
        
        self.input.changePaymentSegmentControlValue
            .drive(onNext: { [weak self] in
                self?.didChange($0)
            })
            .disposed(by: disposeBag)
    }
    
    private func didChange(_ segment: Int) {
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
    
    private func writePaymentItem() {
        let paymentItem = currentStatus.paymentItem
        
        dependency.paymentRepository.fetch(paymentItem.date)
            .subscribe(onNext: { [weak self] payment in
                guard let self = self else { return }
                let newPayment = Payment(value: payment)
                let index = newPayment.paymentItems.firstIndex { $0.id == paymentItem.id}
                if let index = index {
                    newPayment.paymentItems.replace(index: index, object: paymentItem)
                } else {
                    newPayment.paymentItems.append(paymentItem)
                }
                self.dependency.paymentRepository
                    .update(newPayment)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}
