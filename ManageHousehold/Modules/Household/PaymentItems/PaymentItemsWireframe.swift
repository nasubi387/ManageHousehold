//
//  PaymentItemsWireframe.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/18.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol PaymentItemsWireframeInput {
    
}

class PaymentItemsWireframe: PaymentItemsWireframeInput {
    weak var view: PaymentItemsViewController!
    
    init(view: PaymentItemsViewController) {
        self.view = view
    }
    
    static func assembleModules(_ paymentService: BehaviorRelay<PaymentService>) -> PaymentItemsViewController? {
        guard let view = UIStoryboard(name: PaymentItemsViewController.className, bundle: nil).instantiateInitialViewController() as? PaymentItemsViewController else {
            return nil
        }
        _ = view.view
        
        let wireframe = PaymentItemsWireframe(view: view)
        let dependency = PaymentItemsViewModel.Dependency(wireframe: wireframe,
                                                          paymentService: paymentService)
        let input = PaymentItemsViewModel.Input(itemSelected: view.tableView.rx.itemSelected,
                                                itemDeleted: view.tableView.rx.itemDeleted)
        let viewModel = PaymentItemsViewModel(input: input, dependency: dependency)
        view.bind(viewModel)
        
        return view
    }
    
    func presentInputPaymentView(with paymentItem: PaymentItem) {
        guard let inputPaymentView = InputPaymentWireframe.assembleModules(paymentItem) else {
            return
        }
        self.view.present(inputPaymentView, animated: true)
    }
}
