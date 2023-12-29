//
//  VimeoSessionManaging.swift
//  VimeoNetworking
//
//  Created by Rogerio de Paula Assis on 9/5/19.
//  Copyright © 2019 Vimeo. All rights reserved.
//

import Foundation

public struct SessionManagingResult<T> {
    public let request: URLRequest?
    public let response: URLResponse?
    public let result: Result<T, Error>

    init(request: URLRequest? = nil, response: URLResponse? = nil, result: Result<T, Error>) {
        self.request = request
        self.response = response
        self.result = result
    }
}

/// A type that can perform asynchronous requests from a
/// URLRequestConvertible parameter and a response callback.
public protocol SessionManaging: AuthenticationListener {
    
    /// Used to invalidate the session manager, and optionally cancel any pending tasks
    func invalidate(cancelingPendingTasks cancelPendingTasks: Bool)
    
    /// The various methods below create asynchronous operations described by the
    /// requestConvertible object, and return a corresponding task that can be used to identify and
    /// control the lifecycle of the request.
    /// The callback provided will be executed once the operation completes. It will include
    /// the result object along with the originating request and corresponding response objects.

    // Data request
    func request(
        _ requestConvertible: URLRequestConvertible,
        parameters: Any?,
        then callback: @escaping (SessionManagingResult<Data>) -> Void
    ) -> Task?

    // JSON request
    func request(
        _ requestConvertible: URLRequestConvertible,
        parameters: Any?,
        then callback: @escaping (SessionManagingResult<JSON>) -> Void
    ) -> Task?

    // Decodable request
    func request<T: Decodable>(
        _ requestConvertible: URLRequestConvertible,
        parameters: Any?,
        then callback: @escaping (SessionManagingResult<T>) -> Void
    ) -> Task?

    // Download request
    func download(
        _ requestConvertible: URLRequestConvertible,
        destinationURL: URL?,
        then callback: @escaping (SessionManagingResult<URL>) -> Void
    ) -> Task?

    // Upload request
    func upload(
        _ requestConvertible: URLRequestConvertible,
        sourceFile: URL,
        then callback: @escaping (SessionManagingResult<JSON>) -> Void
    ) -> Task?

}
