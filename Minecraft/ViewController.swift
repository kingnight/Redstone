//
//  ViewController.swift
//  Minecraft
//
//  Created by nixzhu on 2017/1/6.
//  Copyright © 2017年 nixWork. All rights reserved.
//

import UIKit
import Redstone

class ViewController: UIViewController {

    var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    enum State: Int {
        case off
        case on
        case broken
    }
    enum Transition: Int {
        case turn
        case cut
    }
    lazy var stateMachine: StateMachine<State, Transition> = {
        let stateMachine = StateMachine<State, Transition>()
        stateMachine.add(state: .off, entryOperation: {
            [weak self] in
            self?.statusBarStyle = .lightContent
            self?.view.backgroundColor = .black
            self?.promptLabel.textColor = .white
            self?.promptLabel.text = "Tap to turn lights on"
            print("enter off")
        })
        
        stateMachine.add(state: .off, beforeEntryOperation: {
            print("before enter off")
        })
        
        stateMachine.add(state: .on, entryOperation: { [weak self] in
            self?.statusBarStyle = .default
            self?.view.backgroundColor = .white
            self?.promptLabel.textColor = .black
            self?.promptLabel.text = "Tap to turn lights off"
            print("enter on")
        })
        
        stateMachine.add(state: .on, beforeEntryOperation: {
            print("before enter on")
        })
        
        stateMachine.add(state: .broken, entryOperation: { [weak self] in
            self?.statusBarStyle = .lightContent
            self?.view.backgroundColor = .black
            self?.promptLabel.textColor = .white
            self?.promptLabel.text = "The wire is broken :["
            print("enter broken")
        })
        
        stateMachine.add(state: .broken, beforeEntryOperation: {
            print("before enter broken")
        })
        
       // stateMachine.add
        stateMachine.add(transition: .turn, fromState: .off, toState: .on)
        stateMachine.add(transition: .turn, fromState: .on, toState: .off)
        stateMachine.add(transition: .cut, fromStates: [.on, .off], toState: .broken)
        return stateMachine
    }()

    override func loadView() {
        super.loadView()

        view.addSubview(promptLabel)
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: promptLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: promptLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
            ]
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        stateMachine.initialState = .off

        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        view.addGestureRecognizer(tap)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        view.addGestureRecognizer(longPress)
    }

    @objc func tap(_ sender: UITapGestureRecognizer) {
        stateMachine.fire(transition: .turn)
    }

    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        stateMachine.fire(transition: .cut)
    }
}
