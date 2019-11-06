//
//  PaymentItemTableViewCellViewModel.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/13.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class PaymentItemTableViewCellViewModel {
    private let disposeBag = DisposeBag()
    
    private let _paymentItem: BehaviorRelay<PaymentItem>
    
    let categoryText: Observable<String?>
    let itemNameText: Observable<String?>
    let priceText: Observable<String?>
    let priceTextColor: Observable<UIColor>
    let isHiddenBorder: Observable<Bool>
    
    init(paymentItem: PaymentItem, isHiddenBorder: Bool) {
        _paymentItem = BehaviorRelay<PaymentItem>(value: paymentItem)
        categoryText = _paymentItem.map { $0.category?.name }
        itemNameText = _paymentItem.map { $0.name}
        priceText = _paymentItem.map { "\($0.paymentItemType.sign)\($0.price)円" }
        priceTextColor = _paymentItem.map { $0.paymentItemType.color }
        self.isHiddenBorder = Observable<Bool>.just(isHiddenBorder)
    }
}
