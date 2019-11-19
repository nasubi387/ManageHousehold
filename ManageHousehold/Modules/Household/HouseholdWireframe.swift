//
//  HouseholdWireframe.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/18.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol HouseholdWireframeInput {
    
}

class HouseholdWireframe: HouseholdWireframeInput {
    weak var view: HouseholdViewController!
    
    init(view: HouseholdViewController) {
        self.view = view
    }
    
    static func assembleModules() -> UINavigationController? {
        guard let navigationController = UIStoryboard(name: HouseholdViewController.className, bundle: nil).instantiateInitialViewController() as? UINavigationController,
            let view = navigationController.viewControllers.first as? HouseholdViewController else {
            return nil
        }
        _ = view.view
        
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let paymentService = PaymentService(year: year, month: month)
        let paymenrServiceObserver = BehaviorRelay<PaymentService>(value: paymentService)
        
        guard let paymentItemsView = PaymentItemsWireframe.assembleModules(paymenrServiceObserver),
            let lineGraph = LineGraphWireframe.assembleModules(paymenrServiceObserver) else {
            return nil
        }
        
        let wireframe = HouseholdWireframe(view: view)
        
        let input = HouseholdViewModel.Input(viewDidAppear: view.rx.viewDidAppear,
                                             didChangePageView: view.pageView.rx.didChangePage,
                                             didChangeItemPageView: view.paymentItemPageView.rx.didChangePage,
                                             didTapAddButton: view.addButton.rx.tap.asSignal(),
                                             didChangePaymentItemSegmentControlValue: view.paymentItemSegmentControl.rx.value,
                                             paymentItemDeleted: paymentItemsView.tableView.rx.itemDeleted)
        
        let dependency = HouseholdViewModel.Dependency(wireframe: wireframe,
                                                       paymentService: paymenrServiceObserver,
                                                       paymentItemViewControllers: [paymentItemsView, lineGraph])
        guard let viewModel = HouseholdViewModel(input: input, dependency: dependency) else {
            return nil
        }
        view.bind(viewModel)
        
        return navigationController
    }
    
    func presentInputPaymentView(with paymentItem: PaymentItem) {
        guard let inputPaymentView = InputPaymentWireframe.assembleModules(paymentItem) else {
            return
        }
        self.view.present(inputPaymentView, animated: true)
    }
    
    func calenderView(year: Int, month: Int) -> CalenderViewController? {
        let paymentService = PaymentService(year: year, month: month)
        return CalenderWireframe.assembleModules(BehaviorRelay<PaymentService>(value: paymentService), parentInput: view.viewModel.input)
    }
}
