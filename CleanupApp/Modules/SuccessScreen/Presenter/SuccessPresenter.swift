//
//  SuccessPresenter.swift
//  CleanupApp
//
//  Created by Philip on 14.04.25.
//

import Foundation

struct SuccessModel {
    let deletedCount: Int
    let freedMB: Double
}

final class SuccessPresenter: SuccessPresenterProtocol {
    weak var view: SuccessViewProtocol?
    var interactor: SuccessInteractorProtocol!
    var router: SuccessRouterProtocol!

    private var deletedCount: Int = 0
    private var freedMB: Double = 0

    func configure(deletedCount: Int, freedMB: Double) {
        self.deletedCount = deletedCount
        self.freedMB = freedMB
    }

    func viewDidLoad() {
        let model = SuccessModel(deletedCount: deletedCount, freedMB: freedMB)
        view?.update(with: model)
    }

    func didTapGreat() {
        router.close()
    }
}
