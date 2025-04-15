//
//  MainScreenModuleAssembly.swift
//  CleanupApp
//
//  Created by Philip on 15.04.25.
//

// PhotoCleaner/Modules/MainScreen/MainScreenModuleAssembly.swift

import UIKit

enum MainScreenModuleAssembly {
    static func create() -> UIViewController {
        let view = MainViewController()
        let presenter = MainPresenter()
        let interactor = MainInteractor()
        let router = MainRouter()

        view.presenter = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router

        interactor.output = presenter
        router.viewController = view

        return view
    }
}
