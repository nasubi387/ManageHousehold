//
//  UITraitCollection+App.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/05.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit

extension UITraitCollection {
    public static var isDarkMode: Bool {
        if #available(iOS 13, *), current.userInterfaceStyle == .dark {
            return true
        }
        return false
    }
}
