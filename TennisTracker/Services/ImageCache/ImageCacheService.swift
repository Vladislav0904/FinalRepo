import UIKit
import Foundation

protocol ImageCacheServiceProtocol {
    func getImage(from url: URL) async -> UIImage?
    func clearCache()
}

final class ImageCacheService: ImageCacheServiceProtocol {
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    init() {
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB

        guard let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            assertionFailure("Failed to get caches directory")
            cacheDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("PlayerImages", isDirectory: true)
            return
        }
        cacheDirectory = cachesDirectory.appendingPathComponent("PlayerImages", isDirectory: true)

        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }

    func getImage(from url: URL) async -> UIImage? {
        let cacheKey = url.absoluteString as NSString

        if let cachedImage = memoryCache.object(forKey: cacheKey) {
            return cachedImage
        }

        if let diskImage = loadFromDisk(key: cacheKey as String) {
            memoryCache.setObject(diskImage, forKey: cacheKey)
            return diskImage
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                return nil
            }

            memoryCache.setObject(image, forKey: cacheKey)

            saveToDisk(image: image, key: cacheKey as String)

            return image
        } catch {
            return nil
        }
    }

    func clearCache() {
        memoryCache.removeAllObjects()

        if let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) {
            for file in files {
                try? fileManager.removeItem(at: file)
            }
        }
    }

    private func saveToDisk(image: UIImage, key: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }

        let fileName = sanitizeFileName(key)
        let fileURL = cacheDirectory.appendingPathComponent(fileName)

        try? data.write(to: fileURL)
    }

    private func loadFromDisk(key: String) -> UIImage? {
        let fileName = sanitizeFileName(key)
        let fileURL = cacheDirectory.appendingPathComponent(fileName)

        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }

        return image
    }

    private func sanitizeFileName(_ fileName: String) -> String {

        let invalidCharacters = CharacterSet(charactersIn: "/:?<>|\\")
        return fileName.components(separatedBy: invalidCharacters).joined(separator: "_")
    }
}
