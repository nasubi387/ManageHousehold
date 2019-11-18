//
//  HouseholdViewController.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/01.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HouseholdViewController: UIViewController {
    var viewModel: HouseholdViewModel!
    let disposeBag = DisposeBag()

    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var paymentItemSegmentControl: UISegmentedControl!
    var addButton: UIBarButtonItem!
    
    var pageView: UIPageViewController {
        return children.first as! UIPageViewController
    }
    
    var paymentItemPageView: UIPageViewController {
        return children.last as! UIPageViewController
    }
    
    var headerView: CalenderHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension HouseholdViewController {
    func setupView() {
        addButton = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_add_black_24pt_1x"),
                                    style: .plain,
                                    target: nil,
                                    action: nil)
        navigationItem.rightBarButtonItem = addButton
        guard let width = navigationController?.navigationBar.frame.size.width,
            let height = navigationController?.navigationBar.frame.size.height else {
            return
        }
        headerView = CalenderHeaderView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        navigationItem.titleView = headerView
    }
    
    func bind(_ viewModel: HouseholdViewModel) {
        
        self.viewModel = viewModel
        pageView.dataSource = viewModel
        
        viewModel.output.incomeText
            .bind(to: incomeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.expenseText
            .bind(to: expenseLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.totalText
            .bind(to: totalLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.calenderTitleText
            .bind(to: headerView.CalenderLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.paymentItemPageViewController
            .bind { [weak self] (view, derection) in
                self?.paymentItemPageView.setViewControllers([view],
                                                             direction: derection,
                                                             animated: true)
            }
            .disposed(by: disposeBag)
        
        viewModel.output.initialCalender
            .bind { [weak self] in
                self?.pageView.setViewControllers($0, direction: .forward, animated: false)
            }
            .disposed(by: disposeBag)
    }
}
