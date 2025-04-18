//
//  MainProtocols.swift
//  CleanupApp
//
//  Created by Philip on 14.04.25.
//

import Foundation
import Photos

protocol MainViewInput: AnyObject {
    func show(groups: [PhotoGroup])
    func updateSelection(at indexPath: IndexPath)
    func updateDeleteButtonVisibility(isVisible: Bool)
    func reloadSection(_ section: Int)
    func setLoading(_: Bool)
    func removeItems(at indexPaths: [IndexPath])
    func reloadItems(at indexPaths: [IndexPath])
    func reloadHeader(for section: Int)
    func showPermissionAlert()
}

protocol MainViewOutput: AnyObject {
    var selectedCount: Int { get }
    func viewDidLoad()
    func toggleSelection(at indexPath: IndexPath)
    func isSelected(indexPath: IndexPath) -> Bool
    func deleteSelectedPhotos()
    func isAllSelected(in section: Int) -> Bool
    func toggleSelectionForSection(_ section: Int, totalItems: Int)
    func isSectionFullySelected(_ section: Int, totalItems: Int) -> Bool
    func openFullScreenPhoto(at indexPath: IndexPath)
}

protocol MainInteractorInput: AnyObject {
    func loadPhotoGroups()
    func deletePhotos(at indexPaths: [IndexPath])
    var groups: [PhotoGroup] { get }
    func group(at section: Int) -> PhotoGroup?
}

protocol MainInteractorOutput: AnyObject {
    func requestPermissionAgain()
    func didLoad(groups: [PhotoGroup])
    func didFinishDeletion(deletedCount: Int, freedBytes: Int64)
    func setLoading(_ isLoading: Bool)
}

protocol MainRouterInput: AnyObject {
    func showSuccessScreen(deletedCount: Int, freedMB: Double)
    func openFullScreenPhoto(asset: PHAsset)
}
