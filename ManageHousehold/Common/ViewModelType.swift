//
//  ViewModelType.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/10/22.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

protocol ViewModelType {
    associatedtype State
    var state: BehaviorRelay<State> { get }
    var currentState: State { get }
}

extension ViewModelType {
    var currentState: State {
        return state.value
    }
}
