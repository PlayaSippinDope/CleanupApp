//
//  MainPresenter.swift
//  CleanupApp
//
//  Created by Philip on 14.04.25.
//

final class MainPresenter {
    weak var view: MainViewInput?
    var interactor: MainInteractorInput?
    var router: MainRouterInput?
}

extension MainPresenter: MainViewOutput {
    func viewDidLoad() {
    }
}

extension MainPresenter: MainInteractorOutput {
}
