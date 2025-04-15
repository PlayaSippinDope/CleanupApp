//
//  AppAssembly.swift
//  CleanupApp
//
//  Created by Philip on 14.04.25.
//

import UIKit

final class AppAssembly {
    static func makeMainScreen() -> UIViewController {
        return MainScreenModuleAssembly.create()
    }
}
