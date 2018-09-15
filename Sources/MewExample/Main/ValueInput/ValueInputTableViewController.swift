//
//  ValueInputTableViewController.swift
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
final class ValueInputTableViewController: UIViewController, Instantiatable, Interactable, UITableViewDelegate, UITableViewDataSource {
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
            tableView?.reloadData()
        }
    }

    var environment: EnvironmentMock
    var handler: ((Output) -> ())?

    @IBOutlet weak var tableView: UITableView!

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
        TableViewCell<NumberViewController>.register(to: tableView)
    }

    func output(_ handler: ((ValueInputTableViewController.Output) -> Void)?) {
        self.handler = handler
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return TableViewCell<NumberViewController>.dequeued(
            from: tableView,
            for: indexPath,
            input: NumberViewController.Input(number: model.elements[indexPath.row]),
            parentViewController: self
        )
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        handler?(Output(numberInput: model.elements[indexPath.row]))
    }
}
