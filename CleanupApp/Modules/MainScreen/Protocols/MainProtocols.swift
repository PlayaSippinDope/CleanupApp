//
//  MainProtocols.swift
//  CleanupApp
//
//  Created by Philip on 14.04.25.
//

import Foundation

protocol MainViewInput: AnyObject {}
protocol MainViewOutput: AnyObject {
    func viewDidLoad()
}

protocol MainInteractorInput: AnyObject {}
protocol MainInteractorOutput: AnyObject {}

protocol MainRouterInput: AnyObject {}
