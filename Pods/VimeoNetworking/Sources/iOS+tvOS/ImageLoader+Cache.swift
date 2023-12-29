//
//  ImageLoader+Cache.swift
//  VimeoNetworking
//
//  Created by Rogerio de Paula Assis on 9/18/19.
//  Copyright © 2019 Vimeo. All rights reserved.
//

import UIKit

// TODO: This wrapper must be removed from the networking layer in favor of a more generic solution
// The only reason this is currently here is due to our dependency on AFNetworking and the
// fact that we use their loading/caching UIKit extensions extensively throughout our source code
extension UIImageView {

    /// Asynchronously downloads an image from the specified URL request.
    /// Any previous image request for the receiver will be cancelled.
    /// If the image is cached locally, the image is returned immediately, otherwise the specified placeholder
    /// image will be set immediately, and then the remote image will be returned once the request is finished.
    ///
    /// It is the responsibility of the closure to set the image of the image view before returning.
    ///
    /// - Parameters:
    ///   - urlRequest: The URL request used for the image request.
    ///   - placeholder: The image to be set initially, until the image request finishes. If `nil`, the image view
    ///   will not change its image until the image request finishes.
    ///   - callback: A closure to be executed when the image data task finishes. This closure has no return value and
    ///   takes three arguments: the image created from the response data or the error object describing the
    ///   network or parsing error that occurred, as well as a boolean flag indicating whether the image was return
    ///   from the local cache.
    @objc public func loadImage(
        with urlRequest: URLRequest,
        placeholder: UIImage? = nil,
        then callback: @escaping (UIImage?, Error?, Bool) -> Void) {
        self.setImageWith(
            urlRequest,
            placeholderImage: placeholder,
            success: { _, response, image in callback(image, nil, response == nil) },
            failure: { _, _, error in callback(nil, error, false) }
        )
    }
}
