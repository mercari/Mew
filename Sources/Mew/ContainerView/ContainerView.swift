//
//  ContainerView.swift
//  Mew
//
//  Created by tarunon on 2018/04/02.
//  Copyright © 2018 Mercari. All rights reserved.
//

import UIKit

/// A view that makes it easier to deal with UIViewControllers by splitting them up into smaller pieces.
/// This helps to avoid monolithic ViewControllers and complicated Interface Builder files.
@IBDesignable
public class ContainerView: UIStackView {
    /// Height anchor that available in InterfaceBuilder.
    @IBInspectable
    public var estimatedHeight: CGFloat = -1

    /// Width anchor that available in InterfaceBuilder.
    @IBInspectable
    public var estimatedWidth: CGFloat = -1

    var latestAddedContainer: ContainerViewContainerProtocol?

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        let interfaceBuilderView = _ContainerInterfaceBuilderView.instantiate(with: (estimatedWidth, estimatedHeight))
        addArrangedSubview(interfaceBuilderView)
        if estimatedHeight >= 0 {
            interfaceBuilderView.heightAnchor.constraint(equalToConstant: estimatedHeight).isActive = true
        }
        if estimatedWidth >= 0 {
            interfaceBuilderView.widthAnchor.constraint(equalToConstant: estimatedWidth).isActive = true
        }
    }

    /// The viewController will be added as a childViewController of parentViewController that has self (`ContainerView`)
    /// When calling this function arbitrarily, arranged of ViewController by container is not guaranteed.
    public func addArrangedViewController(_ viewController: UIViewController, parentViewController: UIViewController) {
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        parentViewController.addChild(viewController)
        addArrangedSubview(viewController.view)
        viewController.didMove(toParent: parentViewController)
    }

    /// The viewController will be inserted at the specified index as a childViewController of parentViewController that self (`ContainerView`)
    /// When calling this function arbitrarily, arranged of ViewController by container is not guaranteed.
    public func insertArrangedViewController(_ viewController: UIViewController, stackIndex: Int, parentViewController: UIViewController) {
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        parentViewController.addChild(viewController)
        insertArrangedSubview(viewController.view, at: stackIndex)
        viewController.didMove(toParent: parentViewController)
    }

    /// The viewController will be removed from self (`ContainerView`)
    /// When calling this function arbitrarily, arranged of ViewController by container is not guaranteed.
    public func removeArrangedViewController(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        removeArrangedSubview(viewController.view)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}

/// Supports making `ContainerView` in `Interface Builder`.
internal class _ContainerInterfaceBuilderView: UIView, Injectable {
    var estimatedWidth: CGFloat = -1 {
        didSet {
            horizontalLabels.forEach { $0.isHidden = estimatedWidth < 0 }
            updateBackgroundColor()
        }
    }

    var estimatedHeight: CGFloat = -1 {
        didSet {
            verticalLabels.forEach { $0.isHidden = estimatedHeight < 0 }
            updateBackgroundColor()
        }
    }

    @IBOutlet var horizontalLabels: [UIView]!
    @IBOutlet var verticalLabels: [UIView]!

    private func updateBackgroundColor() {
        if estimatedWidth >= 0 {
            if estimatedHeight >= 0 {
                backgroundColor = #colorLiteral(red: 0.3882352941, green: 0.8549019608, blue: 0.2196078431, alpha: 1)
            } else {
                backgroundColor = #colorLiteral(red: 1, green: 0.1607843137, blue: 0.4078431373, alpha: 1)
            }
        } else {
            if estimatedHeight >= 0 {
                backgroundColor = #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 1)
            } else {
                backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            }
        }
    }

    internal func input(_ value: (estimatedWidth: CGFloat, estimatedHeight: CGFloat)) {
        estimatedWidth = value.estimatedWidth
        estimatedHeight = value.estimatedHeight
    }

    static var nib: UINib {
        return UINib(nibName: "_ContainerInterfaceBuilderView", bundle: Bundle(for: _ContainerInterfaceBuilderView.self))
    }

    static func instantiate(with input: Input) -> _ContainerInterfaceBuilderView {
        let view = nib.instantiate(withOwner: nil, options: nil).first! as! _ContainerInterfaceBuilderView
        view.input(input)
        return view
    }
}
