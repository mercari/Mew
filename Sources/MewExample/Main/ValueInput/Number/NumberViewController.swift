//
//  NumberViewController.swift
//  MewExample
//
//  Created by tarunon on 2018/09/14.
//  Copyright © 2018 mercari. All rights reserved.
//

import UIKit
import Mew

final class NumberViewController: UIViewController, Instantiatable, Injectable {

    struct Input {
        let number: Int
    }

    struct Model {
        var number: Int
    }

    let environment: EnvironmentMock
    var model: Model {
        didSet {
            update()
        }
    }

    @IBOutlet weak var label: UILabel!

    init(with input: Input, environment: EnvironmentMock) {
        self.environment = environment
        self.model = Model(number: input.number)
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func input(_ input: NumberViewController.Input) {
        model.number = input.number
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }

    func update() {
        label?.text = "\(model.number)"
    }
}
