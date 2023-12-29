//
//  TranscodeStatusEndpoint.swift
//  VimeoNetworking-iOS
//
//  Created by Nicole Lehrer on 12/10/19.
//  Copyright © 2019 Vimeo. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// Encapsulates all information required to fetch a video's transcode status
public struct TranscodeStatusEndpoint: EndpointType {
    public let headers: HTTPHeaders? = nil
    public let parameters: Any? = nil
    public let method = HTTPMethod.get
    public let path: String
    private let statusPathComponent = "/status"
    
    /// Initializer for creating a TranscodeStatusEndpoint
    /// - Parameter videoURI: the URI of the video
    public init(videoURI: String) {
        self.path = videoURI + statusPathComponent
    }
    
    /// Provides a configured request for fetching a video's transcode status
    public func asURLRequest() throws -> URLRequest {
        return URLRequest(url: self.baseURL.appendingPathComponent(self.path))
    }
}
