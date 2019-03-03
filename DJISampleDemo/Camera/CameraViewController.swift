//
//  CameraViewController.swift
//  DJISampleDemo
//
//  Created by 松下航平 on 2019/03/03.
//

import UIKit
import DJISDK
import DJIWidget

/// Camera Application
class CameraViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var takingButton: UIButton!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var changeModeSegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DJISDKManager.registerApp(with: self)
    }
}

extension CameraViewController: DJISDKManagerDelegate {

    func appRegisteredWithError(_ error: Error?) {
        if let error = error {
            print("Register App Failured : " + error.localizedDescription)
        } else {
            print("Register App Successed")
            DJISDKManager.startConnectionToProduct()
        }
    }
}

extension CameraViewController: DJICameraDelegate {

}

extension CameraViewController: DJIVideoFeedListener {

    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData videoData: Data) {

    }
}
