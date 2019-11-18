//
//  LineGraphViewModel.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/14.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxSwift
import RxCocoa

class LineGraphViewModel {
    struct Dependency {
        let wireframe: LineGraphWireframe
        let paymentService: BehaviorRelay<PaymentService>
    }
    
    struct Input {
    }
    
    struct Output {
        let payments: Observable<[Payment]>
    }
    
    private let dependency: Dependency
    private let input: Input
    let output: Output
    
    private let disposeBag = DisposeBag()
    
    struct State {
        let paymentService: PaymentService
        let payments: [Payment]
    }
    var currentStatus: State {
        return State(paymentService: dependency.paymentService.value,
                     payments: dependency.paymentService.value.currentState.payments)
    }
    
    init(input: Input, dependency: Dependency) {
        self.dependency = dependency
        self.input = input
        
        let payments = dependency.paymentService
            .flatMap { $0.payments }
            .map {
                $0.filter {
                    let year = dependency.paymentService.value.currentState.year
                    let month = dependency.paymentService.value.currentState.month
                    return Calendar.current.component(.year, from: $0.date) == year
                        && Calendar.current.component(.month, from: $0.date) == month
                }
            }
        
        let output = Output(payments: payments)
        self.output = output
    }
}
