//
//  ImageLoader.swift
//  Sauna-iOS
//
//  Created by Alex Jackson on 03/08/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import UIKit
import Combine

import os.log

private let log = OSLog(subsystem: "org.alexj.Sauna", category: "ImageLoader")

final class ImageLoader {

    // MARK: - Nested Types

    enum LoadError: Error {
        case networkError(URLError)
        case badData
    }

    private class CacheKey: NSObject {

        private let rawValue: String

        init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        convenience init(_ rawValue: URL) {
            self.init(rawValue.absoluteString)
        }

        override func isEqual(_ object: Any?) -> Bool {
            guard let object = object as? CacheKey else {
                return false
            }

            if object === self {
                return true
            }

            return object.rawValue == self.rawValue
        }

        override var hash: Int {
            return rawValue.hashValue
        }
    }

    // MARK: - Private Properties

    private let inMemoryCache: NSCache<CacheKey, UIImage>
    private let session: URLSession
    private let stateQueue = DispatchQueue(label: "org.alexj.Sauna.ImageLoaderQueue", qos: .userInitiated)

    // MARK: - Initializers

    init(session: URLSession) {
        self.session = session
        self.inMemoryCache = NSCache()
        inMemoryCache.countLimit = 30
    }

    static let shared: ImageLoader = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.waitsForConnectivity = true
        sessionConfig.urlCache = URLCache(memoryCapacity: 8 * Int(1E6), diskCapacity: 15 * Int(1E6))
        
        let session = URLSession(configuration: sessionConfig)
        return ImageLoader(session: session)
    }()

    // MARK: - Public Methods

    /// Load an image from a given URL, using a cached version if available.
    ///
    /// - Returns: A publisher resolved with the image when loading completes.
    ///
    func loadImage(at url: URL) -> AnyPublisher<UIImage, LoadError> {
        let cacheKey = CacheKey(url)

        return Deferred<AnyPublisher<UIImage, LoadError>> { [self] in
            if let cachedImage = inMemoryCache.object(forKey: cacheKey) {
                os_log(.debug, log: log, "Cache hit for image %s", url.absoluteString)

                return Just(cachedImage)
                    .setFailureType(to: LoadError.self)
                    .eraseToAnyPublisher()
            } else {
                os_log(.debug, log: log, "Cache miss for image %s", url.absoluteString)

                return loadImageFromNetwork(url: url)
                    .receive(on: stateQueue)
                    .handleEvents(
                        receiveOutput: { [weak self] image in
                            os_log(.debug, log: log, "Cached image for %s", url.absoluteString)
                            self?.inMemoryCache.setObject(image, forKey: cacheKey)
                        },
                        receiveCompletion: { event in
                            if case .failure(let error) = event {
                                os_log(.error, log: log, "Failed to download image for %s. Error: %{public}s",
                                       url.absoluteString, String(describing: error))
                            }
                        }
                    )
                    .eraseToAnyPublisher()
            }
        }
        .subscribe(on: stateQueue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func loadImageFromNetwork(url: URL) -> AnyPublisher<UIImage, LoadError> {
        session.dataTaskPublisher(for: url)
            .map(\.data)
            .mapError(LoadError.networkError)
            .tryMap { data -> UIImage in
                guard let image = UIImage(data: data) else {
                    throw LoadError.badData
                }

                return image
            }
            .mapError { $0 as! LoadError }
            .eraseToAnyPublisher()
    }
}
