//
//  CollectionReusableView.swift
//  Mew
//
//  Created by tarunon on 2018/07/13.
//  Copyright © 2018 Mercari. All rights reserved.
//

import UIKit

public enum CollectionViewSupplementaryKind {
    case header
    case footer

    var rawValue: String {
        switch self {
        case .header: return UICollectionElementKindSectionHeader
        case .footer: return UICollectionElementKindSectionFooter
        }
    }
}

/// Common Generics CollectionReusableView.
/// T should be `UIView & Injectable & Instantiatable` or `UIViewController & Injecatble & Instantiatable`
/// ```
/// // Register for collectionView
/// CollectionReusableView<MyViewController>.register(to: collectionView, for: .header)
///
/// // Dequeue from collectionView
/// let view = CollectionReusableView<MyViewController>.dequeued(
///   from: collectionView,
///   of: kind,
///   for: indexPath,
///   input: headers[indexPath.section],
///   parentViewController: self
/// )
/// ```
public class CollectionReusableView<T: UIViewController>: UICollectionReusableView, CollectionViewCellProtocol {
    typealias Content = T

    public var content: T {
        return contentViewController!
    }

    internal weak var parentViewController: UIViewController?
    internal var sizeConstraint: SizeConstraint.Calculated?
    var contentViewController: T?
    var contentView: UIView {
        return self
    }

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

public extension CollectionReusableView {
    /// Register dequeueable cell class for collectionView
    ///
    /// - Parameter collectionView: Parent collectionView
    public static func register(to collectionView: UICollectionView, for kind: CollectionViewSupplementaryKind) {
        collectionView.register(CollectionReusableView.self, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: reuseIdentifier)
    }
}

public extension CollectionReusableView where T: Injectable, T: Instantiatable {
    /// Dequeue cell instance from collectionView
    ///
    /// - Parameters:
    ///   - collectionView: Parent collectionView that must have registered cell.
    ///   - indexPath: indexPath for dequeue.
    ///   - input: The ViewController's input.
    ///   - sizeConstraint: Requirement maximum size of Cell.
    ///   - parentViewController: ParentViewController that must has collectionView.
    /// - Returns: The Cell instance that added the ViewController.view, and the ViewController have injected dependency, VC hierarchy.
    public static func dequeued<V>(from collectionView: UICollectionView, of kind: String, for indexPath: IndexPath, input: T.Input, sizeConstraint: SizeConstraint? = nil, parentViewController: V) -> CollectionReusableView where V: UIViewController, V: Instantiatable, T.Environment == V.Environment {
        // Swift4.1 has bug that `Cast from 'X' to unrelated type 'Y<T>' always fails` if T is class and has protocol condition.
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionReusableView.reuseIdentifier, for: indexPath) as Any as! CollectionReusableView
        if cell.contentViewController == nil {
            cell.addViewController(T.instantiate(input, environment: parentViewController.environment), parentViewController: parentViewController)
        } else {
            cell.contentViewController?.input(input)
        }
        cell.updateSizeConstraint(sizeConstraint ?? SizeConstraint.automaticDimension(collectionView.collectionViewLayout))
        return cell
    }
}

public extension CollectionReusableView where T: Injectable, T: Instantiatable, T: Interactable {
    /// Dequeue cell instance from collectionView
    ///
    /// - Parameters:
    ///   - collectionView: Parent collectionView that must have registered cell.
    ///   - indexPath: indexPath for dequeue.
    ///   - input: The ViewController's input.
    ///   - output: Handler for ViewController's output. Start handling when cell init. Don't replace handler when cell reused.
    ///   - sizeConstraint: Requirement maximum size of Cell.
    ///   - parentViewController: ParentViewController that must has collectionView.
    /// - Returns: The header/footer instance that added the ViewController.
    public static func dequeued<V>(from collectionView: UICollectionView, of kind: String, for indexPath: IndexPath, input: T.Input, output: ((T.Output) -> ())?, sizeConstraint: SizeConstraint? = nil, parentViewController: V) -> CollectionReusableView where V: UIViewController, V: Instantiatable, T.Environment == V.Environment {
        // Swift4.1 has bug that `Cast from 'X' to unrelated type 'Y<T>' always fails` if T is class and has protocol condition.
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionReusableView.reuseIdentifier, for: indexPath) as Any as! CollectionReusableView
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
