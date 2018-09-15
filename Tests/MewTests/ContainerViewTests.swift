//
//  ContainerViewTests.swift
//  MercariKitTests
//
//  Created by tarunon on 2018/04/02.
//  Copyright © 2018 Mercari. All rights reserved.
//

import XCTest
@testable import Mew

var resourceCount = 0

class ContainerViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        XCTAssertEqual(resourceCount, 0)
    }

    class ResourceContingViewController: UIViewController {
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            resourceCount += 1
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            resourceCount += 1
        }

        deinit {
            resourceCount -= 1
        }
    }

    // MARK: - Tests for `IBDesignable`

    func testPrepareForInterfaceBuilder() {
        do {
            let view = ContainerView()
            view.prepareForInterfaceBuilder()
            XCTAssert(view.subviewTreeContains { $0 is _ContainerInterfaceBuilderView })
        }

        do {
            let view = ContainerView()
            view.estimatedWidth = 100
            view.prepareForInterfaceBuilder()
            XCTAssert(view.subviewTreeContains { $0.constraints.contains { $0.firstAttribute == NSLayoutAttribute.width && $0.constant == 100 } })
        }

        do {
            let view = ContainerView()
            view.estimatedHeight = 100
            view.prepareForInterfaceBuilder()
            XCTAssert(view.subviewTreeContains { $0.constraints.contains { $0.firstAttribute == NSLayoutAttribute.height && $0.constant == 100 } })
        }
    }

    // MARK: - Tests for `Container`

    final class ContainerViewController: ResourceContingViewController, Instantiatable {
        let environment: Void
        let containerView = ContainerView()

        init(with input: Void, environment: Void) {
            self.environment = environment
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError()
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(containerView)
        }
    }

    func testMakeContainerForInstantiatable() {
        final class ContainedViewController: ResourceContingViewController, Instantiatable {
            let environment: Void

            init(with input: Int, environment: Void) {
                self.environment = environment
                super.init(nibName: nil, bundle: nil)
            }

            required init?(coder aDecoder: NSCoder) {
                fatalError()
            }
        }

        let viewController = ContainerViewController(with: (), environment: ())
        let container1 = viewController.containerView.makeContainer(for: ContainedViewController.self, parentViewController: viewController, with: 1)
        XCTAssertEqual(container1.insertIndex, 1)
        XCTAssertTrue(viewController.childViewControllers.contains(where: { $0 is ContainedViewController }))
    }

    func testContainerForInjectable() {
        final class ContainedView: UIView {
            var param: Int = 0
        }
        final class ContainedViewController: ResourceContingViewController, Instantiatable, Injectable {
            let environment: Void
            lazy var _view: ContainedView = {
                let view = ContainedView()
                self.view = view
                return view
            }()
            init(with input: Int, environment: Void) {
                self.environment = environment
                super.init(nibName: nil, bundle: nil)
                _view.param = input
            }

            required init?(coder aDecoder: NSCoder) {
                fatalError()
            }

            func input(_ input: Int) {
                _view.param = input
            }
        }

        let viewController = ContainerViewController(with: (), environment: ())

        let container1 = viewController.containerView.makeContainer(for: ContainedViewController.self, parentViewController: viewController)
        let container2 = viewController.containerView.makeContainer(for: ContainedViewController.self, parentViewController: viewController)
        let container3 = viewController.containerView.makeContainer(for: ContainedViewController.self, parentViewController: viewController)

        XCTAssertEqual(viewController.containerView.arrangedSubviews.count, 0)
        XCTAssertEqual(viewController.childViewControllers.count, 0)

        container1.inputs([1, 2, 3])

        XCTAssertEqual(viewController.containerView.arrangedSubviews.count, 3)
        XCTAssertEqual(viewController.childViewControllers.count, 3)
        XCTAssertEqual(viewController.containerView.arrangedSubviews.map { $0 as! ContainedView }.map { $0.param }, [1, 2, 3])

        container2.inputs([4, 5, 6])

        XCTAssertEqual(viewController.containerView.arrangedSubviews.count, 6)
        XCTAssertEqual(viewController.childViewControllers.count, 6)
        XCTAssertEqual(viewController.containerView.arrangedSubviews.map { $0 as! ContainedView }.map { $0.param }, [1, 2, 3, 4, 5, 6])

        container3.inputs([7, 8, 9])

        XCTAssertEqual(viewController.containerView.arrangedSubviews.count, 9)
        XCTAssertEqual(viewController.childViewControllers.count, 9)
        XCTAssertEqual(viewController.containerView.arrangedSubviews.map { $0 as! ContainedView }.map { $0.param }, [1, 2, 3, 4, 5, 6, 7, 8, 9])

        container2.input(nil)

        XCTAssertEqual(viewController.containerView.arrangedSubviews.count, 6)
        XCTAssertEqual(viewController.childViewControllers.count, 6)
        XCTAssertEqual(viewController.containerView.arrangedSubviews.map { $0 as! ContainedView }.map { $0.param }, [1, 2, 3, 7, 8, 9])

        container1.inputs([4, 5])

        XCTAssertEqual(viewController.containerView.arrangedSubviews.count, 5)
        XCTAssertEqual(viewController.childViewControllers.count, 5)
        XCTAssertEqual(viewController.containerView.arrangedSubviews.map { $0 as! ContainedView }.map { $0.param }, [4, 5, 7, 8, 9])

        container2.input(6)

        XCTAssertEqual(viewController.containerView.arrangedSubviews.count, 6)
        XCTAssertEqual(viewController.childViewControllers.count, 6)
        XCTAssertEqual(viewController.containerView.arrangedSubviews.map { $0 as! ContainedView }.map { $0.param }, [4, 5, 6, 7, 8, 9])

    }

    func testContainerForInteractable() {
        final class ContainedView: UIView {
            var param: Int = 0
        }
        final class ContainedViewController: ResourceContingViewController, Instantiatable, Injectable, Interactable {
            let environment: Void
            var handler: ((ContainedViewController.Output) -> Void)?
            lazy var _view: ContainedView = {
                let view = ContainedView()
                self.view = view
                return view
            }()
            init(with input: Int, environment: Void) {
                self.environment = environment
                super.init(nibName: nil, bundle: nil)
                _view.param = input
            }

            required init?(coder aDecoder: NSCoder) {
                fatalError()
            }

            func input(_ input: Int) {
                _view.param = input
            }

            func output(_ handler: ((String) -> Void)?) {
                self.handler = handler
            }

            func fire() {
                handler?("\(self._view.param)")
            }
        }

        let viewController = ContainerViewController(with: (), environment: ())

        let container1 = viewController.containerView.makeContainer(for: ContainedViewController.self, parentViewController: viewController)
        let container2 = viewController.containerView.makeContainer(for: ContainedViewController.self, parentViewController: viewController)
        let container3 = viewController.containerView.makeContainer(for: ContainedViewController.self, parentViewController: viewController)

        var result1 = [String]()
        var result2 = [String]()
        var result3 = [String]()

        container1.output { result1.append($0) }
        container2.output { result2.append($0) }
        container3.output { result3.append($0) }

        XCTAssertEqual(result1, [])
        XCTAssertEqual(result2, [])
        XCTAssertEqual(result3, [])

        func reset() {
            result1 = []
            result2 = []
            result3 = []
        }

        container1.inputs([1, 2, 3])
        viewController.childViewControllers
            .compactMap { $0 as? ContainedViewController }
            .forEach { (childViewController) in
                childViewController.fire()
            }

        XCTAssertEqual(result1, ["1", "2", "3"])
        XCTAssertEqual(result2, [])
        XCTAssertEqual(result3, [])

        reset()
        container2.inputs([4, 5, 6])
        viewController.childViewControllers
            .compactMap { $0 as? ContainedViewController }
            .forEach { (childViewController) in
                childViewController.fire()
        }

        XCTAssertEqual(result1, ["1", "2", "3"])
        XCTAssertEqual(result2, ["4", "5", "6"])
        XCTAssertEqual(result3, [])

        reset()
        container3.inputs([7, 8, 9])
        viewController.childViewControllers
            .compactMap { $0 as? ContainedViewController }
            .forEach { (childViewController) in
                childViewController.fire()
        }

        XCTAssertEqual(result1, ["1", "2", "3"])
        XCTAssertEqual(result2, ["4", "5", "6"])
        XCTAssertEqual(result3, ["7", "8", "9"])

        reset()
        container2.input(nil)
        viewController.childViewControllers
            .compactMap { $0 as? ContainedViewController }
            .forEach { (childViewController) in
                childViewController.fire()
        }

        XCTAssertEqual(result1, ["1", "2", "3"])
        XCTAssertEqual(result2, [])
        XCTAssertEqual(result3, ["7", "8", "9"])

        reset()
        container1.inputs([4, 5])
        viewController.childViewControllers
            .compactMap { $0 as? ContainedViewController }
            .forEach { (childViewController) in
                childViewController.fire()
        }

        XCTAssertEqual(result1, ["4", "5"])
        XCTAssertEqual(result2, [])
        XCTAssertEqual(result3, ["7", "8", "9"])

        reset()
        container2.input(6)
        viewController.childViewControllers
            .compactMap { $0 as? ContainedViewController }
            .forEach { (childViewController) in
                childViewController.fire()
        }

        XCTAssertEqual(result1, ["4", "5"])
        XCTAssertEqual(result2, ["6"])
        XCTAssertEqual(result3, ["7", "8", "9"])
    }

    static var allTests = [
        ("testPrepareForInterfaceBuilder", testPrepareForInterfaceBuilder),
        ("testMakeContainerForInstantiatable", testMakeContainerForInstantiatable),
        ("testContainerForInjectable", testContainerForInjectable),
        ("testContainerForInteractable", testContainerForInteractable)
    ]
}
