//
//  InputPaymentCellViewModel.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/02.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxSwift
import RxCocoa
import RxOptional

class InputPaymentCellViewModel {
    private let disposeBag = DisposeBag()
    private let categoryRepository = CategoryRepository()
    
    private let _paymentItem: BehaviorRelay<PaymentItem>
    var paymentItem: Observable<PaymentItem> {
        return _paymentItem.asObservable()
    }
    private let _categories: BehaviorRelay<[Category]>
    var categories: Observable<[Category]> {
        return _categories.asObservable()
    }

    var titleText: Observable<String?>
    var detailText: Observable<String?>
    
    private let indexPath: IndexPath
    
    var currentStatus: PaymentItem {
        return _paymentItem.value
    }
    
    init(paymentItem: PaymentItem, indexPath: IndexPath) {
        self.indexPath = indexPath
        _paymentItem = BehaviorRelay<PaymentItem>(value: paymentItem)
        _categories = BehaviorRelay<[Category]>(value: [])
        
        let sectionType = InputPaymentSectionType(rawValue: indexPath.section)
        switch sectionType {
        case .price:
            let cellType = InputPaymentPriceCellType(rawValue: indexPath.row)
            titleText = Observable<String?>.just(cellType?.title)
            detailText = _paymentItem
                .map {
                    switch cellType {
                    case .price:
                        return "\($0.price)"
                    default:
                        return nil
                    }
            }
        case .detail:
            let cellType = InputPaymentDetailCellType(rawValue: indexPath.row)
            titleText = Observable<String?>.just(cellType?.title)
            detailText = _paymentItem
                .map {
                switch cellType {
                case .category:
                    return $0.category?.name
                case .name:
                    return $0.name
                case .date:
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd"
                    formatter.locale = Locale(identifier: "ja_JP")
                    return formatter.string(from: $0.date)
                default:
                    return nil
                }
            }
            if cellType == .category {
                fetchCategories()
            }
        default:
            fatalError()
        }
    }
    
    func didChange(_ text: String) {
        let sectionType = InputPaymentSectionType(rawValue: indexPath.section)
        let paymentItem = PaymentItem(value: _paymentItem.value)
        switch sectionType {
        case .price:
            let cellType = InputPaymentPriceCellType(rawValue: indexPath.row)
            switch cellType {
            case .price:
                guard text.isEmpty == false else {
                    paymentItem.price = 0
                    break
                }
                paymentItem.price = Int(text) ?? paymentItem.price
            default:
                break
            }
        case .detail:
            let cellType = InputPaymentDetailCellType(rawValue: indexPath.row)
            switch cellType {
            case .category:
                break
            case .name:
                paymentItem.name = text
            case .date:
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd"
                formatter.locale = Locale(identifier: "ja_JP")
                paymentItem.date = formatter.date(from: text) ?? paymentItem.date
            default:
                break
            }
        default:
            break
        }
        _paymentItem.accept(paymentItem)
    }
    
    func didChange(_ index: Int) {
        let sectionType = InputPaymentSectionType(rawValue: indexPath.section)
        let paymentItem = PaymentItem(value: _paymentItem.value)
        switch sectionType {
        case .detail:
            let cellType = InputPaymentDetailCellType(rawValue: indexPath.row)
            switch cellType {
            case .category:
                paymentItem.category = _categories.value[safe: index]
            default:
                break
            }
        default:
            break
        }
        _paymentItem.accept(paymentItem)
    }
    
    func didChange(_ date: Date) {
        let sectionType = InputPaymentSectionType(rawValue: indexPath.section)
        let paymentItem = PaymentItem(value: _paymentItem.value)
        switch sectionType {
        case .detail:
            let cellType = InputPaymentDetailCellType(rawValue: indexPath.row)
            switch cellType {
            case .date:
                paymentItem.date = date
            default:
                break
            }
        default:
            break
        }
        _paymentItem.accept(paymentItem)
    }
    
    func didChange(_ paymentItemType: PaymentItemType) {
        let paymentItem = PaymentItem(value: _paymentItem.value)
        paymentItem.paymentItemType = paymentItemType
        _paymentItem.accept(paymentItem)
    }
    
    func didChange(_ paymentItem: PaymentItem) {
        _paymentItem.accept(paymentItem)
    }
    
    func fetchCategories() {
        categoryRepository.fetch()
            .bind(to: _categories)
            .disposed(by: disposeBag)
    }
    
    func writeCategory(_ category: Category) {
        let same = _categories.value.first { $0.name == category.name }
        guard same == nil else {
            return
        }
        categoryRepository.update(category)
            .subscribe()
            .disposed(by: disposeBag)
    }
}

