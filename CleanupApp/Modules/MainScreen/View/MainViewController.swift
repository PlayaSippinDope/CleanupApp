//
//  MainViewController.swift
//  CleanupApp
//
//  Created by Philip on 14.04.25.
//

import UIKit

final class MainViewController: UIViewController {
    // MARK: - Public Properties
    var presenter: MainViewOutput?
    
    // MARK: - Private Properties
    private var photoGroups: [PhotoGroup] = []
    private var shouldScrollToFirstItem = false

    // MARK: - UI Elements
    private lazy var headerView: UILabel = {
        let headerView = UILabel()
        headerView.font = .boldSystemFont(ofSize: 24)
        headerView.textColor = .white
        headerView.textAlignment = .left
        headerView.numberOfLines = 2
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = makeCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseId)
        collectionView.register(PhotoSectionHeaderView.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                 withReuseIdentifier: PhotoSectionHeaderView.reuseId)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var deleteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.title = "Delete"
        config.baseForegroundColor = .white
        config.background.backgroundColor = .systemBlue
        config.titleAlignment = .center
        config.imagePadding = 10
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var newAttributes = attributes
            newAttributes.font = UIFont.boldSystemFont(ofSize: 20)
            return newAttributes
        }

        let button = UIButton(configuration: config, primaryAction: nil)
        button.alpha = 0
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Preparing your photos..."
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBlue
        setupLayout()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if shouldScrollToFirstItem, photoGroups.count > 0, photoGroups[0].assets.count > 0 {
            let indexPath = IndexPath(item: 0, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            shouldScrollToFirstItem = false
        }
    }
    
    // MARK: - Setup Layout
    private func setupLayout() {
        setupHeaderView()
        setupCollectionView()
        setupDeleteButton()
        setupLoadingIndicator()
        setupLoadingLabel()
    }
    
    private func setupHeaderView() {
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.headerTopInset),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.headerSideInset),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.headerSideInset),
            headerView.heightAnchor.constraint(equalToConstant: Constants.headerHeight)
        ])
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.layer.cornerRadius = Constants.collectionCornerRadius
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collectionView.layer.masksToBounds = true
        collectionView.contentInset.top = Constants.collectionTopInset

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupDeleteButton() {
        view.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.deleteButtonHeight),
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.deleteButtonSideInset),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.deleteButtonSideInset),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.deleteButtonBottomInset)
        ])
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupLoadingLabel() {
        view.addSubview(loadingLabel)

        NSLayoutConstraint.activate([
            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: Constants.loadingLabelTopOffset),
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - Actions
extension MainViewController {
    @objc private func deleteButtonTapped() {
        shouldScrollToFirstItem = true
        presenter?.deleteSelectedPhotos()
        updateHeaderAndButton()
    }
    
    private func updateHeaderAndButton() {
        let total = photoGroups.reduce(0) { $0 + $1.assets.count }
        let selected = presenter?.selectedCount ?? 0
        updateHeader(total: total, selected: selected)
        updateDeleteButtonTitle(selectedCount: selected)
    }
    
    private func makeDeleteButtonConfiguration(selectedCount: Int) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "delete")?.withRenderingMode(.alwaysTemplate)
        config.imagePadding = 10
        config.baseForegroundColor = .white
        config.background.backgroundColor = .systemBlue
        config.cornerStyle = .capsule
        
        let title = "Delete \(selectedCount) similars"
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([.font: UIFont.boldSystemFont(ofSize: 20)])
        )
        
        return config
    }
    
    private func makeCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(183),
                heightDimension: .absolute(215)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(1000),
                heightDimension: .absolute(215)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 6
            section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 16, bottom: 16, trailing: 16)
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(30)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            return section
        }
    }
}

// MARK: - MainViewInput
extension MainViewController: MainViewInput {
    func reloadHeader(for section: Int) {
        let indexPath = IndexPath(item: 0, section: section)
        
        guard let header = collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
        ) as? PhotoSectionHeaderView else {
            return
        }

        let totalItems = photoGroups[section].assets.count
        let isAllSelected = presenter?.isSectionFullySelected(section, totalItems: totalItems) ?? false
        header.configure(similarCount: totalItems, isAllSelected: isAllSelected)
        
