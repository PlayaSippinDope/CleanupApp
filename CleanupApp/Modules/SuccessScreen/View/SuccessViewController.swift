//
//  SuccessViewController.swift
//  CleanupApp
//
//  Created by Philip on 14.04.25.
//

import UIKit

import UIKit

final class SuccessViewController: UIViewController, SuccessViewProtocol {
    var presenter: SuccessPresenterProtocol!

    // MARK: - UI Components
    private let celebrationImageView = UIImageView()
    private let congratsLabel = UILabel()
    private let deletedLabel = UILabel()
    private let savedLabel = UILabel()
    private let infoLabel = UILabel()
    private let button = UIButton(type: .system)
    private let starsImageView = UIImageView()
    private let clockImageView = UIImageView()
    private let subtitleStack = UIStackView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true

        setupSubviews()
        setupLayout()
        presenter.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        button.layer.cornerRadius = button.frame.height / 2
    }

    // MARK: - Public
    func configure(deletedCount: Int, freedMB: Double) {
        presenter.configure(deletedCount: deletedCount, freedMB: freedMB)
    }

    func update(with model: SuccessModel) {
        deletedLabel.attributedText = makeAttributed([
            ("\(model.deletedCount) Photos ", .systemBlue, .systemFont(ofSize: 20, weight: .semibold)),
            ("(\(String(format: "%.1f", model.freedMB)) MB)", .label, .systemFont(ofSize: 20))
        ])

        savedLabel.attributedText = makeAttributed([
            ("Saved ", .label, .systemFont(ofSize: 20)),
            ("10 Minutes", .systemBlue, .systemFont(ofSize: 20, weight: .semibold))
        ])
    }

    // MARK: - Setup
    private func setupSubviews() {
        // Image
        celebrationImageView.image = UIImage(named: "celebration")
        celebrationImageView.contentMode = .scaleAspectFit

        // Congrats Label
        congratsLabel.text = "Congratulations!"
        congratsLabel.font = .boldSystemFont(ofSize: 32)
        congratsLabel.textAlignment = .center

        // Deleted Label Stack
        let deletedTitle = makeLabel(text: "You have deleted", alignment: .center)
        deletedLabel.textAlignment = .center
        deletedLabel.numberOfLines = 0

        starsImageView.image = UIImage(named: "stars")
        starsImageView.contentMode = .scaleAspectFit
        starsImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            starsImageView.heightAnchor.constraint(equalToConstant: 48),
            starsImageView.widthAnchor.constraint(equalTo: starsImageView.heightAnchor)
        ])

        let titleTextStack = UIStackView(arrangedSubviews: [deletedTitle, deletedLabel])
        titleTextStack.axis = .vertical
        titleTextStack.spacing = 2
        titleTextStack.alignment = .leading

        let titleStack = UIStackView(arrangedSubviews: [starsImageView, titleTextStack])
        titleStack.axis = .horizontal
        titleStack.spacing = 8
        titleStack.alignment = .center

        // Saved Label Stack
        savedLabel.textAlignment = .center
        savedLabel.numberOfLines = 1

        let savedSubtitle = makeLabel(text: "using Cleanup", alignment: .center)

        clockImageView.image = UIImage(named: "hourglass")
        clockImageView.contentMode = .scaleAspectFit
        clockImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clockImageView.heightAnchor.constraint(equalToConstant: 48),
            clockImageView.widthAnchor.constraint(equalTo: clockImageView.heightAnchor)
        ])

        let subtitleTextStack = UIStackView(arrangedSubviews: [savedLabel, savedSubtitle])
        subtitleTextStack.axis = .vertical
        subtitleTextStack.spacing = 2
        subtitleTextStack.alignment = .leading

        subtitleStack.axis = .horizontal
        subtitleStack.spacing = 6
        subtitleStack.alignment = .center
        subtitleStack.addArrangedSubview(clockImageView)
        subtitleStack.addArrangedSubview(subtitleTextStack)

        // Info Label
        infoLabel.font = .systemFont(ofSize: 14)
        infoLabel.textColor = .secondaryLabel
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        infoLabel.text = "Review all your videos. Sort them by size or date.\nSee the ones that occupy the most space."

        // Button
        var config = UIButton.Configuration.filled()
        config.title = "Great"
        config.baseForegroundColor = .white
        config.background.backgroundColor = .systemBlue
        config.cornerStyle = .capsule
        config.attributedTitle = AttributedString("Great", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 20, weight: .medium)
        ]))
        button.configuration = config
        button.addTarget(self, action: #selector(didTapGreat), for: .touchUpInside)

        // Add subviews
        view.addSubview(button)

        let stack = UIStackView(arrangedSubviews: [
            celebrationImageView,
            congratsLabel,
            titleStack,
            subtitleStack,
            infoLabel
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        // Constraints
        NSLayoutConstraint.activate([
            celebrationImageView.heightAnchor.constraint(equalToConstant: 280),
            celebrationImageView.widthAnchor.constraint(equalTo: celebrationImageView.heightAnchor),

            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            button.heightAnchor.constraint(equalToConstant: 60),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }

    private func setupLayout() {
        celebrationImageView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Helpers
    private func makeLabel(text: String? = nil, font: UIFont = .systemFont(ofSize: 20), color: UIColor = .label, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.textAlignment = alignment
        return label
    }

    private func makeAttributed(_ parts: [(String, UIColor, UIFont)]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        parts.forEach { string, color, font in
            result.append(NSAttributedString(string: string, attributes: [
                .foregroundColor: color,
                .font: font
            ]))
        }
        return result
    }

    // MARK: - Actions
    @objc private func didTapGreat() {
        presenter.didTapGreat()
    }
}
