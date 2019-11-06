//
//  Array+App.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/21.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        guard index <= count - 1 && index >= 0 else {
            return nil
        }
        return self[index]
    }
}
