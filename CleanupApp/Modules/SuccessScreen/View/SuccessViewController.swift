//
//  SuccessViewController.swift
//  CleanupApp
//
//  Created by Philip on 14.04.25.
//

import UIKit

final class SuccessViewController: UIViewController {

    // MARK: - Public Properties

    var presenter: SuccessPresenterProtocol!

    // MARK: - UI Components

    private let celebrationImageView = UIImageView()
    private let congratsLabel = UILabel()
    private let deletedLabel = UILabel()
    private let deletedTitleLabel = UILabel()
    private let starsImageView = UIImageView()

    private let savedLabel = UILabel()
    private let savedSubtitleLabel = UILabel()
    private let clockImageView = UIImageView()
    private let subtitleStack = UIStackView()

    private let infoLabel = UILabel()
    private let button = UIButton(type: .system)

    private let stackView = UIStackView()

    private var viewsToAnimate: [UIView] {
        [
            celebrationImageView,
            congratsLabel,
            starsImageView,
            deletedTitleLabel,
            deletedLabel,
            clockImageView,
            savedLabel,
            savedSubtitleLabel,
            infoLabel,
            button
        ]
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true

        setupSubviews()
        setupConstraints()
        presenter.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // .capsule уже используется, это можно опустить
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareForAnimation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateAppearance()
    }

    // MARK: - Animation

    private func prepareForAnimation() {
        viewsToAnimate.forEach {
            $0.alpha = 0
            $0.transform = CGAffineTransform(translationX: 0, y: SuccessConstants.animationOffsetY)
        }
    }

    private func animateAppearance() {
        for (index, view) in viewsToAnimate.enumerated() {
            UIView.animate(
                withDuration: SuccessConstants.animationDuration,
                delay: Double(index) * SuccessConstants.animationStagger,
                options: [.curveEaseInOut],
                animations: {
                    view.alpha = 1
                    view.transform = .identity
                }
            )
        }
    }

    // MARK: - UI Setup

    private func setupSubviews() {
        setupImages()
        setupLabels()
        setupButton()
        setupStackView()
        view.addSubview(stackView)
        view.addSubview(button)
    }

    private func setupConstraints() {
        celebrationImageView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            celebrationImageView.heightAnchor.constraint(equalToConstant: SuccessConstants.celebrationImageSize),
            celebrationImageView.widthAnchor.constraint(equalTo: celebrationImageView.heightAnchor),

            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: SuccessConstants.stackSidePadding),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -SuccessConstants.stackSidePadding),

            button.heightAnchor.constraint(equalToConstant: SuccessConstants.buttonHeight),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SuccessConstants.buttonSideInset),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SuccessConstants.buttonSideInset),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -SuccessConstants.buttonBottomInset)
        ])
    }

    private func setupImages() {
        celebrationImageView.image = UIImage(named: "celebration")
        celebrationImageView.contentMode = .scaleAspectFit

        starsImageView.image = UIImage(named: "stars")
        starsImageView.contentMode = .scaleAspectFit

        clockImageView.image = UIImage(named: "hourglass")
        clockImageView.contentMode = .scaleAspectFit

        [starsImageView, clockImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: SuccessConstants.iconSize),
                $0.widthAnchor.constraint(equalTo: $0.heightAnchor)
            ])
        }
    }

    private func setupLabels() {
        congratsLabel.text = "Congratulations!"
        congratsLabel.font = .boldSystemFont(ofSize: SuccessConstants.congratsFontSize)
        congratsLabel.textAlignment = .center

        deletedTitleLabel.text = "You have deleted"
        deletedTitleLabel.font = .systemFont(ofSize: SuccessConstants.secondaryFontSize)
        deletedTitleLabel.textColor = .label
        deletedTitleLabel.textAlignment = .center

        deletedLabel.textAlignment = .center
        deletedLabel.numberOfLines = 0

        savedLabel.textAlignment = .center
        savedLabel.numberOfLines = 1

        savedSubtitleLabel.text = "using Cleanup"
        savedSubtitleLabel.font = .systemFont(ofSize: SuccessConstants.secondaryFontSize)
        savedSubtitleLabel.textColor = .label
        savedSubtitleLabel.textAlignment = .center

        infoLabel.text = "Review all your videos. Sort them by size or date.\nSee the ones that occupy the most space."
        infoLabel.font = .systemFont(ofSize: SuccessConstants.infoFontSize)
        infoLabel.textColor = .secondaryLabel
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
    }

    private func setupButton() {
        var config = UIButton.Configuration.filled()
        config.title = "Great"
        config.baseForegroundColor = .white
        config.background.backgroundColor = .systemBlue
        config.cornerStyle = .capsule
        config.attributedTitle = AttributedString("Great", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: SuccessConstants.buttonFontSize, weight: .medium)
        ]))
        button.configuration = config
        button.addTarget(self, action: #selector(didTapGreat), for: .touchUpInside)
    }

    private func setupStackView() {
        let deletedTextStack = UIStackView(arrangedSubviews: [deletedTitleLabel, deletedLabel])
        deletedTextStack.axis = .vertical
        deletedTextStack.spacing = SuccessConstants.labelStackSpacing
        deletedTextStack.alignment = .leading

        let deletedStack = UIStackView(arrangedSubviews: [starsImageView, deletedTextStack])
        deletedStack.axis = .horizontal
        deletedStack.spacing = SuccessConstants.horizontalSpacing
        deletedStack.alignment = .center

        let savedTextStack = UIStackView(arrangedSubviews: [savedLabel, savedSubtitleLabel])
        savedTextStack.axis = .vertical
        savedTextStack.spacing = SuccessConstants.labelStackSpacing
        savedTextStack.alignment = .leading

        subtitleStack.axis = .horizontal
        subtitleStack.spacing = SuccessConstants.horizontalSpacing
        subtitleStack.alignment = .center
        subtitleStack.addArrangedSubview(clockImageView)
        subtitleStack.addArrangedSubview(savedTextStack)

        stackView.axis = .vertical
        stackView.spacing = SuccessConstants.stackSpacing
        stackView.alignment = .center

        stackView.addArrangedSubview(celebrationImageView)
        stackView.addArrangedSubview(congratsLabel)
        stackView.addArrangedSubview(deletedStack)
        stackView.addArrangedSubview(subtitleStack)
        stackView.addArrangedSubview(infoLabel)
    }

    // MARK: - Actions

    @objc private func didTapGreat() {
        presenter.didTapGreat()
    }

    // MARK: - Helpers

    private func makeAttributed(_ parts: [(String, UIColor, UIFont)]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for (text, color, font) in parts {
            result.append(NSAttributedString(string: text, attributes: [
                .foregroundColor: color,
                .font: font
            ]))
        }
        return result
    }
}

// MARK: - SuccessViewProtocol

extension SuccessViewController: SuccessViewProtocol {
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
}
