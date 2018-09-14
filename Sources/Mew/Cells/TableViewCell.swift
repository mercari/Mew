//
//  TableViewCell.swift
//  Mew
//
//  Created by tarunon on 2018/04/04.
//  Copyright © 2018 Mercari. All rights reserved.
//

import UIKit

/// Common Generics TableViewCell with ViewController.
/// T should be `UIViewController & Injecatble & Instantiatable`
/// ```
/// // Register for tableView
/// TableViewCell<MyViewController>.register(to: tableView)
///
/// // Dequeue from tableView
/// let cell = TableViewCell<MyViewController>.dequeued(
///    from: tableView,
///    for: indexPath,
///    input: elements[indexPath.row],
///    parentViewController: self
/// )
/// ```
public class TableViewCell<T: UIViewController>: UITableViewCell, TableViewCellProtocol {
    typealias Content = T
    public var content: T {
        return contentViewController!
    }

    internal weak var parentViewController: UIViewController?
    var contentViewController: T?

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        _willMove(to: newSuperview)
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        _didMoveToSuperview()
    }
}

public extension TableViewCell {
    /// Register dequeueable cell class for tableView
    ///
    /// - Parameter tableView: Parent tableView
    public static func register(to tableView: UITableView) {
        tableView.register(TableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

public extension TableViewCell where T: Injectable, T: Instantiatable {
    /// Dequeue cell instance from tableView
    ///
    /// - Parameters:
    ///   - tableView: Parent tableView that must have registered cell.
    ///   - indexPath: indexPath for dequeue.
    ///   - input: The ViewController's input.
    ///   - parentViewController: ParentViewController that must has tableView.
    /// - Returns: The Cell instance that added the ViewController.view, and the ViewController have injected dependency, VC hierarchy.
    public static func dequeued<V>(from tableView: UITableView, for indexPath: IndexPath, input: T.Input, parentViewController: V) -> TableViewCell where V: UIViewController, V: Instantiatable, T.Environment == V.Environment {
        // Swift4.1 has bug that `Cast from 'X' to unrelated type 'Y<T>' always fails` if T is class and has protocol condition.
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.reuseIdentifier, for: indexPath) as Any as! TableViewCell
        if cell.contentViewController == nil {
            cell.addViewController(T.instantiate(input, environment: parentViewController.environment), parentViewController: parentViewController)
            cell.selectionStyle = .none
        } else {
            cell.contentViewController?.input(input)
        }
        return cell
    }
}

public extension TableViewCell where T: Injectable, T: Instantiatable, T: Interactable {
    /// Dequeue cell instance from tableView
    ///
    /// - Parameters:
    ///   - tableView: Parent tableView that must have registered cell.
    ///   - indexPath: indexPath for dequeue.
    ///   - input: The ViewController's input.
    ///   - output: Handler for ViewController's output. Start handling when cell init. Don't replace handler when cell reused.
    ///   - parentViewController: ParentViewController that must has tableView.
    /// - Returns: The Cell instance that added the ViewController.
    public static func dequeued<V>(from tableView: UITableView, for indexPath: IndexPath, input: T.Input, output: ((T.Output) -> ())?, parentViewController: V) -> TableViewCell where V: UIViewController, V: Instantiatable, T.Environment == V.Environment {
        // Swift4.1 has bug that `Cast from 'X' to unrelated type 'Y<T>' always fails` if T is class and has protocol condition.
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.reuseIdentifier, for: indexPath) as Any as! TableViewCell
        if cell.contentViewController == nil {
            cell.addViewController(T.instantiate(input, environment: parentViewController.environment), parentViewController: parentViewController)
            cell.selectionStyle = .none
            cell.contentViewController?.output(output)
        } else {
            cell.contentViewController?.input(input)
        }
        return cell
    }
}
