//
//  ViewController.swift
//  ReactorKit Practice1
//
//  Created by 정준영 on 2023/07/18.
//

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
    
    func bind(reactor: FirstViewReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    func bindAction(_ reactor: FirstViewReactor) {
        increaseButton.rx.tap
            .map { Reactor.Action.increase }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        decreaseButton.rx.tap
            .map { Reactor.Action.decrease }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: FirstViewReactor) {
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
        reactor = FirstViewReactor()
    }

    
}

