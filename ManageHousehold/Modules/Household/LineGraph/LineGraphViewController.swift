//
//  LineGraphViewController.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/14.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LineGraphViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private var viewModel: LineGraphViewModel!
    
    @IBOutlet weak var graphView: GraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension LineGraphViewController {
    func bind(_ viewModel: LineGraphViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.payments
            .bind { [weak self] in
                self?.graphView.update(with: $0)
            }
            .disposed(by: disposeBag)
    }
}
