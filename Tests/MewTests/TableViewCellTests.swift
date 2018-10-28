//
//  TableViewCellTests.swift
//  MewTests
//
//  Created by tarunon on 2018/04/04.
//  Copyright © 2018 Mercari. All rights reserved.
//

import XCTest
@testable import Mew

final private class ViewController: UIViewController, Injectable, Instantiatable, Interactable {
    typealias Input = Int
    var parameter: Int
    var handler: ((Int) -> ())?

    let environment: Void

    init(with value: Int, environment: Void) {
        self.parameter = value
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func input(_ value: Int) {
        self.parameter = value
    }

    func output(_ handler: ((Int) -> Void)?) {
        self.handler = handler
    }

    func fire() {
        handler?(parameter)
    }
}

final private class AutolayoutViewController: UIViewController, Injectable, Instantiatable {
    struct Input {
        var additionalWidth: CGFloat
        var additionalHeight: CGFloat
    }
    var parameter: Input {
        didSet {
            updateLayout()
        }
    }

    let environment: Void

    init(with input: Input, environment: Void) {
        self.parameter = input
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var squareRequiredView: UIView!
    var additionalWidthView: UIView!
    var additionalHeightView: UIView!
    var additionalWidthConstraint: NSLayoutConstraint!
    var additionalHeightConstraint: NSLayoutConstraint!

    /**
     ```
     ┌┬─┐
     ├┴─┤
     └──┘
     ```
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        squareRequiredView = UIView()
        squareRequiredView.translatesAutoresizingMaskIntoConstraints = false
        additionalWidthView = UIView()
        additionalWidthView.translatesAutoresizingMaskIntoConstraints = false
        additionalHeightView = UIView()
        additionalHeightView.translatesAutoresizingMaskIntoConstraints = false
        additionalWidthConstraint = additionalWidthView.widthAnchor.constraint(equalToConstant: 0)
        additionalWidthConstraint.priority = .defaultHigh + 1
        additionalHeightConstraint = additionalHeightView.heightAnchor.constraint(equalToConstant: 0)
        view.addSubview(squareRequiredView)
        view.addSubview(additionalWidthView)
        view.addSubview(additionalHeightView)
        NSLayoutConstraint.activate(
            [
                squareRequiredView.heightAnchor.constraint(equalToConstant: 200.0),
                squareRequiredView.widthAnchor.constraint(equalToConstant: 200.0),
                squareRequiredView.topAnchor.constraint(equalTo: view.topAnchor),
                squareRequiredView.leftAnchor.constraint(equalTo: view.leftAnchor),
                squareRequiredView.rightAnchor.constraint(equalTo: additionalWidthView.leftAnchor),
                additionalWidthView.topAnchor.constraint(equalTo: view.topAnchor),
                additionalWidthView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                additionalWidthView.rightAnchor.constraint(equalTo: view.rightAnchor),
                additionalWidthView.widthAnchor.constraint(lessThanOrEqualToConstant: 1000.0),
                additionalWidthConstraint,
                squareRequiredView.bottomAnchor.constraint(equalTo: additionalHeightView.topAnchor),
                additionalHeightView.leftAnchor.constraint(equalTo: view.leftAnchor),
                additionalHeightView.rightAnchor.constraint(equalTo: view.rightAnchor),
                additionalHeightView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                additionalHeightConstraint
            ]
        )
        updateLayout()
    }

    func input(_ value: Input) {
        self.parameter = value
    }

    func updateLayout() {
        additionalWidthConstraint.constant = parameter.additionalWidth
        additionalHeightConstraint.constant = parameter.additionalHeight
    }
}

final private class TableViewController: UITableViewController, Instantiatable {
    let environment: Void
    var elements: [Int]

    init(with input: [Int], environment: Void) {
        self.environment = environment
        self.elements = input
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        TableViewCell<ViewController>.register(to: tableView)
        TableViewHeaderFooterView<ViewController>.register(to: tableView)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return TableViewCell<ViewController>.dequeued(from: tableView, for: indexPath, input: elements[indexPath.row], parentViewController: self)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TableViewHeaderFooterView<ViewController>.dequeued(from: tableView, input: elements.count, parentViewController: self)
    }
}

final private class AutolayoutTableViewController: UITableViewController, Instantiatable, Injectable {
    let environment: Void
    var elements: [AutolayoutViewController.Input]

    init(with input: [AutolayoutViewController.Input], environment: Void) {
        self.environment = environment
        self.elements = input
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        TableViewCell<AutolayoutViewController>.register(to: tableView)
    }

    func input(_ input: [AutolayoutViewController.Input]) {
        self.elements = input
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return TableViewCell<AutolayoutViewController>.dequeued(from: tableView, for: indexPath, input: elements[indexPath.row], parentViewController: self)
    }
}

class TableViewCellTests: XCTestCase {
    func testDequeueTableViewCellWithViewController() {
        let tableViewController = TableViewController(with: [1, 2, 3], environment: ())
        _ = tableViewController.view // load view
        INJECTABLE: do {
            let cell = TableViewCell<ViewController>.dequeued(from: tableViewController.tableView, for: IndexPath(row: 0, section: 0), input: 39, parentViewController: tableViewController)
            XCTAssertEqual(cell.content.parameter, 39)
            XCTAssertTrue(cell.contentView.subviewTreeContains(with: cell.content.view))
            XCTAssertEqual(cell.accessoryType, .none)
            XCTAssertEqual(cell.editingAccessoryType, .none)
            XCTAssertEqual(cell.selectionStyle, .none)
        }

        INTERACTABLE: do {
            var expected: Int?
            let cell = TableViewCell<ViewController>.dequeued(from: tableViewController.tableView, for: IndexPath(row: 0, section: 0), input: 48, output: { expected = $0 }, parentViewController: tableViewController)
            XCTAssertEqual(cell.content.parameter, 48)
            XCTAssertTrue(cell.contentView.subviewTreeContains(with: cell.content.view))
            XCTAssertEqual(cell.accessoryType, .none)
            XCTAssertEqual(cell.editingAccessoryType, .none)
            XCTAssertEqual(cell.selectionStyle, .none)
            XCTAssertNil(expected)
            cell.content.fire()
            XCTAssertEqual(expected, 48)
        }
    }

    func testDequeueTableViewHeaderFooterWithViewController() {
        let tableViewController = TableViewController(with: [1, 2, 3], environment: ())
        _ = tableViewController.view // load view
        INJECTABLE: do {
            let view = TableViewHeaderFooterView<ViewController>.dequeued(from: tableViewController.tableView, input: 39, parentViewController: tableViewController)
            XCTAssertEqual(view.content.parameter, 39)
            XCTAssertTrue(view.contentView.subviewTreeContains(with: view.content.view))
        }

        INTERACTABLE: do {
            var expected: Int?
            let view = TableViewHeaderFooterView<ViewController>.dequeued(from: tableViewController.tableView, input: 48, output: { expected = $0 }, parentViewController: tableViewController)
            XCTAssertEqual(view.content.parameter, 48)
            XCTAssertTrue(view.contentView.subviewTreeContains(with: view.content.view))
            XCTAssertNil(expected)
            view.content.fire()
            XCTAssertEqual(expected, 48)
        }
    }

    func testViewControllerLifeCycle() {
        let exp = expectation(description: #function + "\(#line)")
        let tableViewController = TableViewController(with: Array(0..<10), environment: ())
        let parent = UIViewController()
        UIApplication.shared.keyWindow?.rootViewController = parent
        parent.present(tableViewController, animated: true, completion: {
            let viewControllers = tableViewController.tableView.visibleCells
                .compactMap { $0 as? TableViewCell<ViewController> }
                .map { $0.content }

            viewControllers.forEach {
                XCTAssertEqual($0.parent, tableViewController)
            }
            XCTAssertEqual(
                (tableViewController.tableView.headerView(forSection: 0) as? TableViewHeaderFooterView<ViewController>)?.content.parent,
                tableViewController
            )
            parent.dismiss(animated: true, completion: {
                exp.fulfill()
            })
        })
        self.wait(for: [exp], timeout: 5.0)
    }

    func testAutosizingCell() {
        let tableViewController = AutolayoutTableViewController(with: [], environment: ())
        _ = tableViewController.view // load view
        let data = [
            [
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 0..<100)), additionalHeight: CGFloat(Int.random(in: 0..<100))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 0..<100)), additionalHeight: CGFloat(Int.random(in: 0..<100))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 0..<100)), additionalHeight: CGFloat(Int.random(in: 0..<100))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 0..<100)), additionalHeight: CGFloat(Int.random(in: 0..<100))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 0..<100)), additionalHeight: CGFloat(Int.random(in: 0..<100))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 0..<100)), additionalHeight: CGFloat(Int.random(in: 0..<100)))
            ],
            [
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 200..<1000)), additionalHeight: CGFloat(Int.random(in: 200..<1000))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 200..<1000)), additionalHeight: CGFloat(Int.random(in: 200..<1000))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 200..<1000)), additionalHeight: CGFloat(Int.random(in: 200..<1000))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 200..<1000)), additionalHeight: CGFloat(Int.random(in: 200..<1000))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 200..<1000)), additionalHeight: CGFloat(Int.random(in: 200..<1000))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 200..<1000)), additionalHeight: CGFloat(Int.random(in: 200..<1000))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 200..<1000)), additionalHeight: CGFloat(Int.random(in: 200..<1000)))
            ],
            [
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 0..<1000)), additionalHeight: CGFloat(Int.random(in: 0..<1000))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 0..<1000)), additionalHeight: CGFloat(Int.random(in: 0..<1000))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 0..<1000)), additionalHeight: CGFloat(Int.random(in: 0..<1000))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 0..<1000)), additionalHeight: CGFloat(Int.random(in: 0..<1000))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 0..<1000)), additionalHeight: CGFloat(Int.random(in: 0..<1000))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 0..<1000)), additionalHeight: CGFloat(Int.random(in: 0..<1000))),
                AutolayoutViewController.Input(additionalWidth: CGFloat(Int.random(in: 0..<1000)), additionalHeight: CGFloat(Int.random(in: 0..<1000)))
            ]
        ]
        UIApplication.shared.keyWindow?.rootViewController = tableViewController
        for expects in data {
            tableViewController.input(expects)
            let cells = tableViewController.tableView.visibleCells
            zip(expects, cells).forEach { expect, cell in
                XCTAssertEqual(cell.frame.size, CGSize(width: tableViewController.tableView.frame.width, height: 200 + expect.additionalHeight + 0.5))
                XCTAssertEqual(cell.contentView.frame.size, CGSize(width: tableViewController.tableView.frame.width, height: 200 + expect.additionalHeight))
                let childViewController = tableViewController.childViewControllers.first(where: { $0.view.superview == cell.contentView }) as! AutolayoutViewController
                XCTAssertEqual(childViewController.view.frame.size, CGSize(width: min(tableViewController.tableView.frame.width, 200 + expect.additionalWidth), height: 200 + expect.additionalHeight))
            }
        }
    }

    static var allTests = [
        ("testDequeueTableViewCellWithViewController", testDequeueTableViewCellWithViewController),
        ("testDequeueTableViewHeaderFooterWithViewController", testDequeueTableViewHeaderFooterWithViewController),
        ("testViewControllerLifeCycle", testViewControllerLifeCycle),
        ("testAutosizingCell", testAutosizingCell)
    ]
}
