//
//  ImageCache.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 29/08/2025.
//

import UIKit
import Foundation

// MARK: - Image Cache Protocol

protocol ImageCacheProtocol {
    func loadImage(from url: URL) async -> UIImage?
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void)
    func clearCache()
    func removeImage(for url: URL)
}

// MARK: - Image Cache Implementation

final class ImageCache: ImageCacheProtocol {
    
    // MARK: - Singleton
    
    static let shared = ImageCache()
    
    // MARK: - Properties
    
    private let cache = NSCache<NSString, UIImage>()
    private let session = URLSession.shared
    private let queue = DispatchQueue(label: "com.yassir.imagecache", qos: .userInitiated)
    
    // MARK: - Initialization
    
    private init() {
        setupCache()
    }
    
    private func setupCache() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    // MARK: - Public Methods
    
    func loadImage(from url: URL) async -> UIImage? {
        let key = NSString(string: url.absoluteString)
        
        // Check cache first
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        // Download image
        return await downloadImage(from: url, key: key)
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let key = NSString(string: url.absoluteString)
        
        // Check cache first
        if let cachedImage = cache.object(forKey: key) {
            completion(cachedImage)
            return
        }
        
        // Download image asynchronously
        Task {
            let image = await downloadImage(from: url, key: key)
            await MainActor.run {
                completion(image)
            }
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    func removeImage(for url: URL) {
        let key = NSString(string: url.absoluteString)
        cache.removeObject(forKey: key)
    }
    
    // MARK: - Private Methods
    
    private func downloadImage(from url: URL, key: NSString) async -> UIImage? {
        do {
            let (data, _) = try await session.data(from: url)
            
            guard let image = UIImage(data: data) else {
                return nil
            }
            
            // Cache the image
            cache.setObject(image, forKey: key)
            
            return image
            
        } catch {
            print("Failed to download image from \(url): \(error)")
            return nil
        }
    }
}

// MARK: - UIImage Extension

extension UIImage {
    var memorySize: Int {
        guard let cgImage = self.cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
}
