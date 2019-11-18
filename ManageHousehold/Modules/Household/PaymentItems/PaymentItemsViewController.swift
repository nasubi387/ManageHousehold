//
//  PaymentItemsViewController.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/10.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol PaymentItemsWireFrame {
    func presentInputPaymentView(with paymentItem: PaymentItem)
}

class PaymentItemsViewController: UIViewController {
    var viewModel: PaymentItemsViewModel!
    let disposeBag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

extension PaymentItemsViewController {
    func setupView() {
        tableView.register(cellType: PaymentItemTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func bind(_ viewModel: PaymentItemsViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.itemSelected
            .subscribe(onNext: { [weak self] in
                self?.tableView.deselectRow(at: $0, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.sectionModels
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension PaymentItemsViewController: PaymentItemsWireFrame {
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

extension PaymentItemsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.currentStatus.sectionModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentStatus.sectionModels[section].currentStatus.cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = viewModel.currentStatus.sectionModels[indexPath.section].currentStatus.cellModels[indexPath.row]
        let cell = tableView.dequeue(with: PaymentItemTableViewCell.self, for: indexPath)
        cell.bind(cellModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let payment = viewModel.currentStatus.sectionModels[section].currentStatus.payment
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: payment.date)
    }
}

extension PaymentItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
}
