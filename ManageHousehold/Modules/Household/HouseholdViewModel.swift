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

class HouseholdViewModel {
    struct Dependency {
        let wireframe: HouseholdFireframe
        let paymentService: BehaviorRelay<PaymentService>
    }
    
    struct Input {
        let viewDidAppear: Observable<Bool>
        let didChangePageView: Observable<UIViewController>
        let didChangeItemPageView: Observable<UIViewController>
        let didTapAddButton: Signal<Void>
        let didChangePaymentItemSegmentControlValue: ControlProperty<Int>
    }
    
    struct Output {
        let calenderTitleText: Observable<String>
        let incomeText: Observable<String>
        let expenseText: Observable<String>
        let totalText: Observable<String>
        let paymentItemPageViewController: Observable<(UIViewController,UIPageViewController.NavigationDirection)>
    }
    
    private let dependency: Dependency
    private let input: Input
    let output: Output
    
    private let disposeBag = DisposeBag()
    
    private let _calenderViewModel: BehaviorRelay<CalenderViewModel?>
    private let _paymentItemsViewModel: BehaviorRelay<PaymentItemsViewModel>
    private let _lineGraphViewModel: BehaviorRelay<LineGraphViewModel>
    private let _paymentItemSegmentControlValue: BehaviorRelay<Int>
    
    struct State {
        let payments: [Payment]
        let year: Int
        let month: Int
        let dayCount: Int
        let paymentItemsViewModel: PaymentItemsViewModel
        let lineGraphViewModel: LineGraphViewModel
        let paymentService: PaymentService
    }
    
    var currentStatus: State {
        return State(payments: dependency.paymentService.value.currentState.payments,
                     year: dependency.paymentService.value.currentState.year,
                     month: dependency.paymentService.value.currentState.month,
                     dayCount: dependency.paymentService.value.currentState.dayCount,
                     paymentItemsViewModel: _paymentItemsViewModel.value,
                     lineGraphViewModel: _lineGraphViewModel.value,
                     paymentService: dependency.paymentService.value)
    }
    
    let paymentItemViewControllers: [UIViewController]
    
    init(input: Input, dependency: Dependency) {
        self.dependency = dependency
        
        let paymentItemsViewModel = PaymentItemsViewModel(paymentService: dependency.paymentService)
        _paymentItemsViewModel = BehaviorRelay<PaymentItemsViewModel>(value: paymentItemsViewModel)
        
        let lineGraphViewModel = LineGraphViewModel(paymentService: dependency.paymentService)
        _lineGraphViewModel = BehaviorRelay<LineGraphViewModel>(value: lineGraphViewModel)
        
        _calenderViewModel = BehaviorRelay<CalenderViewModel?>(value: nil)
        _calenderViewModel
            .filterNil()
            .map { $0.currentStatus.paymentService }
            .bind(to: dependency.paymentService)
            .disposed(by: disposeBag)
        
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
        
        let paymentItems = UIStoryboard(name: PaymentItemsViewController.className, bundle: nil).instantiateInitialViewController() as! PaymentItemsViewController
        _ = paymentItems.view
        paymentItems.bind(paymentItemsViewModel)
        
        let lineGraph = UIStoryboard(name: LineGraphViewController.className, bundle: nil).instantiateInitialViewController() as! LineGraphViewController
        _ = lineGraph.view
        lineGraph.bind(lineGraphViewModel)
        
        let paymentItemViewControllers = [paymentItems, lineGraph]
        self.paymentItemViewControllers = paymentItemViewControllers
        
        let paymentItemPageViewController = Observable.combineLatest(
                input.didChangePaymentItemSegmentControlValue,
                input.didChangePaymentItemSegmentControlValue
            )
            .map { index, previous -> (UIViewController, UIPageViewController.NavigationDirection)? in
                guard let view = paymentItemViewControllers[safe: index] else {
                    return nil
                }
                let direction: UIPageViewController.NavigationDirection = index - previous > 0 ? .forward : .reverse
                return (view, direction)
            }
            .filterNil()
        
        _paymentItemSegmentControlValue = BehaviorRelay<Int>(value: 0)
        
        output = Output(calenderTitleText: calenderTitleText,
                        incomeText: incomeText,
                        expenseText: expenseText,
                        totalText: totalText,
                        paymentItemPageViewController: paymentItemPageViewController)
        
        self.input = input
        
        // viewDidAppear
        input.viewDidAppear
            .subscribe(onNext: { [weak self] _ in
                self?.fetchPayments()
            })
            .disposed(by: disposeBag)
        
        // PageView
        input.didChangePageView
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] nextView in
                guard let viewModel = (nextView as? CalenderViewController)?.viewModel else { return }
                self?.update(viewModel)
            })
            .disposed(by: disposeBag)
        
        // ItemPageView
        input.didChangeItemPageView
            .distinctUntilChanged()
            .map { [weak self] in
                self?.paymentItemViewControllers.firstIndex(of: $0)
            }
            .filterNil()
            .bind(to: _paymentItemSegmentControlValue)
            .disposed(by: disposeBag)
        
        // AddButton
        input.didTapAddButton
            .emit(onNext: {
                let paymentItem = PaymentItem(date: Date())
                dependency.wireframe.presentInputPaymentView(with: paymentItem)
            })
            .disposed(by: disposeBag)
    }
    
    func update(_ calenderViewModel: CalenderViewModel) {
        calenderViewModel.fetchPayments()
        _calenderViewModel.accept(calenderViewModel)
    }
    
    private func fetchPayments() {
        dependency.paymentService.value.fetchPayments()
        _calenderViewModel.value?.fetchPayments()
    }
}
