//
//  CalenderWireframe.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/19.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol CalenderWireframeInput {
    
}

class CalenderWireframe: CalenderWireframeInput {
    weak var view: CalenderViewController!
    
    init(view: CalenderViewController) {
        self.view = view
    }
    
    static func assembleModules(_ paymentService: BehaviorRelay<PaymentService>, parentInput: HouseholdViewModel.Input) -> CalenderViewController? {
        guard let view = UIStoryboard(name: CalenderViewController.className, bundle: nil).instantiateInitialViewController() as? CalenderViewController else {
            return nil
        }
        _ = view.view
        
        let wireframe = CalenderWireframe(view: view)
        let dependency = CalenderViewModel.Dependency(wireframe: wireframe,
                                                      paymentService: paymentService)
        let input = CalenderViewModel.Input(viewDidAppear: parentInput.viewDidAppear,
                                            itemSelected: view.rx.itemSelected,
                                            paymentItemDeleted: parentInput.paymentItemDeleted)
        let viewModel = CalenderViewModel(input: input, dependency: dependency)
        view.bind(viewModel)
        
        return view
    }
}
