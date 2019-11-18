//
//  LineGraphWireframe.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/19.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol LineGraphWireframeInput {
    
}

class LineGraphWireframe: LineGraphWireframeInput {
    weak var view: LineGraphViewController!
    
    init(view: LineGraphViewController) {
        self.view = view
    }
    
    static func assembleModules(_ paymentService: BehaviorRelay<PaymentService>) -> LineGraphViewController? {
        guard let view = UIStoryboard(name: LineGraphViewController.className, bundle: nil).instantiateInitialViewController() as? LineGraphViewController else {
            return nil
        }
        _ = view.view
        
        let wireframe = LineGraphWireframe(view: view)
        let dependency = LineGraphViewModel.Dependency(wireframe: wireframe,
                                                       paymentService: paymentService)
        let input = LineGraphViewModel.Input()
        let viewModel = LineGraphViewModel(input: input, dependency: dependency)
        view.bind(viewModel)
        
        return view
    }
}
