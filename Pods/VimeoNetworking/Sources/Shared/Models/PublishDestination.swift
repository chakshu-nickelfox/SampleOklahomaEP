//
//  PublishJobDestination.swift
//  VimeoNetworking
//
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

/// The status of the upload or post for the given platform.
/// - error: There was an error trying to upload the video or create the post.
/// - finished: The post was successfully published.
/// - inProgress: The post creation process is currently underway.
@objc public enum PublishStatus: Int {
    case error
    case finished
    case inProgress
}

extension PublishStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .error:
            return .error
        case .finished:
            return .finished
        case .inProgress:
            return .inProgress
        }
    }
}

@objcMembers
public class PublishDestination: VIMModelObject {
    internal private(set) var statusString: String?
    
    /// The status of the post for a given platform.
    @nonobjc public var status: PublishStatus? {
        switch self.statusString {
        case String.error:
            return .error
        case String.finished:
            return .finished
        case String.inProgress:
            return .inProgress
        default:
            return nil
        }
    }
    /// The URL of the post on a given platform.
    public private(set) var thirdPartyPostURL: String?
    
    /// The ID of the post on a given platform.
    public private(set) var thirdPartyPostID: String?

    /// The number of views this post has, as reported by the third party platform.
    public private(set) var thirdPartyViewCount: NSNumber?

    /// The number of likes (or equivalent) this post has, as reported by the third party platform.
    public private(set) var thirdPartyLikeCount: NSNumber?

    /// The number of comments this post has, as reported by the third party platform.
    public private(set) var thirdPartyCommentCount: NSNumber?
    
    // MARK: - Overrides
    
    public override func getObjectMapping() -> Any? {
        return [
            Constants.thirdPartyPostURL.0: Constants.thirdPartyPostURL.1,
            Constants.thirdPartyPostID.0: Constants.thirdPartyPostID.1,
            Constants.thirdPartyViewCount.0: Constants.thirdPartyViewCount.1,
            Constants.thirdPartyLikeCount.0: Constants.thirdPartyLikeCount.1,
            Constants.thirdPartyCommentCount.0: Constants.thirdPartyCommentCount.1,
            Constants.status.0: Constants.status.1
        ]
    }
}

/// Encapsulates data related to all supported platform destinations.
@objcMembers
public class PublishDestinations: VIMModelObject {
    
    /// Information about a post on Facebook.
    public private(set) var facebook: PublishDestination?
    
    /// Information about a post on YouTube.
    public private(set) var youtube: PublishDestination?
    
    /// Information about a post on LinkedIn.
    public private(set) var linkedin: PublishDestination?
    
    /// Information about a post on Twitter.
    public private(set) var twitter: PublishDestination?

    public override func getClassForObjectKey(_ key: String?) -> AnyClass? {
        switch key {
        case String.facebook,
             String.linkedin,
             String.twitter,
             String.youtube:
            return PublishDestination.self
        default:
            return nil
        }
    }
}

private extension String {
    static let error = "error"
    static let finished = "finished"
    static let inProgress = "in_progress"
}

private struct Constants {
    static let status = (key: "status", value: "statusString")
    static let thirdPartyPostURL = (key: "third_party_post_url", value: "thirdPartyPostURL")
    static let thirdPartyPostID = (key: "third_party_post_id", value: "thirdPartyPostID")
    static let thirdPartyViewCount = (key: "third_party_view_count", value: "thirdPartyViewCount")
    static let thirdPartyLikeCount = (key: "third_party_like_count", value: "thirdPartyLikeCount")
    static let thirdPartyCommentCount = (key: "third_party_comment_count", value: "thirdPartyCommentCount")
}
