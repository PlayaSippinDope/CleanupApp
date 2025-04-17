//
//  FullScreenPhotoViewController.swift
//  CleanupApp
//
//  Created by Philip on 16.04.25.
//

import UIKit
import Photos

final class FullScreenPhotoViewController: UIViewController {

    private let asset: PHAsset
    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(asset: PHAsset) {
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadImage()
        addDismissGesture()
    }

    private func setupUI() {
        view.backgroundColor = .black

        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(imageView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: scrollView.heightAnchor)
        ])
        
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)

    }

    private func loadImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false

        manager.requestImage(for: asset,
                             targetSize: UIScreen.main.bounds.size,
                             contentMode: .aspectFit,
                             options: options) { [weak self] image, _ in
            self?.imageView.image = image
        }
    }

    private func addDismissGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }

    @objc private func handleSwipeDown() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
}

extension FullScreenPhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
