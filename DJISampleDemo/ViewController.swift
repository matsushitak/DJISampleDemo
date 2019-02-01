//
//  ViewController.swift
//  DJISampleDemo
//
//  Created by 松下航平 on 2019/01/30.
//

import UIKit
import DJISDK

class ViewController: UIViewController {

    @IBOutlet weak var activationStateLabel: UILabel!
    @IBOutlet weak var aircraftBindingStateLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!

    private var activationState: DJIAppActivationState! {
        didSet {
            switch activationState {
            case .none:
                self.activationStateLabel.text = "None"
            case .some(let state):
                switch state {
                case .notSupported:
                    self.activationStateLabel.text = "App Activation is not supported."
                case .loginRequired:
                    self.activationStateLabel.text = "Login is required to activate."
                case .activated:
                    self.activationStateLabel.text = "Activated"
                case .unknown:
                    self.activationStateLabel.text = "Unknown"
                }
            }
        }
    }

    private var aircraftBindingState: DJIAppActivationAircraftBindingState! {
        didSet {
            switch aircraftBindingState {
            case .none:
                self.aircraftBindingStateLabel.text = "None"
            case .some(let state):
                switch state {
                case .initial:
                    self.aircraftBindingStateLabel.text = "Initial"
                case .unbound:
                    self.aircraftBindingStateLabel.text = "Unbound. Use DJI GO to bind the aircraft."
                case .unboundButCannotSync:
                    self.aircraftBindingStateLabel.text = "Unbound. Please connect Internet to update state."
                case .bound:
                    self.aircraftBindingStateLabel.text = "Bound"
                case .notRequired:
                    self.aircraftBindingStateLabel.text = "Binding is not required."
                case .notSupported:
                    self.aircraftBindingStateLabel.text = "App Activation is not supported."
                case .unknown:
                    self.aircraftBindingStateLabel.text = "Unknown"
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DJISDKManager.registerApp(with: self)
    }

    @IBAction func onTapLogin(_ sender: UIButton) {
        DJISDKManager.userAccountManager().logIntoDJIUserAccount(withAuthorizationRequired: false) { (state, error) in
            if let error = error {
                print("Login Failure : " + error.localizedDescription)
            } else {
                print("Login Success")
            }
        }
    }

    @IBAction func onTapLogout(_ sender: UIButton) {
        DJISDKManager.userAccountManager().logOutOfDJIUserAccount { (error) in
            if let error = error {
                print("Logout Failure : " + error.localizedDescription)
            } else {
                print("Logout Success")
            }
        }
    }
}

extension ViewController: DJIAppActivationManagerDelegate {

    func manager(_ manager: DJIAppActivationManager!, didUpdate appActivationState: DJIAppActivationState) {
        self.activationState = appActivationState
    }

    func manager(_ manager: DJIAppActivationManager!, didUpdate aircraftBindingState: DJIAppActivationAircraftBindingState) {
        self.aircraftBindingState = aircraftBindingState
    }
}


extension ViewController: DJISDKManagerDelegate {

    func appRegisteredWithError(_ error: Error?) {
        if let error = error {
            print("Register App Failured : " + error.localizedDescription)
        } else {
            print("Register App Successed")
            DJISDKManager.startConnectionToProduct()
            DJISDKManager.appActivationManager().delegate = self
            activationState = DJISDKManager.appActivationManager().appActivationState
            aircraftBindingState = DJISDKManager.appActivationManager().aircraftBindingState
        }
    }
}
