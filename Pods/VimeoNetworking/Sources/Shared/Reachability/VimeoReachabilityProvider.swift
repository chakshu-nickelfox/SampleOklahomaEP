//
//  VimeoReachabilityProvider.swift
//  Vimeo
//
//  Copyright © 2019 Vimeo. All rights reserved.
//

import Foundation

public enum VimeoReachabilityProvider {
    
    /// The shared reachability manager used to listen to reachability changes
    ///
    /// Upon initialization, this reachability manager immediately starts listening
    /// for reachability changes and broadcasts them via system notification to
    /// interested subscribers.
    internal static let reachabilityManager: ReachabilityManaging? = {
        let manager = NetworkReachabilityManager.default
        manager?.startListening { _ in
            NetworkingNotification.reachabilityDidChange.post(object: nil)
        }
        return manager
    }()
}

// MARK: - Convenience

// This extension exposes reachability flags and assumes pessimistic default values
// for cases where the reachability manager cannot be unwrapped. This is to allow
// consistency of usage across all the consumers of this API.
extension VimeoReachabilityProvider {

    /// Whether the network is currently reachable. Defaults to false if no reachabilityManager is available.
    public static var isReachable: Bool {
        return VimeoReachabilityProvider.reachabilityManager?.isReachable ?? false
    }

    /// Whether the network is currently reachable via celullar. Defaults to false if no reachabilityManager is available.
    public static var isReachableOnCellular: Bool {
        return VimeoReachabilityProvider.reachabilityManager?.isReachableOnCellular ?? false
    }

    /// Whether the network is currently reachable via ethernet or wifi. Defaults to false if no reachabilityManager is available.
    public static var isReachableOnEthernetOrWiFi: Bool {
        return VimeoReachabilityProvider.reachabilityManager?.isReachableOnEthernetOrWiFi ?? false
    }

}
