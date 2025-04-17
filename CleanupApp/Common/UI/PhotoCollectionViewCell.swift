//
//  PhotoCollectionViewCell.swift
//  CleanupApp
//
//  Created by Philip on 15.04.25.
//

import UIKit
import Photos

protocol PhotoCellDelegate: AnyObject {
    func photoCellDidToggleSelection(_ cell: PhotoCollectionViewCell)
    func photoCellDidTapImage(_ cell: PhotoCollectionViewCell)
}

final class PhotoCollectionViewCell: UICollectionViewCell {
    static let reuseId = "PhotoCollectionViewCell"

    weak var delegate: PhotoCellDelegate?

    private let imageView = UIImageView()
    private let checkmarkImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.isUserInteractionEnabled = true

        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.tintColor = .white
        checkmarkImageView.isUserInteractionEnabled = true

        // Checkmark click
        let checkmarkTap = UITapGestureRecognizer(target: self, action: #selector(didTapCheckmark))
        checkmarkImageView.addGestureRecognizer(checkmarkTap)

        // Image click
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(imageTap)

        contentView.addSubview(imageView)
        contentView.addSubview(checkmarkImageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }

    @objc private func didTapCheckmark() {
        delegate?.photoCellDidToggleSelection(self)
    }

    @objc private func didTapImage() {
        delegate?.photoCellDidTapImage(self)
    }

    func configure(with asset: PHAsset, isSelected: Bool) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = false

        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 100, height: 100),
                             contentMode: .aspectFill,
                             options: options) { [weak self] image, _ in
            self?.imageView.image = image
        }

        if isSelected {
            checkmarkImageView.image = UIImage(named: "checkmarkIcon")
            checkmarkImageView.tintColor = .systemGreen
        } else {
            checkmarkImageView.image = UIImage(named: "rectangle")
            checkmarkImageView.tintColor = .white
        }
    }
}
