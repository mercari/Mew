//
//  CollectionViewCell.swift
//  Mew
//
//  Created by tarunon on 2018/04/04.
//  Copyright © 2018 Mercari. All rights reserved.
//

import UIKit

/// Common Generics CollectionViewCell.
/// T should be `UIView & Injectable & Instantiatable` or `UIViewController & Injecatble & Instantiatable`
/// ```
/// // Register for collectionView
/// CollectionViewCell<MyViewController>.register(to: collectionView)
///
/// // Dequeue from collectionView
/// let cell = CollectionViewCell<MyViewController>.dequeued(
///   from: collectionView,
///   for: indexPath,
///   input: elements[indexPath.item],
///   parentViewController: self
/// )
/// ```
public class CollectionViewCell<T: UIViewController>: UICollectionViewCell, CollectionViewCellProtocol {
    typealias Content = T

    public var content: T {
        return contentViewController!
    }

    internal weak var parentViewController: UIViewController?
    internal var sizeConstraint: SizeConstraint.Calculated?
    var contentViewController: T?

    internal lazy var maxWidthConstraint: NSLayoutConstraint = self.contentViewController!.view.widthAnchor.constraint(lessThanOrEqualToConstant: 0.0)
    internal lazy var maxHeightConstraint: NSLayoutConstraint = self.contentViewController!.view.heightAnchor.constraint(lessThanOrEqualToConstant: 0.0)



    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        _willMove(to: newSuperview)
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        _didMoveToSuperview()
    }
}

public extension CollectionViewCell {
    /// Register dequeueable cell class for collectionView
    ///
    /// - Parameter collectionView: Parent collectionView
    public static func register(to collectionView: UICollectionView) {
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

public extension CollectionViewCell where T: Injectable, T: Instantiatable {
    /// Dequeue cell instance from collectionView
    ///
    /// - Parameters:
    ///   - collectionView: Parent collectionView that must have registered cell.
    ///   - indexPath: indexPath for dequeue.
    ///   - input: The ViewController's input.
    ///   - sizeConstraint: Requirement maximum size of Cell.
    ///   - parentViewController: ParentViewController that must has collectionView.
    /// - Returns: The Cell instance that added the ViewController.view, and the ViewController have injected dependency, VC hierarchy.
    public static func dequeued<V>(from collectionView: UICollectionView, for indexPath: IndexPath, input: T.Input, sizeConstraint: SizeConstraint? = nil, parentViewController: V) -> CollectionViewCell where V: UIViewController, V: Instantiatable, T.Environment == V.Environment {
        // Swift4.1 has bug that `Cast from 'X' to unrelated type 'Y<T>' always fails` if T is class and has protocol condition.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reuseIdentifier, for: indexPath) as Any as! CollectionViewCell
        if cell.contentViewController == nil {
            cell.addViewController(T.instantiate(input, environment: parentViewController.environment), parentViewController: parentViewController)
        } else {
            cell.contentViewController?.input(input)
        }
        cell.updateSizeConstraint(sizeConstraint ?? SizeConstraint.automaticDimension(collectionView.collectionViewLayout))
        return cell
    }
}

public extension CollectionViewCell where T: Injectable, T: Instantiatable, T: Interactable {
    /// Dequeue cell instance from collectionView
    ///
    /// - Parameters:
    ///   - collectionView: Parent collectionView that must have registered cell.
    ///   - indexPath: indexPath for dequeue.
    ///   - input: The ViewController's input.
    ///   - output: Handler for ViewController's output. Start handling when cell init. Don't replace handler when cell reused.
    ///   - sizeConstraint: Requirement maximum size of Cell.
    ///   - parentViewController: ParentViewController that must has collectionView.
    /// - Returns: The Cell instance that added the ViewController.
    public static func dequeued<V>(from collectionView: UICollectionView, for indexPath: IndexPath, input: T.Input, output: ((T.Output) -> Void)?, sizeConstraint: SizeConstraint? = nil, parentViewController: V) -> CollectionViewCell where V: UIViewController, V: Instantiatable, T.Environment == V.Environment  {
        // Swift4.1 has bug that `Cast from 'X' to unrelated type 'Y<T>' always fails` if T is class and has protocol condition.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reuseIdentifier, for: indexPath) as Any as! CollectionViewCell
        if cell.contentViewController == nil {
            cell.addViewController(T.instantiate(input, environment: parentViewController.environment), parentViewController: parentViewController)
            cell.contentViewController?.output(output)
        } else {
            cell.contentViewController?.input(input)
        }
        cell.updateSizeConstraint(sizeConstraint ?? SizeConstraint.automaticDimension(collectionView.collectionViewLayout))
        return cell
    }
}
