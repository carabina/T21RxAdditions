//
//  RxCustomBindings.swift
//  t21_rxadditions_ios
//
//  Created by Eloi Guzmán Cerón on 07/06/2017.
//  Copyright © 2017 Worldline. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

infix operator <->

infix operator =>

//MARK: Bidirectional bindings

func <-> <T>(property: ControlProperty<T>?, variable: Variable<T>) -> Disposable {
    return bidirectionalBinding(property: property, variable: variable)
}

func bidirectionalBinding<T>(property: ControlProperty<T>?, variable: Variable<T>) -> Disposable {
    if let p = property {
        let bindToUIDisposable = variable => p
        let bindToVariable = p.asDriver().asObservable().subscribe(onNext: { n in
            variable.value = n
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })
        return CompositeDisposable(bindToUIDisposable, bindToVariable)
    }
    return Disposables.create()
}

//MARK: Directional binding to ControlProperty

func bindToProperty<T>(variable: Variable<T>, property: ControlProperty<T>?) -> Disposable {
    if let p = property {
        let bindToUIDisposable = variable.asDriver().asObservable().bind(to: p)
        return bindToUIDisposable
    }
    return Disposables.create()
}

func => <T>(variable: Variable<T>, property: ControlProperty<T>?) -> Disposable {
    if let p = property {
        return bindToProperty(variable: variable, property: p)
    }
    return Disposables.create()
}

//MARK: Directional binding to Observer

func bindToObserver<O,T> (variable: Variable<T>, observer: O?, disposeBag: DisposeBag) where O : ObserverType, O.E == T? {
    if let obs = observer {
        variable.asDriver().asObservable().bind(to: obs).disposed(by: disposeBag)
    }
}

func bindToObserver<O,T> (variable: Variable<T>, observer: O?, disposeBag: DisposeBag) where O : ObserverType, O.E == T {
    if let obs = observer {
        variable.asDriver().asObservable().bind(to: obs).disposed(by: disposeBag)
    }
}

func bindToObserver<O,T> (variable: Variable<T>, observer: O?) where O : ObserverType, O.E == T {
    if let obs = observer {
        _ = variable.asDriver().asObservable().bind(to: obs)
    }
}

func bindToObserver<O,T> (variable: Variable<T>, observer: O?) where O : ObserverType, O.E == T? {
    if let obs = observer {
        _ = variable.asDriver().asObservable().bind(to: obs)
    }
}

func => <O,T>(variable: Variable<T>, observer: O?) where O : ObserverType, O.E == T {
    bindToObserver(variable: variable,observer: observer)
}

func => <O,T>(variable: Variable<T>, observer: O?) where O : ObserverType, O.E == T? {
    bindToObserver(variable: variable,observer: observer)
}

//MARK: Directional binding onNext closure

func bindOnNext<T>( _ variable: Variable<T>, _ onNext: @escaping (T) -> (Void)) {
    _ = variable.asDriver().asObservable().bind(onNext: onNext)
}