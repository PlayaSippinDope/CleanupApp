//
//  MainScreenModuleAssembly.swift
//  CleanupApp
//
//  Created by Philip on 15.04.25.
//

import UIKit

enum MainScreenModuleAssembly {
    static func create() -> UIViewController {
        let photoService = PhotoLibraryService()
        
        let view = MainViewController()
        let presenter = MainPresenter()
        let interactor = MainInteractor(photoService: photoService)
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
