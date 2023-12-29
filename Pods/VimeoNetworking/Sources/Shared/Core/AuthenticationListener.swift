//
//  AuthenticationListener.swift
//  VimeoNetworking
//
//  Created by Rogerio de Paula Assis on 10/16/19.
//  Copyright © 2019 Vimeo. All rights reserved.
//

import Foundation

/// A type that listens to and responds to authentication status changes
public protocol AuthenticationListener {

    /// Called when authentication completes successfully
    /// - Parameter account: the new authenticated account
    func clientDidAuthenticate(with account: VIMAccount)

    /// Called when a client is logged out
    func clientDidClearAccount()
}
