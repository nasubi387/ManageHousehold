//
//  PaymentItem.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/31.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

enum PaymentItemType: Int {
    case expense = 0
    case income = 1
    
    var sign: String {
        switch self {
        case .expense:
            return "-"
        case .income:
            return "+"
        }
    }
    
    var color: UIColor {
        switch self {
        case .expense:
            return UIColor.systemRed
        case .income:
            if #available(iOS 13.0, *) {
                return UIColor.systemIndigo
            } else {
                return UIColor.blue
            }
        }
    }
}

class PaymentItem: Object {
    @objc dynamic var id: String = UUID().uuidString
    dynamic var payment = LinkingObjects(fromType: Payment.self, property: "paymentItems")
    @objc dynamic var name: String = ""
    @objc dynamic var price: Int = 0
    @objc dynamic var date: Date = Date()
    @objc dynamic var category: Category?
    @objc dynamic private var type = 0

    var paymentItemType: PaymentItemType {
        get {
            return PaymentItemType(rawValue: type) ?? .expense
        }
        set {
            type = newValue.rawValue
        }
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(date: Date) {
        self.init()
        self.date = date
    }
}
