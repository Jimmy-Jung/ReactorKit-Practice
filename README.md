# ReactorKit-Practice
ReactorKit + RxSwift 기능 학습

# 👉 ReactorKit 개념

ReactorKit은 RxSwift를 기반으로 한 iOS 애플리케이션 아키텍처 패턴 중 하나로, View, ViewModel, Reactor로 구성됩니다.

이 패턴은 모든 사용자 입력과 시스템 입력에 대한 반응을 제공하며, 뷰와 상태 사이의 강력한 연결을 제공합니다.

이 패턴은 또한 깨끗하고 모듈화 된 코드를 작성할 수 있도록합니다.

## ReactorKit을 사용하는 이유

ReactorKit은 뷰와 뷰모델 사이의 결합도를 줄이고 코드를 모듈화하여 작성할 수 있도록 함으로써 애플리케이션의 구조를 단순화시킵니다. 

또한 리액티브 프로그래밍을 사용하므로 코드의 가독성과 유지 보수성이 향상되며, 비즈니스 로직을 명확하게 분리할 수 있습니다.

ReactorKit은 뷰모델과 리액터의 분리로 인해 뷰와 뷰모델 사이의 결합도를 낮춥니다. 

이를 통해 뷰와 뷰모델을 각각 단일 책임 원칙(Single Responsibility Principle)에 따라 분리한 후, 코드를 모듈화하여 작성할 수 있습니다. 

이는 애플리케이션의 구조를 단순화시키고, 확장성과 유지 보수성을 향상시킵니다.

또한, 리액티브 프로그래밍을 사용하므로, 코드의 가독성과 유지 보수성이 향상됩니다. 

비동기적으로 처리되는 이벤트를 쉽게 처리할 수 있고, 코드 중복을 줄일 수 있습니다. 

이를 통해 코드의 생산성을 향상시킬 수 있습니다.

또한, ReactorKit은 비즈니스 로직을 명확하게 분리할 수 있습니다. 

뷰모델은 뷰에서 전달받은 이벤트를 처리하는 역할만 하고, 비즈니스 로직은 리액터에서 처리합니다. 

이를 통해 코드를 더욱 깔끔하게 작성할 수 있습니다.

## ReactorKit의 장단점

장점:

- 코드의 모듈화 및 재사용성을 높입니다.
- 뷰와 뷰모델 사이의 결합도를 줄입니다.
- 비즈니스 로직을 명확하게 분리할 수 있습니다.
- 뷰모델을 통한 테스트가 용이합니다.

단점:

- RxSwift에 대한 이해도가 필요합니다.
- 처음에는 러닝커브가 있습니다.

---
# 기본 예제 학습

<img width="558" alt="image" src="https://github.com/Jimmy-Jung/ReactorKit-Practice/assets/115251866/fd55ca48-f9cf-4fe3-aeca-a008a99f1065">
<img width="300" alt="image" src="https://github.com/Jimmy-Jung/ReactorKit-Practice/assets/115251866/956da8b9-0975-4008-8be5-c143ca04f76f">

   

## View
View는 UI를 담당하며, Reactor로부터 Action을 받아서 UI 이벤트를 구동하고, Reactor의 State를 구독하여 UI를 업데이트합니다.

View에서 Reactor로 이벤트를 전달하는 방법은 bindAction(*:), Reactor에서 상태를 구독하는 방법은 bindState(*:) 입니다.

ReactorKit에서는 View를 구현하는 방법으로 StoryboardView와 CodeView 두 가지가 있습니다. 

StoryboardView는 스토리보드를 이용하여 UI를 구현하는 방법이며, CodeView는 코드를 이용하여 UI를 구현하는 방법입니다.

```swift
import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class ViewController: UIViewController, StoryboardView {

    var disposeBag = DisposeBag()
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var decreaseButton: UIButton!
    @IBOutlet weak var increaseButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    func bind(reactor: ViewReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    func bindAction(_ reactor: ViewReactor) {
        increaseButton.rx.tap
            .map { Reactor.Action.increase }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        decreaseButton.rx.tap
            .map { Reactor.Action.decrease }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: ViewReactor) {
        reactor.state
            .map { String($0.value) }
            .distinctUntilChanged() // 중복값 무시
            .bind(to: textLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reactor = ViewReactor()
    }

    
}
```

## Reactor
Reactor는 비즈니스 로직을 담당하며, View에서 전달된 Action을 받아서 State를 업데이트하고, 변경된 State를 View에 전달합니다.

Reactor는 크게 Action, Mutation, State 세 가지로 구성됩니다.

- **Action**
    - View에서 전달된 이벤트를 enum 형태로 정의합니다.
- **Mutation**
    - Action을 받아서 해야 할 작업 단위들을 enum 형태로 정의합니다.
- **State**
    - 현재 상태를 저장하고, View에서 해당 정보를 사용하여 UI를 업데이트합니다.

Reactor에서 mutate(action:) 함수를 통해 Action을 받으면, Mutation에서 정의한 작업 단위들을 사용하여 Observable로 방출합니다. 

이 때, RxSwift의 concat 연산자를 이용하여 비동기 처리를 유용하게 할 수 있습니다.

마지막으로, reduce(state:mutation:) 함수를 통해 현재 상태와 작업 단위를 받아 최종 상태를 반환합니다. 

이 함수는 mutate(action:) -> Observable<Mutation>이 실행된 후 바로 실행됩니다.

```swift
import Foundation
import RxSwift
import RxCocoa
import ReactorKit

class ViewReactor: Reactor {
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
```



