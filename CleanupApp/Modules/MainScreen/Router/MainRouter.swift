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

        guard let navigationController = viewController?.navigationController else { return }
        
        UIView.transition(with: navigationController.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            navigationController.pushViewController(vc, animated: false)
        }, completion: nil)
    }
}

extension MainRouter {
    // MARK: - Full Screen Navigation
    func openFullScreenPhoto(asset: PHAsset) {
        let fullScreenVC = FullScreenPhotoViewController(asset: asset)
        fullScreenVC.modalPresentationStyle = .fullScreen
        viewController?.present(fullScreenVC, animated: true)
    }
}
