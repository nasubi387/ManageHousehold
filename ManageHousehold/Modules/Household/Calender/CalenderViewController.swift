//
//  CalenderViewController.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/20.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol CalenderFireframe {
    
}

class CalenderViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var viewModel: CalenderViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

extension CalenderViewController {
    func setupView() {
        collectionView.register(cellType: CalenderCell.self)
        collectionView.register(cellType: WeekdayCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
    }
    
    func bind(_ viewModel: CalenderViewModel) {
        self.viewModel = viewModel
        viewModel.cellModels
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension CalenderViewController: CalenderFireframe {
    
}

extension CalenderViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section != 0 else {
            return Weekday.allCases.count
        }
        return viewModel.currentStatus.cellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.section != 0 else {
            let cell = collectionView.dequeue(with: WeekdayCell.self, for: indexPath)
            cell.setup(with: Weekday(rawValue: indexPath.row)!)
            return cell
        }
        let cell = collectionView.dequeue(with: CalenderCell.self, for: indexPath)
        cell.bind(viewModel.currentStatus.cellModels[indexPath.row])
        return cell
    }
}

extension CalenderViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = view.frame.width / 7
        guard indexPath.section != 0 else {
            return CGSize(width: size, height: 25)
        }
        return CGSize(width: size, height: 50)
    }
}

extension Reactive where Base: CalenderViewController {
    var itemSelected: ControlEvent<Date> {
        let source = base.collectionView.rx.itemSelected
            .map { [weak base] indexPath in
                base?.viewModel.currentStatus.cellModels[safe: indexPath.row]?.currentStatus.date
            }
            .filterNil()
        return ControlEvent(events: source)
    }
}
