//
//  Expense.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/31.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import Foundation
import RealmSwift

class Expense: Object, PaymentItem {
    @objc dynamic var id: String = UUID().uuidString
    dynamic var name: String = ""
    dynamic var price: Int = 0
    dynamic var date: Date = Date()
    
    override static func primaryKey() -> String? {
      return "id"
    }
}
