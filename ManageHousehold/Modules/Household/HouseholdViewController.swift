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
        
        guard let view = getCalenderViewController(year: year, month: month) else {
            return
        }
        viewModel.update(view.viewModel)
        pageView.dataSource = self
        pageView.setViewControllers([view], direction: .forward, animated: false)
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
    }
}

extension HouseholdViewController {
    private func getCalenderViewController(year: Int, month: Int) -> CalenderViewController? {
        guard let view = UIStoryboard(name: CalenderViewController.className, bundle: nil).instantiateInitialViewController() as? CalenderViewController else {
            return nil
        }
        _ = view.view
        view.page.year = year
        view.page.month = month
        let paymentService = PaymentService(year: year, month: month)
        let viewModel = CalenderViewModel(paymentService: paymentService)
        view.bind(viewModel)
        view.rx.itemSelected
            .bind{ [weak self] date in
                guard let self = self else { return }
                
                let calendar = Calendar.current
                guard calendar.component(.year, from: date) == self.viewModel.currentStatus.year
                    && calendar.component(.month, from: date) == self.viewModel.currentStatus.month else {
                    return
                }
                let paymentItem = PaymentItem(date: date)
                self.presentInputPaymentView(with: paymentItem)
            }
            .disposed(by: view.disposeBag)
        return view
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

extension HouseholdViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard pageViewController == pageView else {
            return nil
        }
        return getCalenderViewController(year: viewModel.currentStatus.year, month: viewModel.currentStatus.month - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard pageViewController == pageView else {
            return nil
        }
        return getCalenderViewController(year: viewModel.currentStatus.year, month: viewModel.currentStatus.month + 1)
    }
}
