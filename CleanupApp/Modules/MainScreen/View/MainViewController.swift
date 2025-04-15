//
//  MainViewController.swift
//  CleanupApp
//
//  Created by Philip on 14.04.25.
//

import UIKit

final class MainViewController: UIViewController, MainViewInput {
    var presenter: MainViewOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        presenter?.viewDidLoad()

        let label = UILabel()
        label.text = "Main Screen"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
