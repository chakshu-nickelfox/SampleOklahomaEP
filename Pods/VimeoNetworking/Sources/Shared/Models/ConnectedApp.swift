//
//  ConnectedApp.swift
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

/// An enumeration of the supported connected app types.
/// - facebook: Represents a connection to Facebook.
/// - linkedin: Represents a connection to LinkedIn.
/// - twitter: Represents a connection to Twitter.
/// - youtube: Represents a connection to YouTube.
@objc public enum ConnectedAppType: Int {
    case facebook
    case linkedin
    case twitter
    case youtube
}

extension ConnectedAppType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .facebook:
            return String.facebook
        case .linkedin:
            return String.linkedin
        case .twitter:
            return String.twitter
        case .youtube:
            return String.youtube
        }
    }
}

extension ConnectedAppType: RawRepresentable {
    public typealias RawValue = String
    public var rawValue: RawValue { return String(describing: self) }
    public init?(rawValue: Self.RawValue) {
        switch rawValue {
        case String.facebook:
            self = .facebook
        case String.linkedin:
            self = .linkedin
        case String.twitter:
            self = .twitter
        case String.youtube:
            self = .youtube
        default:
            return nil
        }
    }
}

///  An object that encapsulates the scopes necessary for interacting with features like publishing to social platforms
///  or simulcasting a live stream.
@objcMembers
public class ConnectedAppScopes: VIMModelObject {

    /// All scopes required for publishing to a specific social media platform.
    public private(set) var publishToSocial: [String]?

    /// All scopes required for simulcasting to a specific social media platform.
    public private(set) var simulcast: [String]?

    // MARK: - Overrides

    public override func getObjectMapping() -> Any? {
        return [
            Constants.Key.publishToSocial: Constants.Value.publishToSocial
        ]
    }
}

/// A category that can be sent when publishing to a social media platform.
@objcMembers
public class PublishOptionItem: VIMModelObject {

    /// The ID of the publish item.
    public private(set) var identifier: String?

    /// The name or display name of the publish item, i.e.: "art", "family", "vacation" etc.
    public private(set) var name: String?

    // MARK: - Overrides

    public override func getObjectMapping() -> Any? {
        return [
            Constants.Key.identifier: Constants.Value.identifier,
        ]
    }
}

/// A `ConnectedApp` represents a connection to a social media platform. Some activities, like simultaneously live
/// stream to multiple destinations, or publishing across platforms, require requesting specific scopes. The scopes
/// required will always be returned in the `neededScopes` array.
/// - Note: Some properties are specific to a particular platform. These cases have been noted in the documentation
///         where relevant.
@objcMembers
public class ConnectedApp: VIMModelObject {

    /// The date when the user established this connected app, as a String.
    /// - Note: This property is available to provide interoperability with Objective-C codebases.
    ///         Using `addDate` is preferred.
    public private(set) var addDateString: String?

    /// The date when the user established this connected app.
    public private(set) var addDate: Date?

    /// Facebook only. A value of 1 maps to expired data access. A value of 0 maps to having data access.
    /// - Note: This is an internal property. Use `isDataAccessExpired` instead.
    internal private(set) var dataAccessIsExpired: NSNumber?

    /// Returns whether the user's data access has expired.
    /// - Note: Facebook only. Will always return false if the `ConnectedAppType` is not `.facebook`.
    @nonobjc public lazy var isDataAccessExpired: Bool = {
        guard self.type == .facebook else { return false }
        return self.dataAccessIsExpired?.intValue != 0
    }()

    /// The list of remaining scopes on this connected app that the user needs for a particular Vimeo feature.
    public private(set) var neededScopes: ConnectedAppScopes?

    /// The list of third party pages associated with the user's account.
    /// - Note: Facebook and LinkedIn only.
    public private(set) var pages: [PublishOptionItem]?

    /// The list of third party categories that can be selected when publishing to a social media platform.
    /// - Note: Facebook and YouTube only.
    public private(set) var publishCategories: [PublishOptionItem]?

    /// The resource key string of the connected app.
    public private(set) var resourceKey: String?

    /// The unique identifier for the user on this connected app.
    public private(set) var thirdPartyUserID: String?

    /// The user's display name on this connected app.
    public private(set) var thirdPartyUserDisplayName: String?

    /// The type of the connected app, as a String.
    /// - Note: This property is available to provide interoperability with Objective-C codebases.
    ///         Using `type` is preferred.
    public private(set) var typeString: String?

    /// The type of the connected app.
    /// - Note: A returned value of `nil` indicates an unsupported `ConnectedAppType`, or a malformed response.
    @nonobjc public var type: ConnectedAppType? {
        typeString.map { ConnectedAppType.init(rawValue: $0) } ?? nil
    }

    /// The API URI of this connected app.
    public private(set) var uri: String?

    // MARK: - Overrides

    public override func getClassForObjectKey(_ key: String?) -> AnyClass? {
        switch key {
        case Constants.Key.neededScopes:
            return ConnectedAppScopes.self
        default:
            return nil
        }
    }

    public override func getObjectMapping() -> Any? {
        return [
            Constants.Key.addDate: Constants.Value.addDate,
            Constants.Key.dataAccessIsExpired: Constants.Value.dataAccessIsExpired,
            Constants.Key.publishCategories: Constants.Value.publishCategories,
            Constants.Key.thirdPartyUserID: Constants.Value.thirdPartyUserID,
            Constants.Key.thirdPartyUserDisplayName: Constants.Value.thirdPartyUserDisplayName,
            Constants.Key.type: Constants.Value.type
        ]
    }

    public override func getClassForCollectionKey(_ key: String?) -> AnyClass? {
        switch key {
        case Constants.Key.publishCategories:
            return PublishOptionItem.self
        case Constants.Key.pages:
            return PublishOptionItem.self
        default:
            return nil
        }
    }

    public override func didFinishMapping() {
        self.addDate = self.formatDate(from: self.addDateString)
    }

    // MARK: - Private

    private func formatDate(from dateString: String?) -> Date? {
        guard let dateString = dateString,
            let date = VIMModelObject.dateFormatter().date(from: dateString) else {
                return nil
        }
        return date
    }
}

public extension String {
    static let facebook = "facebook"
    static let linkedin = "linkedin"
    static let twitter = "twitter"
    static let youtube = "youtube"
}

private struct Constants {
    struct Key {
        static let addDate = "add_date"
        static let dataAccessIsExpired = "data_access_is_expired"
        static let identifier = "id"
        static let neededScopes = "needed_scopes"
        static let pages = "pages"
        static let publishCategories = "publish_categories"
        static let publishToSocial = "publish_to_social"
        static let resourceKey = "resource_key"
        static let thirdPartyUserID = "third_party_user_id"
        static let thirdPartyUserDisplayName = "third_party_user_display_name"
        static let type = "type"
    }

    struct Value {
        static let addDate = "addDateString"
        static let dataAccessIsExpired = "dataAccessIsExpired"
        static let identifier = "identifier"
        static let neededScopes = "neededScopes"
        static let publishCategories = "publishCategories"
        static let publishToSocial = "publishToSocial"
        static let resourceKey = "resourceKey"
        static let thirdPartyUserID = "thirdPartyUserID"
        static let thirdPartyUserDisplayName = "thirdPartyUserDisplayName"
        static let type = "typeString"
    }
}
