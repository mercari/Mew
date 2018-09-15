//
//  Container.swift
//  Mew
//
//  Created by tarunon on 2018/08/14.
//  Copyright © 2018 Mercari. All rights reserved.
//

import UIKit

protocol ContainerViewContainerProtocol {
    var insertIndex: Int { get }
    var prev: ContainerViewContainerProtocol? { get }
}

extension ContainerView {
    /// Lazy given generics for ContainerView
    /// - Content: ViewController / ViewControllerResponseWrapper<ViewControllerRequest>
    /// - Parent: The parentViewController
    /// It will support Injectable/Interactable if Content is support it.
    /// e.g. )
    /// ```
    /// @IBOutlet weak var myContainerView: ContainerView!
    /// lazy var myViewContorllerContainer = myContainerView.makeContainer(for: MyViewController.self, parent: self)
    /// ...
    /// func updateMyViewController(input: MyViewController.Input) {
    ///    myViewControllerContainer.input(input)
    /// }
    /// ```
    /// Container have virtual section initialized order.
    /// We can add multi `type` viewController in 1 ContainerView.
    public final class Container<Content, Parent>: ContainerViewContainerProtocol where
        Parent: Instantiatable,
        Parent: UIViewController,
        Content: Instantiatable,
        Content: UIViewController,
        Parent.Environment == Content.Environment  {
        var contents: [Content] = [] {
            didSet {
                contentsHandler?(contents)
            }
        }
        var contentsHandler: (([Content]) -> ())?
        var prev: ContainerViewContainerProtocol?
        weak var base: ContainerView?
        weak var parentViewController: Parent?

        var insertIndex: Int {
            return (prev?.insertIndex ?? 0) + contents.count
        }

        init(base: ContainerView, parentViewController: Parent) {
            self.base = base
            self.parentViewController = parentViewController
            self.prev = base.latestAddedContainer
            base.latestAddedContainer = self
        }
    }
}

extension ContainerView.Container: Injectable where Content: Injectable {
    public typealias Input = Content.Input?
    public typealias Inputs = [Content.Input]
    /// Inputing 1 value and make 1 viewContorller or removing
    /// - Parameter input: Optional value of viewController input. If it nil, viewController will be deallocated.
    public func input(_ input: Input) {
        inputs([input].compactMap { $0 })
    }

    /// Inputling multiple values and make some viewControllers or removing.
    /// - Parameter inputs: Array value of viewController input.
    public func inputs(_ inputs: Inputs) {
        guard let parentViewController = parentViewController, let base = base else { return }
        zip(contents, inputs)
            .forEach { viewController, input in
                viewController.input(input)
        }

        if inputs.count < contents.count {
            let range = inputs.count..<contents.count
            contents[range]
                .forEach { viewController in
                    base.removeArrangedViewController(viewController)
            }
            contents.removeSubrange(range)
        }

        if contents.count < inputs.count {
            inputs[contents.count..<inputs.count]
                .forEach { input in
                    let viewController = Content.instantiate(input, environment: parentViewController.environment)
                    base.insertArrangedViewController(viewController, stackIndex: insertIndex, parentViewController: parentViewController)
                    contents.append(viewController)
            }
        }
    }
}

extension ContainerView.Container: Interactable where Content: Interactable {
    public typealias Output = Content.Output

    /// The output values that including all contained viewControllers output.
    public func output(_ handler: ((Content.Output) -> Void)?) {
        var latestHandleIndex = 0
        func update(_ contents: [Content]) {
            if latestHandleIndex < contents.count {
                contents.suffix(from: latestHandleIndex).forEach { $0.output(handler) }
            }
            latestHandleIndex = contents.count
        }
        contentsHandler = { contents in
            update(contents)
        }
        update(contents)
    }
}

extension ContainerView {

    /// Make container for Instantiatable ViewController
    /// Each views are arranged in order of Container creation.
    /// 
    /// - Parameters:
    ///   - viewController: The ViewController instance
    ///   - parent: Parent viewController
    /// - Returns: The container for viewController
    @discardableResult
    public func makeContainer<ViewController, Parent>(for type: ViewController.Type, parentViewController: Parent, with input: ViewController.Input)
        -> Container<ViewController, Parent>
        where ViewController: UIViewController,
        ViewController: Instantiatable {
            let container = Container<ViewController, Parent>(base: self, parentViewController: parentViewController)
            let viewController = ViewController.instantiate(input, environment: parentViewController.environment)
            insertArrangedViewController(viewController, stackIndex: container.insertIndex, parentViewController: parentViewController)
            container.contents = [viewController]
            return container
    }

    /// Make container for Instantiatable and Injectable ViewController
    /// Each views are arranged in order of Container creation.
    ///
    /// - Parameters:
    ///   - type: The ViewController's type
    ///   - parent: Parent viewController
    /// - Returns: The container for ViewController type
    public func makeContainer<ViewController, Parent>(for type: ViewController.Type, parentViewController: Parent)
        -> Container<ViewController, Parent>
        where ViewController: UIViewController,
        ViewController: Instantiatable,
        ViewController: Injectable {
            return Container(base: self, parentViewController: parentViewController)
    }
}

extension ContainerView {
    @discardableResult
    @available(*, deprecated, renamed: "makeContainer(for:parentViewController:with:)")
    public func makeContainer<ViewController, Parent>(for type: ViewController.Type, parent: Parent, with input: ViewController.Input) -> Container<ViewController, Parent>
        where ViewController: UIViewController,
        ViewController: Instantiatable {
            return makeContainer(for: type, parentViewController: parent, with: input)
    }

    @available(*, deprecated, renamed: "makeContainer(for:parentViewController:)")
    public func makeContainer<ViewController, Parent>(for type: ViewController.Type, parent: Parent)
        -> Container<ViewController, Parent>
        where ViewController: UIViewController,
        ViewController: Instantiatable,
        ViewController: Injectable {
            return makeContainer(for: type, parentViewController: parent)
    }
}
