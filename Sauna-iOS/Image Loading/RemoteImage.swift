//
//  RemoteImage.swift
//  Sauna-iOS
//
//  Created by Alex Jackson on 03/08/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class RemoteImage: ObservableObject {

    // MARK: - Public Properties

    let url: URL
    @Published private(set) var image: UIImage?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: ImageLoader.LoadError?

    var view: Image? {
        image.map(Image.init(uiImage:))
    }

    // MARK: - Private Properties

    private let loader: ImageLoader
    private var loadCancellable: AnyCancellable?

    // MARK: - Initializers

    init(_ url: URL, loader: ImageLoader) {
        self.url = url
        self.loader = loader
    }

    convenience init(_ url: URL) {
        self.init(url, loader: .shared)
    }

    // MARK: - Public Methods

    func startLoading() {
        guard image == nil else {
            return
        }

        isLoading = true
        loadCancellable = loader.loadImage(at: url)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.error = error
                    }

                    self?.isLoading = false
                    self?.loadCancellable = nil
                },
                receiveValue: { [weak self] image in
                    self?.image = image
                }
            )
    }

    func cancelLoading() {
        loadCancellable?.cancel()
        loadCancellable = nil
        isLoading = false
    }

    deinit {
        cancelLoading()
    }
}
