//
//  Interactable.swift
//  MercariKit
//
//  Created by tarunon on 2018/04/02.
//  Copyright © 2018 Mercari. All rights reserved.
//

/// A protocol to allow others to listen to emitted events. Events are emitted as a result of user interactions, API calls, etc.
/// Implement either handler or continuous endpoint
///
/// ## associatedtype Output
/// `Output` should be a "value type" such as `struct` or `enum`.
/// It is recommended to define `Output` for each `Interactable` class.
public protocol Interactable {
    associatedtype Output
    func output(_ handler: ((Output) -> Void)?)
}
