//
//  HouseholdViewModel.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/01.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

class HouseholdViewModel: NSObject {
    struct Dependency {
        let wireframe: HouseholdWireframe
        let paymentService: BehaviorRelay<PaymentService>
        let paymentItemViewControllers: [UIViewController]
    }
    
    struct Input {
        let viewDidAppear: Observable<Bool>
        let didChangePageView: Observable<UIViewController>
        let didChangeItemPageView: Observable<UIViewController>
        let didTapAddButton: Signal<Void>
        let didChangePaymentItemSegmentControlValue: ControlProperty<Int>
        var paymentItemDeleted: ControlEvent<IndexPath>
    }
    
    struct Output {
        let calenderTitleText: Observable<String>
        let incomeText: Observable<String>
        let expenseText: Observable<String>
        let totalText: Observable<String>
        let paymentItemPageViewController: Observable<(UIViewController,UIPageViewController.NavigationDirection)>
        let initialCalender: Observable<[CalenderViewController]>
    }
    
    private let dependency: Dependency
    var input: Input
    let output: Output
    
    private let disposeBag = DisposeBag()
    
    private let _paymentItemSegmentControlValue: BehaviorRelay<Int>
    private let _initialCalender: BehaviorRelay<[CalenderViewController]>
    
    struct State {
        let payments: [Payment]
        let year: Int
        let month: Int
        let dayCount: Int
        let paymentService: PaymentService
    }
    
    var currentStatus: State {
        return State(payments: dependency.paymentService.value.currentState.payments,
                     year: dependency.paymentService.value.currentState.year,
                     month: dependency.paymentService.value.currentState.month,
                     dayCount: dependency.paymentService.value.currentState.dayCount,
                     paymentService: dependency.paymentService.value)
    }
    
    init?(input: Input, dependency: Dependency) {
        self.dependency = dependency
        self.input = input
        
        guard let initialCalenderViewController = CalenderWireframe.assembleModules(dependency.paymentService, parentInput: input) else {
            return nil
        }
        _initialCalender = BehaviorRelay<[CalenderViewController]>(value: [initialCalenderViewController])
        _paymentItemSegmentControlValue = BehaviorRelay<Int>(value: 0)
        
        // output
        let calenderTitleText = dependency.paymentService
            .flatMap { $0.calender }
            .map { (year, month, dayCount) in
                "\(year)年\(month)月"
            }
            .distinctUntilChanged()
        
        let incomeText = dependency.paymentService
            .flatMap { $0.payments }
            .map { String($0.reduce(0) { $0 + $1.income }) }
            .distinctUntilChanged()
        
        let expenseText = dependency.paymentService
            .flatMap { $0.payments }
            .map { String($0.reduce(0) { $0 + $1.expense }) }
            .distinctUntilChanged()
        
        let totalText = dependency.paymentService
            .flatMap { $0.payments }
            .map { String($0.reduce(0) { $0 + $1.total }) }
            .distinctUntilChanged()
        
        let paymentItemPageViewController = Observable.combineLatest(
                input.didChangePaymentItemSegmentControlValue,
                input.didChangePaymentItemSegmentControlValue
            )
            .map { index, previous -> (UIViewController, UIPageViewController.NavigationDirection)? in
                guard let view = dependency.paymentItemViewControllers[safe: index] else {
                    return nil
                }
                let direction: UIPageViewController.NavigationDirection = index - previous > 0 ? .forward : .reverse
                return (view, direction)
            }
            .filterNil()
        
        let initialCalender = _initialCalender.asObservable()
        
        output = Output(calenderTitleText: calenderTitleText,
                        incomeText: incomeText,
                        expenseText: expenseText,
                        totalText: totalText,
                        paymentItemPageViewController: paymentItemPageViewController,
                        initialCalender: initialCalender)
        
        super.init()
        // viewDidAppear
        self.input.viewDidAppear
            .subscribe(onNext: { [weak self] _ in
                self?.fetchPayments()
            })
            .disposed(by: disposeBag)
        
        // itemDeleted
        self.input.paymentItemDeleted
            .subscribe(onNext: { [weak self] _ in
                self?.fetchPayments()
            })
            .disposed(by: disposeBag)
        
        // PageView
        self.input.didChangePageView
            .map { ($0 as? CalenderViewController)?.viewModel.currentStatus.paymentService }
            .filterNil()
            .bind(to: dependency.paymentService)
            .disposed(by: disposeBag)
        
        self.input.didChangePageView
            .map { $0 as? CalenderViewController }
            .filterNil()
            .subscribe(onNext: { [weak self] view in
                view.viewModel.output.itemSelected
                    .subscribe(onNext:{ [weak self] in
                        self?.dependency.wireframe.presentInputPaymentView(with: $0)
                    })
                    .disposed(by: view.disposeBag)
            })
            .disposed(by: disposeBag)
        
        // ItemPageView
        self.input.didChangeItemPageView
            .distinctUntilChanged()
            .map { [weak self] in
                self?.dependency.paymentItemViewControllers.firstIndex(of: $0)
            }
            .filterNil()
            .bind(to: _paymentItemSegmentControlValue)
            .disposed(by: disposeBag)
        
        // AddButton
        self.input.didTapAddButton
            .emit(onNext: {
                let paymentItem = PaymentItem(date: Date())
                dependency.wireframe.presentInputPaymentView(with: paymentItem)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchPayments() {
        dependency.paymentService.value.fetchPayments()
    }
}

extension HouseholdViewModel: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return dependency.wireframe.calenderView(year: currentStatus.year, month: currentStatus.month - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return dependency.wireframe.calenderView(year: currentStatus.year, month: currentStatus.month + 1)
    }
}
