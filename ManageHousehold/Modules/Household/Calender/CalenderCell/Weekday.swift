//
//  Weekday.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/05.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import Foundation
import UIKit

enum Weekday: Int, CaseIterable {
    case sunday = 0
    case monday = 1
    case tuseday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
}

extension Weekday {
    var name: String {
        switch self {
        case .sunday:
            return "日"
        case .monday:
            return "月"
        case .tuseday:
            return "火"
        case .wednesday:
            return "水"
        case .thursday:
            return "木"
        case .friday:
            return "金"
        case .saturday:
            return "土"
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .sunday:
            return #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        case .saturday:
            return #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        default:
            if #available(iOS 13.0, *) {
                return UIColor.label
            } else {
                return UIColor.black
            }
        }
    }
}
