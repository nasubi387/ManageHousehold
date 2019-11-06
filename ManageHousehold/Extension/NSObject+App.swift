//
//  NSObject+App.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/03.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import Foundation

extension NSObject {
    class var className: String {
        return String(describing: self)
    }

    var className: String {
        return type(of: self).className
    }
}
