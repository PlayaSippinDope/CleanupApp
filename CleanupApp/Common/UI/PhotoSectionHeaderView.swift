//
//  PhotoSectionHeaderView.swift
//  CleanupApp
//
//  Created by Philip on 15.04.25.
//

import UIKit

protocol PhotoSectionHeaderViewDelegate: AnyObject {
    func didTapSelectAll(in section: Int)
}

final class PhotoSectionHeaderView: UICollectionReusableView {
    static let reuseId = "PhotoSectionHeaderView"

    private let titleLabel = UILabel()
    private let toggleButton = UIButton(type: .system)

    var onToggleSelection: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.font = .boldSystemFont(ofSize: 22)
        toggleButton.titleLabel?.font = .systemFont(ofSize: 14)
        toggleButton.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, toggleButton])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func toggleButtonTapped() {
        onToggleSelection?()
    }
    
    func configure(similarCount: Int, isAllSelected: Bool) {
        titleLabel.text = "\(similarCount) Similar"
        
        let newTitle = isAllSelected ? "Deselect all" : "Select all"
        
        UIView.animate(withDuration: 0.1, animations: {
            self.toggleButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.transition(with: self.toggleButton,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: {
                self.toggleButton.setTitle(newTitle, for: .normal)
            }, completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.toggleButton.transform = .identity
                }
            })
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
