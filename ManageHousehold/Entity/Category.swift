//
//  Category.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/02.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
