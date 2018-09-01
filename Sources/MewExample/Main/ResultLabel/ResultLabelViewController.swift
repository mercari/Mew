//
//  ResultLabelViewController.swift
//  Mew
//
//  Created by tarunon on 2018/08/29.
//  Copyright © 2018 Mercari. All rights reserved.
//

import UIKit
import Mew

/// Note: Present 2 Int value additin.
/// 2 Int value is require.
/// Send reset signal when tapped button.
final class ResultLabelViewController: UIViewController, Instantiatable, Injectable, Interactable {
    typealias Environment = EnvironmentMock
    struct Model {
        var x: Int
        var y: Int

        init?(x: Int?, y: Int?) {
            guard let x = x, let y = y else { return nil }
            self.x = x
            self.y = y
        }
    }

    typealias Input = Model
    enum Output {
        case reset
    }

    let environment: EnvironmentMock
    var model: Model {
        didSet {
            updateUI()
        }
    }
    var handler: ((Output) -> Void)?

    @IBOutlet var label: UILabel!

    init(with input: Input, environment: EnvironmentMock) {
        self.model = input
        self.environment = environment
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func input(_ input: Input) {
        model = input
    }

    func output(_ handler: ((Output) -> Void)?) {
        self.handler = handler
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    func updateUI() {
        label?.text = "\(model.x) + \(model.y) = \(model.x + model.y)"
    }

    @IBAction func buttonTapped(_ sender: AnyObject) {
        handler?(.reset)
    }
}
