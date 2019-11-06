//
//  RealmManager.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/04.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxSwift
import RealmSwift
import Realm

class RealmManager {
    static let shared = RealmManager()
    private let realm: Realm
    static let schemaVersion: UInt64 = 1
    
    private init() {
        var config = Realm.Configuration()
        config.schemaVersion = RealmManager.schemaVersion
        config.migrationBlock = { migration, oldSchemaVersion in
            guard RealmManager.schemaVersion > oldSchemaVersion else {
                return
            }
            // migration
        }
        Realm.Configuration.defaultConfiguration = config
        realm  = try! Realm()
    }
    
    func update<Element: Object>(_ object: Element) -> Observable<Element> {
        return Observable<Element>.create { [weak self] observer in
            MainScheduler.ensureExecutingOnScheduler()
            guard let self = self else {
                return Disposables.create()
            }
            do {
                try self.realm.write {
                    self.realm.add(object, update: .all)
                    try self.realm.commitWrite()
                    observer.onNext(object)
                    observer.onCompleted()
                }
            } catch let error {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func delete<Element: Object>(_ object: Element) -> Observable<Element> {
        return Observable<Element>.create { [weak self] observer in
            MainScheduler.ensureExecutingOnScheduler()
            guard let self = self else {
                return Disposables.create()
            }
            do {
                try self.realm.write {
                    self.realm.delete(object)
                    try self.realm.commitWrite()
                    observer.onNext(object)
                    observer.onCompleted()
                }
            } catch let error {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func fetchAll<Element: Object>(_ type: Element.Type) -> Observable<Results<Element>> {
        return Observable<Results<Element>>.create { [weak self] observer in
            MainScheduler.ensureExecutingOnScheduler()
            guard let self = self else {
                return Disposables.create()
            }
            let objects = self.realm.objects(Element.self)
            observer.onNext(objects)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func fetch<Element: Object>(_ type: Element.Type, where condition: String) -> Observable<Results<Element>> {
        return Observable<Results<Element>>.create { [weak self] observer in
            MainScheduler.ensureExecutingOnScheduler()
            guard let self = self else {
                return Disposables.create()
            }
            let objects = self.realm.objects(Element.self).filter(condition)
            observer.onNext(objects)
            observer.onCompleted()
            return Disposables.create()
        }
    }
}
