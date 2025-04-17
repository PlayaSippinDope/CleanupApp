//
//  SuccessRouter.swift
//  CleanupApp
//
//  Created by Philip on 14.04.25.
//

import UIKit

final class SuccessRouter: SuccessRouterProtocol {
    weak var viewController: UIViewController?

    func close() {
        viewController?.navigationController?.popToRootViewController(animated: true)
    }
}

