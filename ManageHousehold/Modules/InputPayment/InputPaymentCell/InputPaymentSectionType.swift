//
//  InputPaymentSectionType.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/02.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import Foundation

enum InputPaymentSectionType: Int, CaseIterable {
    case price = 0
    case detail = 1
}

extension InputPaymentSectionType {
    var cellCount: Int {
        switch self {
        case .price:
            return InputPaymentPriceCellType.allCases.count
        case .detail:
            return InputPaymentDetailCellType.allCases.count
        }
    }
    
    var title: String {
        switch self {
        case .price:
            return ""
        case .detail:
            return ""
        }
    }
}
