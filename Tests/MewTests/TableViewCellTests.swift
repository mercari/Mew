//
//  TableViewCellTests.swift
//  MewTests
//
//  Created by tarunon on 2018/04/04.
//  Copyright © 2018 Mercari. All rights reserved.
//

import XCTest
@testable import Mew

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
                XCTAssertFalse(cell.hasAmbiguousLayout)
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
