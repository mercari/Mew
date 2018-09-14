//
//  ValueInputViewController.swift
//  MewExample
//
//  Created by tarunon on 2018/08/29.
//  Copyright © 2018 Mercari. All rights reserved.
//

import UIKit
import Mew

/// A form for inputting a number.
/// Supports being pushed or presented.
/// Outputs numberInput when the Done button is tapped
final class ValueInputViewController: UIViewController, Instantiatable, Interactable {
    typealias Environment = EnvironmentMock
    
    enum PresentedStyle {
        case push
        case present
    }

    struct Model {
        var presentedStyle: PresentedStyle
    }

    struct Input {
        var presentedStyle: PresentedStyle
    }

    struct Output {
        var numberInput: Int
    }

    var model: Model {
        didSet {
            // Do nothing
        }
    }

    var environment: EnvironmentMock
    var handler: ((Output) -> ())?

    @IBOutlet weak var textField: UITextField!

    init(with input: Input, environment: EnvironmentMock) {
        self.environment = environment
        self.model = Model(presentedStyle: input.presentedStyle)
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if model.presentedStyle == .present {
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
        let output = Output.init(numberInput: Int(textField.text ?? "0") ?? 0)
        switch model.presentedStyle {
        case .push:
            navigationController?.popViewController(animated: true)
            handler?(output)
        case .present:
            dismiss(animated: true, completion: {
                self.handler?(output)
            })
        }
    }
}
