//
//  MainRouter.swift
//  CleanupApp
//
//  Created by Philip on 14.04.25.
//

import UIKit
import Photos

final class MainRouter: MainRouterInput {
    weak var viewController: UIViewController?

    func showSuccessScreen(deletedCount: Int, freedMB: Double) {
        let vc = SuccessModuleAssembly.create(deletedCount: deletedCount, freedMB: freedMB)
        viewController?.navigationController?.pushViewController(vc, animated: true)

    }
}

extension MainRouter {
    func navigateToSuccessScreen(deletedCount: Int) {
        let successVC = SuccessViewController()
        viewController?.present(successVC, animated: true)
    }
    
    func openFullScreenPhoto(asset: PHAsset) {
        let fullScreenVC = FullScreenPhotoViewController(asset: asset)
        fullScreenVC.modalPresentationStyle = .fullScreen
        viewController?.present(fullScreenVC, animated: true)
    }
}
