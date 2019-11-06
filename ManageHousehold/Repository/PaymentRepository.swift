//
//  PaymentRepository.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/02.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import Foundation
import RxSwift
import Realm
import RealmSwift

class PaymentRepository {
    func fetch(year: Int, month: Int) -> Observable<[Payment]> {
        return RealmManager.shared
            .fetchAll(Payment.self)
            .map { results in
                let resultArray = Array(results)
                return resultArray.filter {
                    let calendar = Calendar.current
                    let resultYear = calendar.component(.year, from: $0.date)
                    let resultMonth = calendar.component(.month, from: $0.date)
                    return year == resultYear && month == resultMonth
                }
        }
    }
    
    func fetch(_ date: Date) -> Observable<Payment> {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return RealmManager.shared
            .fetchAll(Payment.self)
            .map { results in
                let payment = Array(results).filter {
                    let resultYear = calendar.component(.year, from: $0.date)
                    let resultMonth = calendar.component(.month, from: $0.date)
                    let resultDay = calendar.component(.day, from: $0.date)
                    return year == resultYear && month == resultMonth && day == resultDay
                }.first
                if let payment = payment {
                    return payment
                } else {
                    let newPayment = Payment()
                    newPayment.date = date
                    return newPayment
                }
        }
    }
    
    func update(_ payment: Payment) -> Observable<Payment> {
        return RealmManager.shared.update(payment)
    }
    
    func delete(_ payment: Payment, at itemIndex: Int) -> Observable<Payment> {
        let realm = try! Realm()
        return Observable<Payment>.create { observer in
            MainScheduler.ensureExecutingOnScheduler()
            do {
                try realm.write {
                    payment.paymentItems.remove(at: itemIndex)
                    try realm.commitWrite()
                    observer.onNext(payment)
                    observer.onCompleted()
                }
            } catch let error {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
}
