//
//  Payment.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/02.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import Foundation
import RealmSwift

class Payment: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var date: Date!
    let paymentItems: List<PaymentItem> = List<PaymentItem>()
    var income: Int {
        return paymentItems.reduce(0) {
            guard $1.paymentItemType == .income else {
                return $0
            }
            return $0 + $1.price
        }
    }
    var expense: Int {
        return paymentItems.reduce(0) {
            guard $1.paymentItemType == .expense else {
                return $0
            }
            return $0 + $1.price
        }
    }
    var total: Int {
        return income - expense
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
