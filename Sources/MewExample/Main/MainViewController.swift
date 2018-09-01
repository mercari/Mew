//
//  MainViewController.swift
//  MewExampleApp
//
//  Created by tarunon on 2018/08/29.
//  Copyright © 2018 Mercari. All rights reserved.
//

import UIKit
import Mew

final class MainViewController: UIViewController, Instantiatable {
    struct Model {
        var x: Int?
        var y: Int?

        static var initial = Model(x: nil, y: nil)
    }

    typealias Environment = EnvironmentMock
    typealias Input = Void
    var environment: EnvironmentMock

    var model: Model = .initial {
        didSet {
            update()
        }
    }

    init(with input: Input, environment: Environment) {
        self.environment = environment
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet weak var containerView: ContainerView!

    lazy var pushContainer = self.containerView.makeContainer(for: PushButtonViewController.self, parent: self, with: ())
    lazy var presentContainer = self.containerView.makeContainer(for: PresentButtonViewController.self, parent: self, with: ())
    lazy var resultContainer = self.containerView.makeContainer(for: ResultLabelViewController.self, parent: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mew Example"

        pushContainer.output { [weak self] (value) in
            self?.model.x = value
        }
        presentContainer.output { [weak self] (value) in
            self?.model.y = value
        }
        resultContainer.output { [weak self] _ in
            self?.model = .initial
            UIView.animate(withDuration: 0.35) {
                self?.view.layoutSubviews()
            }
        }
        update()
    }

    func update() {
        resultContainer.input(ResultLabelViewController.Input(x: model.x, y: model.y))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

