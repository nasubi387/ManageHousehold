//
//  UIPageViewControllerDelegate+Rx.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/22.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

extension UIPageViewController: HasDelegate {
    public typealias Delegate = UIPageViewControllerDelegate
}

class RxPageViewControllerDelegateProxy: DelegateProxy<UIPageViewController, UIPageViewControllerDelegate>, DelegateProxyType, UIPageViewControllerDelegate {
    internal lazy var didChangePageSubject = PublishSubject<UIViewController>()
    
    init(with pageView: UIPageViewController) {
        super.init(parentObject: pageView, delegateProxy: RxPageViewControllerDelegateProxy.self)
    }
    
    deinit {
        didChangePageSubject.onCompleted()
    }
    static func registerKnownImplementations() {
        register { RxPageViewControllerDelegateProxy(with: $0) }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed == true, let currentViewController = pageViewController.viewControllers?.first else {
            return
        }
        didChangePageSubject.onNext(currentViewController)
    }
}

extension Reactive where Base: UIPageViewController {
    var didChangePage: Observable<UIViewController> {
        return RxPageViewControllerDelegateProxy.proxy(for: base).didChangePageSubject.asObserver()
    }
}
