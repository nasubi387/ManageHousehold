//
//  InputPaymentWireframe.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/19.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol InputPaymentWireframeInput {

}

class InputPaymentWireframe: InputPaymentWireframeInput {
    weak var view: InputPaymentViewController!
    
    init(view: InputPaymentViewController) {
        self.view = view
    }
    
    static func assembleModules(_ paymentItem: PaymentItem) -> UINavigationController? {
        guard let navigationController = UIStoryboard(name: InputPaymentViewController.className, bundle: nil).instantiateInitialViewController() as? UINavigationController,
            let view = navigationController.viewControllers.first as? InputPaymentViewController else {
            return nil
        }
        _ = view.view
        
        let wireframe = InputPaymentWireframe(view: view)
        
        let dependency = InputPaymentViewModel.Dependency(wireframe: wireframe)
        let input = InputPaymentViewModel.Input(tapGesture: view.tapGesture.rx.event.asDriver(),
                                                changePaymentSegmentControlValue: view.paymentSegmentControl.rx.value.asDriver().skip(1),
                                                tapCloseButton: view.closeButton.rx.tap,
                                                tapSaveButton: view.saveButton.rx.tap)
        
        let viewModel = InputPaymentViewModel(input: input,
                                              dependency: dependency,
                                              paymentItem: paymentItem)
        
        view.bind(viewModel)
        
        return navigationController
    }
}
