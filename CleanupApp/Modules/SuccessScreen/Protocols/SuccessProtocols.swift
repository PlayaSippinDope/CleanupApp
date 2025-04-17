//
//  SuccessProtocols.swift
//  CleanupApp
//
//  Created by Philip on 14.04.25.
//

protocol SuccessViewProtocol: AnyObject {
    func update(with viewModel: SuccessModel)
}

protocol SuccessPresenterProtocol: AnyObject {
    func configure(deletedCount: Int, freedMB: Double)
    func viewDidLoad()
    func didTapGreat()
}

protocol SuccessInteractorProtocol: AnyObject {
}

protocol SuccessRouterProtocol: AnyObject {
    func close()
}
