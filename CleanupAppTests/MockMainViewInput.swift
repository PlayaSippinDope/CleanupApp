//
//  MockMainViewInput.swift
//  CleanupAppTests
//
//  Created by Philip on 17.04.25.
//

import XCTest
@testable import CleanupApp
import Photos

// MARK: - Mock View
final class MockMainViewInput: MainViewInput {
    var updateSelectionCalled = false
    var reloadItemsCalled = false
    var updateDeleteButtonVisibilityCalled = false
    var reloadSectionCalled = false
    var removeItemsCalled = false

    func updateSelection(at indexPath: IndexPath) {
        updateSelectionCalled = true
    }

    func reloadItems(at indexPaths: [IndexPath]) {
        reloadItemsCalled = true
    }

    func updateDeleteButtonVisibility(isVisible: Bool) {
        updateDeleteButtonVisibilityCalled = true
    }

    func reloadHeader(for section: Int) {
        reloadSectionCalled = true
    }

    func setLoading(_ isLoading: Bool) {}

    func show(groups: [PhotoGroup]) {}

    func showPermissionAlert() {}

    func reloadSection(_ section: Int) {
        reloadSectionCalled = true
    }

    func removeItems(at indexPaths: [IndexPath]) {
        removeItemsCalled = true
    }
}


// MARK: - Mock Interactor
final class MockMainInteractorInput: MainInteractorInput {
    var stubbedGroup: PhotoGroup?

    func loadPhotoGroups() {}
    func deletePhotos(at indexPaths: [IndexPath]) {}

    func group(at section: Int) -> PhotoGroup? {
        return stubbedGroup
    }

    var groups: [PhotoGroup] = []
}

// MARK: - Mock Router
final class MockMainRouterInput: MainRouterInput {
    func navigateToSuccessScreen(deletedCount: Int) {}
    func showSuccessScreen(deletedCount: Int, freedMB: Double) {}
    func openFullScreenPhoto(asset: PHAsset) {}
}
