//
//  UITableViewCell+App.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/03.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import Foundation
import UIKit

extension UIResponder {
    
    func next<T: UIResponder>(_ type: T.Type) -> T? {
        return next as? T ?? next?.next(type)
    }
}

extension UITableViewCell {
    
    var tableView: UITableView? {
        return next(UITableView.self)
    }
    
    var indexPath: IndexPath? {
        return tableView?.indexPath(for: self)
    }
}
