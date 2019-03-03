//
//  GettingStartedViewController.swift
//  DJISampleDemo
//
//  Created by 松下航平 on 2019/03/03.
//

import UIKit
import DJISDK
import DJIUXSDK

/// Getting Started with UX SDK
class GettingStartedViewController: DUXDefaultLayoutViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DJISDKManager.registerApp(with: self)
    }
}

extension GettingStartedViewController: DJISDKManagerDelegate {

    func appRegisteredWithError(_ error: Error?) {
        if let error = error {
            print("Register App Failured : " + error.localizedDescription)
        } else {
            print("Register App Successed")
            DJISDKManager.startConnectionToProduct()
        }
    }
}
