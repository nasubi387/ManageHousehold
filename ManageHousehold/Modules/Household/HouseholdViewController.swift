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

protocol HouseholdFireframe {
    func presentInputPaymentView(with paymentItem: PaymentItem)
}

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
        
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        
        bind(year: year, month: month)
        
        pageView.dataSource = viewModel
    }
    
    func bind(year: Int, month: Int) {
        let paymentService = PaymentService(year: year, month: month)
        
        let input = HouseholdViewModel.Input(viewDidAppear: self.rx.viewDidAppear,
                                             didChangePageView: pageView.rx.didChangePage,
                                             didChangeItemPageView: paymentItemPageView.rx.didChangePage,
                                             didTapAddButton: addButton.rx.tap.asSignal(),
                                             didChangePaymentItemSegmentControlValue: paymentItemSegmentControl.rx.value)
        
        let dependency = HouseholdViewModel.Dependency(wireframe: self,
                                                       paymentService: BehaviorRelay<PaymentService>(value: paymentService))
        
        let viewModel = HouseholdViewModel(input:input, dependency: dependency)
        
        self.viewModel = viewModel
        
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

extension HouseholdViewController: HouseholdFireframe {
    func presentInputPaymentView(with paymentItem: PaymentItem) {
        guard let navigationController = UIStoryboard(name: InputPaymentViewController.className, bundle: nil).instantiateInitialViewController() as? UINavigationController,
            let view = navigationController.viewControllers.first as? InputPaymentViewController else {
            return
        }
        let viewModel = InputPaymentViewModel(paymentItem: paymentItem)
        view.bind(viewModel)
        present(navigationController, animated: true)
    }
}
