//
//  PhotoLibraryService.swift
//  CleanupApp
//
//  Created by Philip on 15.04.25.
//

import UIKit
import Photos

class PhotoLibraryService {
    private let analyzer = SimilarityAnalyzer()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        default:
            completion(false)
        }
    }
    func groupPhotos(_ assets: [PHAsset], completion: @escaping ([PhotoGroup]) -> Void) {
        analyzer.groupSimilarPhotos(from: assets, completion: completion)
    }

    func deletePhotos(_ assets: [PHAsset], completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        }) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    func fetchAllPhotos(completion: @escaping ([PHAsset]) -> Void) {
        var assets: [PHAsset] = []
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let result = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        completion(assets)
    }
    
    func fetchAllPhotos(completion: @escaping ([UIImage]) -> Void) {
        var images: [UIImage] = []
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let imageManager = PHImageManager.default()

        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isSynchronous = false
        imageRequestOptions.deliveryMode = .fastFormat
        imageRequestOptions.resizeMode = .fast
        imageRequestOptions.isNetworkAccessAllowed = true

        let targetSize = CGSize(width: 300, height: 300)

        let dispatchGroup = DispatchGroup()

        assets.enumerateObjects { asset, _, _ in
            dispatchGroup.enter()
            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: imageRequestOptions
            ) { image, _ in
                if let img = image {
                    images.append(img)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(images)
        }
    }
    
    func requestAuthorizationIfNeeded(completion: @escaping (PHAuthorizationStatus) -> Void) {
        let currentStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        if currentStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus)
                }
            }
        } else {
            completion(currentStatus)
        }
    }
    
}

extension PhotoLibraryService {
    func estimateSize(of assets: [PHAsset], completion: @escaping (Int64) -> Void) {
        var totalSize: Int64 = 0
        let dispatchGroup = DispatchGroup()

        for asset in assets {
            dispatchGroup.enter()
            let resources = PHAssetResource.assetResources(for: asset)
            if let resource = resources.first,
               let fileSize = resource.value(forKey: "fileSize") as? CLong {
                totalSize += Int64(fileSize)
                dispatchGroup.leave()
            } else {
                PHAssetResourceManager.default().requestData(for: resources.first!, options: nil, dataReceivedHandler: { _ in }, completionHandler: { _ in
                    totalSize += 1_000_000
                    dispatchGroup.leave()
                })
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(totalSize)
        }
    }
}
