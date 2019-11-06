//
//  InputPaymentCellType.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/02.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import Foundation

protocol InputPaymentCellType: CaseIterable {
    var title: String { get }
}

enum InputPaymentPriceCellType: Int, InputPaymentCellType {
    case price = 0
}

extension InputPaymentPriceCellType {
    var title: String {
        switch self {
        case .price:
            return "金額"
        }
    }
}

enum InputPaymentDetailCellType: Int, InputPaymentCellType {
    case category = 0
    case name = 1
    case date = 2
}

extension InputPaymentDetailCellType {
    var title: String {
        switch self {
        case .category:
            return "カテゴリ"
        case .name:
            return "項目名"
        case .date:
            return "日付"
        }
    }
}
