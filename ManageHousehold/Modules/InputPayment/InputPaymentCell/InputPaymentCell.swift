//
//  InputPaymentCell.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/02.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InputPaymentCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailTextField: InputPaymentTextField!
    private let pickerHeight: CGFloat = 210
    private let toolbarHeight: CGFloat = 44
    
    private lazy var datePicker: UIDatePicker = UIDatePicker(frame: CGRect(x: 0, y: 44, width: UIScreen.main.bounds.size.width, height: pickerHeight))
    private var pickerCloseButton: UIBarButtonItem = UIBarButtonItem(title: "閉じる",
                                                                     style: .plain,
                                                                     target: nil,
                                                                     action: nil)
    private lazy var datePickerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: pickerHeight + toolbarHeight))
    private lazy var categoryPicker: UIPickerView = UIPickerView(frame: CGRect(x: 0, y: 44, width: UIScreen.main.bounds.size.width, height: pickerHeight))
    private lazy var categoryPickerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: pickerHeight + toolbarHeight))
    var addCategoyButton: UIBarButtonItem = UIBarButtonItem(title: "追加",
                                                            style: .plain,
                                                            target: nil,
                                                            action: nil)
    
    var viewModel: InputPaymentCellViewModel!
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
}

extension InputPaymentCell {
    func setupView() {
        let datePickerToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: toolbarHeight))
        datePickerToolBar.items = [pickerCloseButton]
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ja_JP")
        datePickerView.addSubview(datePickerToolBar)
        datePickerView.addSubview(datePicker)
        let categoryPickerToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: toolbarHeight))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        categoryPickerToolBar.items = [pickerCloseButton, flexible, addCategoyButton]
        categoryPickerView.addSubview(categoryPickerToolBar)
        categoryPickerView.addSubview(categoryPicker)
    }
    
    func bind(_ viewModel: InputPaymentCellViewModel) {
        self.viewModel = viewModel
        datePicker.setDate(viewModel.currentStatus.date, animated: false)
        detailTextField.rx.text.asObservable()
            .skip(1)
            .distinctUntilChanged()
            .filterNil()
            .bind { [weak self] in
                self?.viewModel.didChange($0)
            }
            .disposed(by: disposeBag)
        detailTextField.rx.editingDidBegin
            .drive(onNext:{ [weak self] in
                self?.setupDetailTextFieldInputView()
            })
            .disposed(by: disposeBag)
        detailTextField.rx.editingDidEnd
            .drive(onNext:{ [weak self] in
                guard self?.detailTextField.isFirstResponder == true else {
                    return
                }
                self?.detailTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        pickerCloseButton.rx.tap
            .subscribe(onNext:{ [weak self] in
                guard self?.detailTextField.isFirstResponder == true else {
                    return
                }
                self?.detailTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        datePicker.rx.date.asObservable()
            .bind { [weak self] in
                self?.viewModel.didChange($0)
            }
            .disposed(by: disposeBag)
        categoryPicker.rx.itemSelected
            .subscribe(onNext: { [weak self] row, _ in
                self?.viewModel.didChange(row)
            })
            .disposed(by: disposeBag)
        addCategoyButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentAddCategoryAlert()
            })
            .disposed(by: disposeBag)
        viewModel.titleText
            .distinctUntilChanged()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.detailText
            .bind(to: detailTextField.rx.text)
            .disposed(by: disposeBag)
        viewModel.categories
            .bind(to: categoryPicker.rx.itemTitles) { _, category in
                return category.name
            }
            .disposed(by: disposeBag)
    }
}

extension InputPaymentCell {
    private func setupDetailTextFieldInputView() {
        guard let indexPath = indexPath,
            let sectionType = InputPaymentSectionType(rawValue: indexPath.section) else {
                return
        }
        switch sectionType {
        case .price:
            let cellType = InputPaymentPriceCellType(rawValue: indexPath.row)
            switch cellType {
            case .price:
                detailTextField.setup(isDisplayCaret: true)
                detailTextField.inputView = nil
            default:
                return
            }
        case .detail:
            let cellType = InputPaymentDetailCellType(rawValue: indexPath.row)
            switch cellType {
            case .category:
                detailTextField.setup(isDisplayCaret: false)
                detailTextField.inputView = categoryPickerView
            case .name:
                detailTextField.setup(isDisplayCaret: true)
                detailTextField.inputView = nil
            case .date:
                detailTextField.setup(isDisplayCaret: false)
                detailTextField.inputView = datePickerView
            default:
                return
            }
        }
    }
    
    private func presentAddCategoryAlert() {
        let alert = UIAlertController(title: nil,
                                      message: "追加するカテゴリを入力してください",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "カテゴリ"
        }
        let addAction = UIAlertAction(title: "追加", style: .default) { [weak self] _ in
            guard let categoryName = alert.textFields?.first?.text else {
                return
            }
            let newCategory = Category(name: categoryName)
            self?.viewModel.writeCategory(newCategory)
            self?.viewModel.fetchCategories()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(alert, animated: true)
    }
}

extension Reactive where Base: UITextField {
    var editingDidBegin: Driver<Void> {
        return base.rx.controlEvent(.editingDidBegin).asDriver()
    }
    
    var editingDidEnd: Driver<Void> {
        return base.rx.controlEvent(.editingDidEnd).asDriver()
    }
}
