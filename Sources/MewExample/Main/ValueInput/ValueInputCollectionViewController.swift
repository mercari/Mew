//
//  ValueInputCollectionViewController.swift
//  Mew
//
//  Created by tarunon on 2018/08/29.
//  Copyright © 2018 Mercari. All rights reserved.
//

import UIKit
import Mew

/// A form for inputting a number.
/// Supports being pushed or presented.
/// Outputs numberInput when the Done button is tapped
final class ValueInputCollectionViewController: UIViewController, Instantiatable, Interactable, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    typealias Environment = EnvironmentMock

    struct Model {
        var elements: [Int]
    }

    struct Input {
        var elements: [Int]
    }

    struct Output {
        var numberInput: Int
    }

    var model: Model {
        didSet {
            collectionView?.reloadData()
        }
    }

    var environment: EnvironmentMock
    var handler: ((Output) -> ())?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    init(with input: Input, environment: EnvironmentMock) {
        self.environment = environment
        self.model = Model(elements: input.elements)
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        CollectionViewCell<NumberViewController>.register(to: collectionView)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "✖︎", style: .done, target: self, action: #selector(close(_:)))
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        flowLayout.invalidateLayout()
    }

    func output(_ handler: ((ValueInputCollectionViewController.Output) -> Void)?) {
        self.handler = handler
    }

    @objc func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.elements.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return CollectionViewCell<NumberViewController>.dequeued(
            from: collectionView,
            for: indexPath,
            input: NumberViewController.Input(number: model.elements[indexPath.row]),
            parentViewController: self
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.handler?(Output(numberInput: self.model.elements[indexPath.row]))
        }
    }
}
