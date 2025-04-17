//
//  MainPresenterTests.swift
//  CleanupAppTests
//
//  Created by Philip on 17.04.25.
//

import XCTest
@testable import CleanupApp
import Photos

final class MainPresenterTests: XCTestCase {

    private var presenter: MainPresenter!
    private var mockView: MockMainViewInput!
    private var mockInteractor: MockMainInteractorInput!
    private var mockRouter: MockMainRouterInput!

    override func setUp() {
        super.setUp()
        presenter = MainPresenter()
        mockView = MockMainViewInput()
        mockInteractor = MockMainInteractorInput()
        mockRouter = MockMainRouterInput()

        presenter.view = mockView
        presenter.interactor = mockInteractor
        presenter.router = mockRouter
    }

    func test_toggleSelection_selectsAndDeselectsIndexPath() {
        // Given
        let indexPath = IndexPath(item: 0, section: 0)

        let dummyAsset = PHAsset()
        let group = PhotoGroup(id: UUID(), assets: [dummyAsset])
        mockInteractor.stubbedGroup = group

        // When – select
        presenter.toggleSelection(at: indexPath)

        // Then
        XCTAssertTrue(presenter.isSelected(indexPath: indexPath))
        XCTAssertTrue(mockView.updateSelectionCalled)
        XCTAssertTrue(mockView.reloadItemsCalled)
        XCTAssertTrue(mockView.updateDeleteButtonVisibilityCalled)

        // When – deselect
        presenter.toggleSelection(at: indexPath)

        // Then
        XCTAssertFalse(presenter.isSelected(indexPath: indexPath))
    }
}
