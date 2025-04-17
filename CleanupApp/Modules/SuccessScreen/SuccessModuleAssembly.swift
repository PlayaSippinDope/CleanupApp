//
//  SuccessModuleAssembly.swift
//  CleanupApp
//
//  Created by Philip on 16.04.25.
//

import UIKit

enum SuccessModuleAssembly {
    static func create(deletedCount: Int, freedMB: Double) -> UIViewController {
        let view = SuccessViewController()
        let presenter = SuccessPresenter()
        let interactor = SuccessInteractor()
        let router = SuccessRouter()

        view.presenter = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router

        router.viewController = view

        view.configure(deletedCount: deletedCount, freedMB: freedMB)

        return view
    }
}