        updateHeaderAndButton()
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        guard let section = indexPaths.first?.section else { return }
        reloadHeader(for: section)
        collectionView.reloadItems(at: indexPaths)
        updateHeaderAndButton()
    }
    
    func reloadSection(_ section: Int) {
        collectionView.reloadSections(IndexSet(integer: section))
        updateHeaderAndButton()
    }
    
    func updateSelection(at indexPath: IndexPath) {
        collectionView.reloadItems(at: [indexPath])
        updateHeaderAndButton()
    }

    func setLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            loadingLabel.isHidden = false
        } else {
            loadingIndicator.stopAnimating()
            loadingLabel.isHidden = true
        }
    }
    
    func removeItems(at indexPaths: [IndexPath]) {
        let grouped = Dictionary(grouping: indexPaths, by: { $0.section })

        for (section, indexPathsInSection) in grouped {
            guard section < photoGroups.count else { continue }

            var group = photoGroups[section]
            let sorted = indexPathsInSection.map { $0.item }.sorted(by: >)

            for item in sorted {
                if item < group.assets.count {
                    group.assets.remove(at: item)
                }
            }

            photoGroups[section] = group
        }

        photoGroups.removeAll(where: { $0.assets.isEmpty })

        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: indexPaths)
        } completion: { _ in
            if self.photoGroups.isEmpty {
                self.collectionView.reloadData()
            } else {
                self.collectionView.reloadSections(IndexSet(integersIn: 0..<self.photoGroups.count))
            }
        }

        updateHeaderAndButton()
    }

    func updateDeleteButtonVisibility(isVisible: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.deleteButton.alpha = isVisible ? 1.0 : 0.0
        }
    }

    func show(groups: [PhotoGroup]) {
        self.photoGroups = groups
        collectionView.reloadData()
        updateHeaderAndButton()
    }

    func updateHeader(total: Int, selected: Int) {
        let fullText = "Similar\n\(total) photos • \(selected) selected"
        let attributedText = NSMutableAttributedString(string: fullText)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Constants.headerLineSpacing

        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: fullText.count))

        if let range = fullText.range(of: "\(total) photos • \(selected) selected") {
            let nsRange = NSRange(range, in: fullText)
            attributedText.addAttributes([
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor(white: 1.0, alpha: 0.8)
            ], range: nsRange)
        }

        headerView.attributedText = attributedText
    }

    func updateDeleteButtonTitle(selectedCount: Int) {
        deleteButton.configuration = makeDeleteButtonConfiguration(selectedCount: selectedCount)
    }
    
    func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Photo Access",
            message: "The app needs access to your photos to continue. Please grant access in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { [weak self] _ in
            
            self?.presenter?.viewDidLoad()
        })
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        })
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photoGroups.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoGroups[section].assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.reuseId, for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        let asset = photoGroups[indexPath.section].assets[indexPath.item]
        let isSelected = presenter?.isSelected(indexPath: indexPath) ?? false
        cell.configure(with: asset, isSelected: isSelected)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PhotoSectionHeaderView.reuseId,
            for: indexPath
        ) as! PhotoSectionHeaderView

        let totalItems = photoGroups[indexPath.section].assets.count
        let isAllSelected = presenter?.isSectionFullySelected(indexPath.section, totalItems: totalItems) ?? false
        header.configure(similarCount: totalItems, isAllSelected: isAllSelected)

        header.onToggleSelection = { [weak self] in
            self?.presenter?.toggleSelectionForSection(indexPath.section, totalItems: totalItems)
        }

        return header
    }
}

// MARK: - PhotoSectionHeaderViewDelegate
extension MainViewController: PhotoSectionHeaderViewDelegate {
    func didTapSelectAll(in section: Int) {
        let totalItems = photoGroups[section].assets.count
        presenter?.toggleSelectionForSection(section, totalItems: totalItems)
    }
}

// MARK: - PhotoCellDelegate
extension MainViewController: PhotoCellDelegate {
    func photoCellDidToggleSelection(_ cell: PhotoCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        presenter?.toggleSelection(at: indexPath)
    }

    func photoCellDidTapImage(_ cell: PhotoCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let flashView = UIView(frame: cell.bounds)
        flashView.backgroundColor = .white
        flashView.alpha = 0
        flashView.isUserInteractionEnabled = false
        flashView.layer.cornerRadius = cell.layer.cornerRadius
        flashView.clipsToBounds = true
        cell.addSubview(flashView)
        cell.bringSubviewToFront(flashView)
        
        UIView.animate(withDuration: 0.05, animations: {
            flashView.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                flashView.alpha = 0
            }, completion: { _ in
                flashView.removeFromSuperview()
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.presenter?.openFullScreenPhoto(at: indexPath)
        }
    }
}
