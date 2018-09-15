//
//  CollectionViewCellTests.swift
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

final private class CollectionViewController: UICollectionViewController, Instantiatable, UICollectionViewDelegateFlowLayout {
    let environment: Void
    var elements: [Int]

    init(with input: [Int], environment: Void) {
        self.environment = environment
        self.elements = input
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        CollectionViewCell<ViewController>.register(to: collectionView!)
        CollectionReusableView<ViewController>.register(to: collectionView!, for: .header)
        collectionViewLayout.invalidateLayout()
        collectionView?.reloadData()
        collectionView?.layoutIfNeeded()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return elements.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return CollectionViewCell<ViewController>.dequeued(from: collectionView, for: indexPath, input: elements[indexPath.row], parentViewController: self)
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return CollectionReusableView<ViewController>.dequeued(from: collectionView, of: kind, for: indexPath, input: elements.count, parentViewController: self)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44.0)
    }
}

class CollectionViewCellTests: XCTestCase {
    func testDequeueCollectionViewCellWithViewController() {
        let collectionViewController = CollectionViewController(with: [1, 2, 3], environment: ())
        _ = collectionViewController.view // load view
        INJECTABLE: do {
            let cell = CollectionViewCell<ViewController>.dequeued(from: collectionViewController.collectionView!, for: IndexPath(row: 0, section: 0), input: 39, parentViewController: collectionViewController)
            XCTAssertEqual(cell.content.parameter, 39)
            XCTAssertTrue(cell.contentView.subviewTreeContains(with: cell.content.view))
        }

        INTERACTABLE: do {
            var expected: Int?
            let cell = CollectionViewCell<ViewController>.dequeued(from: collectionViewController.collectionView!, for: IndexPath(row: 0, section: 0), input: 48, output: { expected = $0 }, parentViewController: collectionViewController)
            XCTAssertEqual(cell.content.parameter, 48)
            XCTAssertTrue(cell.contentView.subviewTreeContains(with: cell.content.view))
            XCTAssertNil(expected)
            cell.content.fire()
            XCTAssertEqual(expected, 48)
        }
    }

    func testDequeueCollectionViewHeaderFooterWithViewController() {
        let collectionViewController = CollectionViewController(with: [1, 2, 3], environment: ())
        _ = collectionViewController.view // load view
        INJECTABLE: do {
            let view = CollectionReusableView<ViewController>.dequeued(from: collectionViewController.collectionView!, of: CollectionViewSupplementaryKind.header.rawValue, for: IndexPath(item: 0, section: 0), input: 39, parentViewController: collectionViewController)
            XCTAssertEqual(view.content.parameter, 39)
            XCTAssertTrue(view.subviewTreeContains(with: view.content.view))
        }

        INTERACTABLE: do {
            var expected: Int?
            let view = CollectionReusableView<ViewController>.dequeued(from: collectionViewController.collectionView!, of: CollectionViewSupplementaryKind.header.rawValue, for: IndexPath(item: 0, section: 0), input: 48, output: { expected = $0 }, parentViewController: collectionViewController)
            XCTAssertEqual(view.content.parameter, 48)
            XCTAssertTrue(view.subviewTreeContains(with: view.content.view))
            XCTAssertNil(expected)
            view.content.fire()
            XCTAssertEqual(expected, 48)
        }
    }

    func testViewControllerLifeCycle() {
        let exp = expectation(description: #function + "\(#line)")
        let collectionViewController = CollectionViewController(with: Array(0..<10), environment: ())
        let parent = UIViewController()
        UIApplication.shared.keyWindow?.rootViewController = parent
        parent.present(collectionViewController, animated: true, completion: {
            let viewControllers = collectionViewController.collectionView!.visibleCells
                .compactMap { $0 as? CollectionViewCell<ViewController> }
                .map { $0.content }

            viewControllers.forEach {
                XCTAssertEqual($0.parent, collectionViewController)
            }
            XCTAssertEqual(
                (collectionViewController.collectionView?.supplementaryView(forElementKind: CollectionViewSupplementaryKind.header.rawValue, at: IndexPath(item: 0, section: 0)) as? CollectionReusableView<ViewController>)?.content.parent,
                collectionViewController
            )
            parent.dismiss(animated: true, completion: {
                exp.fulfill()
            })
        })
        self.wait(for: [exp], timeout: 5.0)
    }

    static var allTests = [
        ("testDequeueCollectionViewCellWithViewController", testDequeueCollectionViewCellWithViewController),
        ("testDequeueCollectionViewHeaderFooterWithViewController", testDequeueCollectionViewHeaderFooterWithViewController),
        ("testViewControllerLifeCycle", testViewControllerLifeCycle)
    ]
}
