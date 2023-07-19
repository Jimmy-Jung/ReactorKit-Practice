//
//  FirstViewReactor.swift
//  ReactorKit Practice1
//
//  Created by 정준영 on 2023/07/18.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit

class FirstViewReactor: Reactor {
    let initialState = State()
    
    enum Action {
        case increase
        case decrease
    }
    
    enum Mutation {
        case increaseValue
        case decreaseValue
        case setLoading(Bool)
    }
    
    struct State {
        var value = 0
        var isLoading = false
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .increase:
            return Observable.concat([
                Observable.just(.setLoading(true)),
                Observable.just(.increaseValue)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                Observable.just(.setLoading(false))
            ])
        case .decrease:
            return Observable.concat([
                Observable.just(.setLoading(true)),
                Observable.just(.decreaseValue)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                Observable.just(.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .increaseValue:
            newState.value += 1
        case .decreaseValue:
            newState.value -= 1
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }
        return newState
    }
    
    
    
}
