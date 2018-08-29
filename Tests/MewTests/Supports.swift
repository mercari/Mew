//
//  Supports.swift
//  MewTests
//
//  Created by tarunon on 2018/08/29.
//  Copyright © 2018 Mercari. All rights reserved.
//

import UIKit

extension UIView {
    private static func contains(_ view: UIView, where condition: (UIView) -> Bool) -> Bool {
        if condition(view) { return true }
        return view.subviews.contains(where: { contains($0, where: condition) })
    }

    public func subviewTreeContains(with view: UIView) -> Bool {
        return UIView.contains(self, where: { $0 === view })
    }

    public func subviewTreeContains(where condition: (UIView) -> Bool) -> Bool {
        return UIView.contains(self, where: condition)
    }

    /// addSubview and add constraints/resizingMasks that make frexible size.
    public func addSubviewFrexibleSize(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        if translatesAutoresizingMaskIntoConstraints {
            subview.frame = bounds
            addSubview(subview)
            subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        } else {
            addSubview(subview)
            NSLayoutConstraint.activate(
                [
                    subview.topAnchor.constraint(equalTo: topAnchor),
                    subview.leftAnchor.constraint(equalTo: leftAnchor),
                    subview.rightAnchor.constraint(equalTo: rightAnchor),
                    subview.bottomAnchor.constraint(equalTo: bottomAnchor)
                ]
            )
        }
    }
}
