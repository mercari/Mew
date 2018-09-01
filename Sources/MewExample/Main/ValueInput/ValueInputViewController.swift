//
//  ValueInputViewController.swift
//  Mew
//
//  Created by tarunon on 2018/08/29.
//  Copyright © 2018 Mercari. All rights reserved.
//

import UIKit
import Mew

/// Note: Support Push/Present both.
/// Output is user inputed value and send when tapped Done button.
final class ValueInputViewController: UIViewController, Instantiatable, Interactable {
    typealias Environment = EnvironmentMock
    enum Kind {
        case push
        case present
    }

    struct Model {
        var kind: Kind
    }

    struct Input {
        var kind: Kind
    }

    struct Output {
        var inputedValue: Int
    }

    var model: Model {
        didSet {
            // nop
        }
    }

    var environment: EnvironmentMock
    var handler: ((Output) -> ())?

    @IBOutlet weak var textField: UITextField!

    init(with input: Input, environment: EnvironmentMock) {
        self.environment = environment
        self.model = Model(kind: input.kind)
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if model.kind == .present {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "✕", style: .done, target: self, action: #selector(cancel(_:)))
        }
    }

    @objc func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func output(_ handler: ((ValueInputViewController.Output) -> Void)?) {
        self.handler = handler
    }

    @IBAction func buttonTapped(_ sender: Any) {
        switch model.kind {
        case .push:
            navigationController?.popViewController(animated: true)
            handler?(Output.init(inputedValue: Int(textField.text ?? "0") ?? 0))
        case .present:
            dismiss(animated: true, completion: {
                self.handler?(Output.init(inputedValue: Int(self.textField.text ?? "0") ?? 0))
            })
        }
    }
}
