//
//  PaymentItemTableViewSectionModel.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/13.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxCocoa
import RxSwift

class PaymentItemTableViewSectionModel {
    private let disposeBag = DisposeBag()
    
    private let _cellModels: BehaviorRelay<[PaymentItemTableViewCellViewModel]>
    
    private let payment: Payment
    
    struct State {
        let payment: Payment
        let cellModels: [PaymentItemTableViewCellViewModel]
    }
    var currentStatus: State {
        return State(payment: payment,
                     cellModels: _cellModels.value)
    }
    
    init(payment: Payment) {
        self.payment = payment
        
        let paymentItems = Array(payment.paymentItems)
        let cellModels = paymentItems.map {
            PaymentItemTableViewCellViewModel(paymentItem: $0, isHiddenBorder: $0 == paymentItems.last)
        }
        _cellModels = BehaviorRelay<[PaymentItemTableViewCellViewModel]>(value: cellModels)
    }
}
