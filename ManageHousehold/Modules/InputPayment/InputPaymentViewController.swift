//
//  InputPaymentViewController.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/27.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InputPaymentViewController: UIViewController {
    var viewModel: InputPaymentViewModel!
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var paymentSegmentControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    
    var closeButton: UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_close_black_36pt_1x"),
                                                       style: .plain,
                                                       target: nil,
                                                       action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presentingViewController?.beginAppearanceTransition(false, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentingViewController?.endAppearanceTransition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.beginAppearanceTransition(true, animated: animated)
        presentingViewController?.endAppearanceTransition()
    }
}

extension InputPaymentViewController {
    
    func setupView() {
        tableView.register(cellType: InputPaymentCell.self)
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = UIColor.systemGroupedBackground
        }
        tableView.dataSource = self
        closeButton.tintColor = UIColor.systemGray
        navigationItem.rightBarButtonItems = [closeButton]
    }
    
    func bind(_ viewModel: InputPaymentViewModel) {
        self.viewModel = viewModel
        let gesture = UITapGestureRecognizer()
        view.addGestureRecognizer(gesture)
        gesture.rx.event.asDriver()
            .drive(onNext: { [weak self] event in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        paymentSegmentControl.rx.value.asDriver()
            .skip(1)
            .drive(onNext: {
                viewModel.didChange($0)
            })
            .disposed(by: disposeBag)
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.writePaymentItem()
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        viewModel.segmentControl
            .bind(to: paymentSegmentControl.rx.value)
            .disposed(by: disposeBag)
        viewModel.paymentItem
            .distinctUntilChanged()
            .bind { [weak self] in
                self?.viewModel.didChange($0)
            }
            .disposed(by: disposeBag)
    }
}

extension InputPaymentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return InputPaymentSectionType(rawValue: section)?.cellCount ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return InputPaymentSectionType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(with: InputPaymentCell.self, for: indexPath)
        let viewModel = self.viewModel.currentStatus.cellModels[indexPath.section + indexPath.row]
        cell.bind(viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return InputPaymentSectionType(rawValue: section)?.title
    }
}

