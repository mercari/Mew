//
//  TableViewHeaderFooterView.swift
//  Mew
//
//  Created by tarunon on 2018/06/07.
//  Copyright © 2018 Mercari. All rights reserved.
//

import UIKit

/// Common Generics TableViewHeaderFooterView.
/// T should be `UIViewController & Injecatble & Instantiatable`
/// ```
/// // Register for tableView
/// TableViewHeaderFooterView<MyViewController>.register(to: tableView)
/// 
/// // Dequeue from tableView
/// let view = TableViewHeaderFooterView<MyViewController>.dequeued(
///   from: tableView,
///   input: headers[section],
///   parentViewController: self
/// )
/// ```
public class TableViewHeaderFooterView<T: UIViewController>: UITableViewHeaderFooterView, TableViewCellProtocol {
    public typealias Content = T

    public var content: T {
        return contentViewController!
    }

    internal weak var parentViewController: UIViewController?
    var contentViewController: T?

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        _willMove(to: newSuperview)
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        _didMoveToSuperview()
    }
}

public extension TableViewHeaderFooterView {
    /// Register dequeueable header/footer class for tableView
    ///
    /// - Parameter tableView: Parent tableView
    public static func register(to tableView: UITableView) {
        tableView.register(TableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }
}

public extension TableViewHeaderFooterView where T: Injectable, T: Instantiatable {
    /// Dequeue header/footer instance from tableView
    ///
    /// - Parameters:
    ///   - tableView: Parent tableView that must have registered header/footer.
    ///   - input: The ViewController's input.
    ///   - parentViewController: ParentViewController that must has tableView.
    /// - Returns: The header/footer instance that added the ViewController.view, and the ViewController have injected dependency, VC hierarchy.
    public static func dequeued<V>(from tableView: UITableView, input: T.Input, parentViewController: V) -> TableViewHeaderFooterView where V: UIViewController, V: Instantiatable, T.Environment == V.Environment {
        // Swift4.1 has bug that `Cast from 'X' to unrelated type 'Y<T>' always fails` if T is class and has protocol condition.
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewHeaderFooterView.reuseIdentifier) as Any as! TableViewHeaderFooterView
        if view.contentViewController == nil {
            view.addViewController(T.instantiate(input, environment: parentViewController.environment), parentViewController: parentViewController)
        } else {
            view.contentViewController?.input(input)
        }
        return view
    }
}

public extension TableViewHeaderFooterView where T: Injectable, T: Instantiatable, T: Interactable {
    /// Dequeue header/footer instance from tableView
    ///
    /// - Parameters:
    ///   - tableView: Parent tableView that must have registered header/footer.
    ///   - input: The ViewController's input.
    ///   - output: Handler for ViewController's output. Start handling when cell init. Don't replace handler when cell reused.
    ///   - parentViewController: ParentViewController that must has tableView.
    /// - Returns: The header/footer instance that added the ViewController.
    public static func dequeued<V>(from tableView: UITableView, input: T.Input, output: ((T.Output) -> ())?, parentViewController: V) -> TableViewHeaderFooterView where V: UIViewController, V: Instantiatable, T.Environment == V.Environment {
        // Swift4.1 has bug that `Cast from 'X' to unrelated type 'Y<T>' always fails` if T is class and has protocol condition.
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewHeaderFooterView.reuseIdentifier) as Any as! TableViewHeaderFooterView
        if view.contentViewController == nil {
            view.addViewController(T.instantiate(input, environment: parentViewController.environment), parentViewController: parentViewController)
            view.contentViewController?.output(output)
        } else {
            view.contentViewController?.input(input)
        }
        return view
    }
}
