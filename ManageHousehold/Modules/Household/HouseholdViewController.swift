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
    
    lazy var paymentItemViewControllers: [UIViewController] = {
        let paymentItems = UIStoryboard(name: PaymentItemsViewController.className, bundle: nil).instantiateInitialViewController() as! PaymentItemsViewController
        _ = paymentItems.view
        paymentItems.bind(self.viewModel.currentStatus.paymentItemsViewModel)
        
        let lineGraph = UIStoryboard(name: LineGraphViewController.className, bundle: nil).instantiateInitialViewController() as! LineGraphViewController
        _ = lineGraph.view
        lineGraph.bind(self.viewModel.currentStatus.lineGraphViewModel)
        
        return [paymentItems, lineGraph]
    }()
    
    var headerView: CalenderHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetchPayments()
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
        
        let cuerrentDate = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: cuerrentDate)
        let month = calendar.component(.month, from: cuerrentDate)
        
        let paymentService = PaymentService(year: year, month: month)
        let viewModel = HouseholdViewModel(paymentService: paymentService)
        bind(viewModel)
        
        guard let view = getCalenderViewController(year: year, month: month) else {
            return
        }
        viewModel.update(view.viewModel)
        pageView.dataSource = self
        pageView.setViewControllers([view], direction: .forward, animated: false)
        paymentItemPageView.setViewControllers([paymentItemViewControllers[0]], direction: .forward, animated: false)
    }
    
    func bind(_ viewModel: HouseholdViewModel) {
        self.viewModel = viewModel
        
        pageView.rx.didChangePage
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] nextView in
                guard let viewModel = (nextView as? CalenderViewController)?.viewModel else { return }
                self?.viewModel.update(viewModel)
            })
            .disposed(by: disposeBag)
        
        paymentItemPageView.rx.didChangePage
            .distinctUntilChanged()
            .map { [weak self] in
                self?.paymentItemViewControllers.firstIndex(of: $0)
            }
            .filterNil()
            .bind(to: paymentItemSegmentControl.rx.value)
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let paymentItem = PaymentItem(date: Date())
                self?.presentInputPaymentView(with: paymentItem)
            })
            .disposed(by: disposeBag)
        
        paymentItemSegmentControl.rx.value.asDriver()
            .skip(1)
            .drive(onNext: { [weak self] destIndex in
                guard
                    let currentView = self?.paymentItemPageView.viewControllers?.first,
                    let currentIndex = self?.paymentItemViewControllers.firstIndex(of: currentView),
                    let destView = self?.paymentItemViewControllers[safe: destIndex] else {
                        return
                }
                self?.paymentItemPageView.setViewControllers([destView],
                                                             direction: currentIndex < destIndex ? .forward : .reverse,
                                                             animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.incomeText
            .bind(to: incomeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.expenseText
            .bind(to: expenseLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.totalText
            .bind(to: totalLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.calenderTitleText
            .bind(to: headerView.CalenderLabel.rx.text)
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
    
    private func getPaymentItemPageViewController(current: UIViewController, diff: Int) -> UIViewController? {
        guard let currentIndex = paymentItemViewControllers.firstIndex(of: current) else {
            return nil
        }
        return paymentItemViewControllers[safe: currentIndex + diff]
    }
    
    private func presentInputPaymentView(with paymentItem: PaymentItem) {
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
            return getPaymentItemPageViewController(current: viewController, diff: -1)
        }
        return getCalenderViewController(year: viewModel.currentStatus.year, month: viewModel.currentStatus.month - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard pageViewController == pageView else {
            return getPaymentItemPageViewController(current: viewController, diff: 1)
        }
        return getCalenderViewController(year: viewModel.currentStatus.year, month: viewModel.currentStatus.month + 1)
    }
}
