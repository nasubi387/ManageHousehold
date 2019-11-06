//
//  CategoryRepository.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/06.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxSwift

class CategoryRepository {
    func fetch() -> Observable<[Category]> {
        return RealmManager.shared
            .fetchAll(Category.self)
            .map { return Array($0) }
    }
    
    func update(_ category: Category) -> Observable<Category> {
        return RealmManager.shared.update(category)
    }
}
