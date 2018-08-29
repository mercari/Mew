//
//  Injectable.swift
//  MercariKit
//
//  Created by tarunon on 2018/04/02.
//  Copyright © 2018 Mercari. All rights reserved.
//

/// A protocol to allow updating of a MicroViewController's input.
/// A class that conforms to Injectable becomes "mutable".
///
/// ## associatedtype Input
/// `Input` should be a "value type" such as `struct` or `enum`.
/// It is recommended to define `Input` for each `Injectable` class.
///
/// `Input` can be shared with `Instantiatable.Input`.
///
/// If you want to implement completion handlers, please use `Interactable` instead.
public protocol Injectable {
    associatedtype Input
    func input(_ input: Input)
}

public extension Injectable where Input == Void {
    public func input(_ input: Input) {

    }
}
