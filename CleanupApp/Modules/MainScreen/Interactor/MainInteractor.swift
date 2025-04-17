//
//  MainInteractor.swift
//  CleanupApp
//
//  Created by Philip on 14.04.25.
//

import Foundation
import Photos

final class MainInteractor: MainInteractorInput {
    weak var output: MainInteractorOutput?

    private let photoService: PhotoLibraryService
    private(set) var currentGroups: [PhotoGroup] = []

    init(photoService: PhotoLibraryService) {
        self.photoService = photoService
    }

    var groups: [PhotoGroup] {
        return currentGroups
    }

    func group(at section: Int) -> PhotoGroup? {
        guard section < currentGroups.count else { return nil }
        return currentGroups[section]
    }

    func loadPhotoGroups() {
        photoService.requestAuthorizationIfNeeded { [weak self] status in
            guard let self else { return }

            switch status {
            case .authorized, .limited:
                self.output?.setLoading(true)
                self.photoService.fetchAllPhotos { assets in
                    self.photoService.groupPhotos(assets) { groups in
                        self.currentGroups = groups
                        self.output?.didLoad(groups: groups)
                    }
                }

            case .denied, .restricted:
                self.output?.requestPermissionAgain()

            case .notDetermined:
                self.output?.requestPermissionAgain()

            @unknown default:
                self.output?.requestPermissionAgain()
            }
        }
    }
    
    func deletePhotos(at indexPaths: [IndexPath]) {
        let assetsToDelete: [PHAsset] = indexPaths.compactMap {
            guard $0.section < currentGroups.count,
                  $0.item < currentGroups[$0.section].assets.count else { return nil }
            return currentGroups[$0.section].assets[$0.item]
        }

        photoService.estimateSize(of: assetsToDelete) { [weak self] totalBytes in
            self?.photoService.deletePhotos(assetsToDelete) { success in
                guard success else { return }

                self?.removeAssets(at: indexPaths)
                self?.currentGroups.removeAll(where: { $0.assets.count <= 1 })
                let deletedCount = assetsToDelete.count
                self?.output?.didFinishDeletion(deletedCount: deletedCount, freedBytes: totalBytes)
            }
        }
    }

    private func removeAssets(at indexPaths: [IndexPath]) {
        let grouped = Dictionary(grouping: indexPaths, by: { $0.section })
        
        for (section, items) in grouped {
            guard section < currentGroups.count else { continue }
            
            var group = currentGroups[section]
            let sortedItems = items.map { $0.item }.sorted(by: >)

            for item in sortedItems {
                if item < group.assets.count {
                    group.assets.remove(at: item)
                }
            }
            
            currentGroups[section] = group
        }

        currentGroups.removeAll(where: { $0.assets.isEmpty })
    }
}
