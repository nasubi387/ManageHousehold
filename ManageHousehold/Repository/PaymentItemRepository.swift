//
//  PaymentItemRepository.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/04.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxSwift

class PaymentItemRepository {
    func update(_ paymentItem: PaymentItem) -> Observable<PaymentItem>{
        return RealmManager.shared.update(paymentItem)
    }
    
    func delete(_ paymentItem: PaymentItem) -> Observable<PaymentItem>{
        return RealmManager.shared.delete(paymentItem)
    }
}
