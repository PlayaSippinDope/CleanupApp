//
//  MainPresenter.swift
//  CleanupApp
//
//  Created by Philip on 14.04.25.
//

import Foundation

final class MainPresenter {
    weak var view: MainViewInput?
    var interactor: MainInteractorInput?
    var router: MainRouterInput?

    private var selectedIndexPaths = Set<IndexPath>()
    private var fullySelectedSections = Set<Int>()

    func toggleSelection(at indexPath: IndexPath) {
        if selectedIndexPaths.contains(indexPath) {
            selectedIndexPaths.remove(indexPath)
        } else {
            selectedIndexPaths.insert(indexPath)
        }

        if let group = interactor?.group(at: indexPath.section) {
            let totalItems = group.assets.count
            let sectionIndexPaths = (0..<totalItems).map { IndexPath(item: $0, section: indexPath.section) }

            if sectionIndexPaths.allSatisfy({ selectedIndexPaths.contains($0) }) {
                fullySelectedSections.insert(indexPath.section)
            } else {
                fullySelectedSections.remove(indexPath.section)
            }
        }

        view?.updateSelection(at: indexPath)
        if let group = interactor?.group(at: indexPath.section) {
            let indexPaths = group.assets.enumerated().map {
                IndexPath(item: $0.offset, section: indexPath.section)
            }
            view?.reloadItems(at: indexPaths)
        }

        view?.updateDeleteButtonVisibility(isVisible: !selectedIndexPaths.isEmpty)
    }


    func isSelected(indexPath: IndexPath) -> Bool {
        return selectedIndexPaths.contains(indexPath)
    }

    func deleteSelectedPhotos() {
        guard !selectedIndexPaths.isEmpty else { return }
        interactor?.deletePhotos(at: Array(selectedIndexPaths))
    }
    
    func isAllSelected(in section: Int) -> Bool {
        guard let group = interactor?.group(at: section) else { return false }

        for (index, _) in group.assets.enumerated() {
            let indexPath = IndexPath(item: index, section: section)
            if !selectedIndexPaths.contains(indexPath) {
                return false
            }
        }
        return true
    }
    
    func toggleSelectionForSection(_ section: Int, totalItems: Int) {
        let indexPaths = (0..<totalItems).map { IndexPath(item: $0, section: section) }

        if fullySelectedSections.contains(section) {
            for indexPath in indexPaths {
                selectedIndexPaths.remove(indexPath)
            }
            fullySelectedSections.remove(section)
        } else {
            for indexPath in indexPaths {
                selectedIndexPaths.insert(indexPath)
            }
            fullySelectedSections.insert(section)
        }

        view?.reloadItems(at: indexPaths)
        view?.reloadHeader(for: section)
        view?.updateDeleteButtonVisibility(isVisible: !selectedIndexPaths.isEmpty)
    }

    func isSectionFullySelected(_ section: Int, totalItems: Int) -> Bool {
        let indexPaths = (0..<totalItems).map { IndexPath(item: $0, section: section) }
        return indexPaths.allSatisfy { selectedIndexPaths.contains($0) }
    }

}

extension MainPresenter: MainViewOutput {
    func viewDidLoad() {
        view?.setLoading(false)
        interactor?.loadPhotoGroups()
    }
    
    var selectedCount: Int {
        return selectedIndexPaths.count
    }
    
    func openFullScreenPhoto(at indexPath: IndexPath) {
        guard let group = interactor?.group(at: indexPath.section),
              indexPath.item < group.assets.count else { return }

        let asset = group.assets[indexPath.item]
        router?.openFullScreenPhoto(asset: asset)
    }
}

extension MainPresenter: MainInteractorOutput {
    func setLoading(_ isLoading: Bool) {
        view?.setLoading(isLoading)
    }
    
    func requestPermissionAgain() {
        view?.showPermissionAlert()
    }
    
    func didLoad(groups: [PhotoGroup]) {
        view?.setLoading(false)
        view?.show(groups: groups)
        view?.updateDeleteButtonVisibility(isVisible: false)
    }

    func didFinishDeletion(deletedCount: Int, freedBytes: Int64) {
        selectedIndexPaths.removeAll()
        view?.updateDeleteButtonVisibility(isVisible: false)

        let updatedGroups = interactor?.groups ?? []
        view?.show(groups: updatedGroups)

        let mb = Double(freedBytes) / 1_048_576.0
        router?.showSuccessScreen(deletedCount: deletedCount, freedMB: mb)
    }
}
