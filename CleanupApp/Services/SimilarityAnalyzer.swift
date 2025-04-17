//
//  SimilarityAnalyzer.swift
//  CleanupApp
//
//  Created by Philip on 15.04.25.
//

import UIKit
import Photos
import Vision

final class SimilarityAnalyzer {

    struct AssetFeature {
        let asset: PHAsset
        let feature: VNFeaturePrintObservation
    }

    func groupSimilarPhotos(from assets: [PHAsset], completion: @escaping ([PhotoGroup]) -> Void) {
        var assetFeatures: [AssetFeature] = []
        let dispatchGroup = DispatchGroup()
        let imageManager = PHImageManager.default()

        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = false
        requestOptions.isNetworkAccessAllowed = true

        let targetSize = CGSize(width: 224, height: 224)

        for asset in assets {
            if asset.mediaSubtypes.contains(.photoScreenshot) {
                    continue
                }
            dispatchGroup.enter()

            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: requestOptions) { image, _ in
                defer { dispatchGroup.leave() }
                guard let image = image, let cgImage = image.cgImage ?? self.convertToCGImage(image) else { return }
                
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                let request = VNGenerateImageFeaturePrintRequest()

                
                do {
                    try handler.perform([request])
                    if let feature = request.results?.first as? VNFeaturePrintObservation {
                        assetFeatures.append(AssetFeature(asset: asset, feature: feature))
                    }
                } catch {
                    print("Failed to extract feature vector")
                }
            }
        }

        dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
            let groupedAssets = self.clusterAssets(features: assetFeatures)
            let photoGroups = groupedAssets.map { PhotoGroup(id: UUID(), assets: $0) }
            DispatchQueue.main.async {
                completion(photoGroups)
            }
        }
    }
    
    func convertToCGImage(_ image: UIImage) -> CGImage? {
        let context = CIContext()
        if let ciImage = image.ciImage {
            return context.createCGImage(ciImage, from: ciImage.extent)
        }
        if let cgImage = image.cgImage {
            return cgImage
        }
        if let ciImage = CIImage(image: image) {
            return context.createCGImage(ciImage, from: ciImage.extent)
        }
        return nil
    }

    private func clusterAssets(features: [AssetFeature]) -> [[PHAsset]] {
        var visited = Set<Int>()
        var groups: [[PHAsset]] = []

        for (i, item) in features.enumerated() {
            if visited.contains(i) { continue }

            var group: [PHAsset] = [item.asset]
            visited.insert(i)

            for (j, otherItem) in features.enumerated() {
                guard i != j && !visited.contains(j) else { continue }

                var distance: Float = 0
                do {
                    try item.feature.computeDistance(&distance, to: otherItem.feature)
                    if distance < 10 {
                        group.append(otherItem.asset)
                        visited.insert(j)
                    }
                } catch {
                    continue
                }
            }

            if group.count > 1 {
                groups.append(group)
            }
        }

        return groups
    }
}
