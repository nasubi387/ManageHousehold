//
//  PaymentService.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/10.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxSwift
import RxCocoa

class PaymentService {
    private let repository = PaymentRepository()
    private let disposeBag = DisposeBag()
    
    private let _payments: BehaviorRelay<[Payment]>
    var payments: Observable<[Payment]> {
        _payments.asObservable()
    }
    
    private let _year: BehaviorRelay<Int>
    var year: Observable<Int> {
        return _year.asObservable()
    }
    
    private let _month: BehaviorRelay<Int>
    var month: Observable<Int> {
        return _month.asObservable()
    }
    
    private let _dayCount: BehaviorRelay<Int>
    var dayCount: Observable<Int> {
        return _dayCount.asObservable()
    }
    
    var calender: Observable<(Int, Int, Int)> {
        return Observable.combineLatest(_year.asObservable(),
                                        _month.asObservable(),
                                        _dayCount.asObservable())
    }
    
    struct State {
        let payments: [Payment]
        let year: Int
        let month: Int
        let dayCount: Int
    }
    
    var currentState: State {
        return State(payments: _payments.value,
                     year: _year.value,
                     month: _month.value,
                     dayCount: _dayCount.value)
    }
    
    init(year: Int, month: Int) {
        _payments = BehaviorRelay<[Payment]>(value: [])
        
        if month >= 13 {
            _year = BehaviorRelay<Int>(value: year + 1)
            _month = BehaviorRelay<Int>(value: month - 12)
        } else if month <= 0 {
            _year = BehaviorRelay<Int>(value: year - 1)
            _month = BehaviorRelay<Int>(value: month + 12)
        } else {
            _year = BehaviorRelay<Int>(value: year)
            _month = BehaviorRelay<Int>(value: month)
        }
        let dayCount = Calendar.current.getDayCount(year: year, month: month)
        _dayCount = BehaviorRelay<Int>(value: dayCount)
        
        fetchPayments()
    }
    
    func fetchPayments() {
        let year = _year.value
        let month = _month.value
        let dayCount = _dayCount.value
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        
        repository.fetch(year: year, month: month).map { [weak self] results in
            guard let self = self else {
                return []
            }
            var payments: [Payment] = []
            for day in 1...dayCount {
                let result = results.filter {
                    let resultDay = calendar.component(.day, from: $0.date)
                    return resultDay == day
                }.first
                if let result = result {
                    payments.append(result)
                } else {
                    let payment = Payment()
                    components.day = day
                    payment.date = calendar.date(from: components)
                    payments.append(payment)
                }
            }
            
            let prevDummyPayments = self.getPrevDummyPayments()
            let nextDummyPayments = self.getNextDummyPayments()
            
            return prevDummyPayments + payments + nextDummyPayments
        }
        .bind(to: _payments)
        .disposed(by: disposeBag)
    }
    
    func updatePayment(_ payment: Payment) {
        var newPayments = _payments.value
        let resultIndex = newPayments.firstIndex { $0.date == payment.date }
        guard let index = resultIndex else {
            return
        }
        repository.update(payment)
            .map {
                newPayments[index] = $0
                return newPayments
            }
            .bind(to: _payments)
            .disposed(by: disposeBag)
    }
    
    func delete(from payment: Payment, at indexPath: IndexPath) {
        repository.delete(payment, at: indexPath.row)
            .subscribe(onNext: { [weak self] newPayment in
                self?.updatePayment(newPayment)
            })
            .disposed(by: disposeBag)
    }
    
    func update(year: Int, month: Int) {
        _year.accept(year)
        _month.accept(month)
        _dayCount.accept(Calendar.current.getDayCount(year: year, month: month))
        fetchPayments()
    }
}

extension PaymentService {
    private func getPrevDummyPayments() -> [Payment] {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = _year.value
        components.month = _month.value
        components.day = 0
        let beginWeekday = calendar.getBeginWeekDay(year: _year.value, month: _month.value)
        
        var prevDummyPayments: [Payment] = []
        
        for index in 0..<(beginWeekday.rawValue - Weekday.sunday.rawValue) {
            let dummyPayment = Payment()
            components.day = components.day! - index
            dummyPayment.date = calendar.date(from: components)
            prevDummyPayments.insert(dummyPayment, at: 0)
        }
        return prevDummyPayments
    }
    
    private func getNextDummyPayments() -> [Payment] {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = _year.value
        components.month = _month.value + 1
        components.day = 0
        let endWeekday = calendar.getEndWeekDay(year: _year.value, month: _month.value)
        
        var nextDummyPayments: [Payment] = []
        
        for index in 0..<(Weekday.saturday.rawValue - endWeekday.rawValue) {
            let dummyPayment = Payment()
            components.day = index + 1
            dummyPayment.date = calendar.date(from: components)
            nextDummyPayments.append(dummyPayment)
        }
        
        return nextDummyPayments
    }
}

extension Calendar {
    func getDayCount(year: Int, month: Int) -> Int {
        let endDay = self.getEndDay(year: year, month: month)
        return self.component(.day, from: endDay)
    }
    
    func getEndDay(year: Int, month: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month + 1
        components.day = 0
        return self.date(from: components)!
    }
    
    func getBeginDay(year: Int, month: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        return self.date(from: components)!
    }
    
    func getEndWeekDay(year: Int, month: Int) -> Weekday {
        let date = self.getEndDay(year: year, month: month)
        return Weekday(rawValue: self.component(.weekday, from: date) - 1)!
    }
    
    func getBeginWeekDay(year: Int, month: Int) -> Weekday {
        var newYear = year
        var newMonth = month
        if month >= 13 {
            newYear = year + 1
            newMonth = month - 12
        } else if month <= 0 {
            newYear = year - 1
            newMonth = month + 12
        }
        let date = self.getBeginDay(year: newYear, month: newMonth)
        return Weekday(rawValue: self.component(.weekday, from: date) - 1)!
    }
}
