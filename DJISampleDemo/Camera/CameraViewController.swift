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

    private enum CameraMode {
        case photo, video
    }

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var takingButton: UIButton!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var changeModeSegmentedControl: UISegmentedControl!
    private var isRecording: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        recordingTimeLabel.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DJISDKManager.registerApp(with: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disconnectCamera()
    }

    @IBAction func onTapTakingCapture(_ sender: UIButton) {
        guard let camera = camera else {
            print("Product's camera is not found")
            return
        }
        camera.setShootPhotoMode(.single) { (error) in
            if let error = error {
                print("Capture Failured : " + error.localizedDescription)
            } else {
                camera.startShootPhoto { (error) in
                    if let error = error {
                        print("Capture Failured : " + error.localizedDescription)
                    }
                }
            }
        }
    }

    @IBAction func onTapRecordingVideo(_ sender: UIButton) {
        guard let camera = camera else {
            print("Product's camera is not found")
            return
        }
        camera.setShootPhotoMode(.single) { (error) in
            if let error = error {
                print("Record Failured : " + error.localizedDescription)
            } else {
                camera.startRecordVideo { (error) in
                    if let error = error {
                        print("Record Failured : " + error.localizedDescription)
                    }
                }
            }
        }
    }

    @IBAction func onChangedModeSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            changeCameraMode(mode: .photo)
        } else if sender.selectedSegmentIndex == 1 {
            changeCameraMode(mode: .video)
        }
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

    func productConnected(_ product: DJIBaseProduct?) {
        print("Product connected")
        connectCamera(product)
    }

    func productDisconnected() {
        print("Product disconnected")
        disconnectCamera()
    }

    private func connectCamera(_ product: DJIBaseProduct?) {
        guard let camera = camera else {
            print("Product's camera is not found")
            return
        }
        camera.delegate = self
        setupVideoPreview()
    }

    private func disconnectCamera() {
        guard let camera = camera else {
            print("Product's camera is not found")
            return
        }
        camera.delegate = nil
        resetVideoPreview()
    }

    private var camera: DJICamera? {
        guard let product = DJISDKManager.product() else {
            return nil
        }
        switch product {
        case is DJIAircraft:
            return (product as? DJIAircraft)?.camera
        case is DJIHandheld:
            return (product as? DJIHandheld)?.camera
        default:
            return nil
        }
    }
}

extension CameraViewController: DJICameraDelegate {

    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
        isRecording = systemState.isRecording
        recordingTimeLabel.isHidden = !systemState.isRecording
        recordingTimeLabel.text = formattingSecond(seconds: systemState.currentVideoRecordingTimeInSeconds)
        if systemState.isRecording {
            recordingButton.setTitle("Stop Record", for: .normal)
        } else {
            recordingButton.setTitle("Start Record", for: .normal)
        }
    }

    private func formattingSecond(seconds: UInt) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(seconds))
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }

    private func changeCameraMode(mode: CameraMode) {
        guard let camera = camera else {
            print("Product's camera is not found")
            return
        }
        let changeMode: DJICameraMode!
        switch mode {
        case .photo:
            changeMode = .shootPhoto
            break
        case .video:
            changeMode = .recordVideo
            break
        }
        camera.setMode(changeMode) { error in
            if let error = error {
                print("Change Camera Mode Failured : " + error.localizedDescription)
            } else {
                print("Change Camera Mode Successed")
            }
        }
    }
}

extension CameraViewController: DJIVideoFeedListener {

    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData videoData: Data) {
        guard let previewer = DJIVideoPreviewer.instance() else {
            return
        }
        var data = videoData
        let count = data.count
        data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) -> Void in
            previewer.push(bytes, length: Int32(count))
        }
    }

    private func setupVideoPreview() {
        print("Setup video preview")
        guard let previewer = DJIVideoPreviewer.instance() else {
            return
        }
        guard let model = DJISDKManager.product()?.model else {
            return
        }
        previewer.setView(previewView)
        if model == DJIAircraftModelNameA3
            || model == DJIAircraftModelNameN3
            || model == DJIAircraftModelNameMatrice600
            || model == DJIAircraftModelNameMatrice600Pro {
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.add(self, with: nil)
        } else {
            DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
        }
        previewer.start()
    }

    private func resetVideoPreview() {
        print("Reset video preview")
        guard let previewer = DJIVideoPreviewer.instance() else {
            return
        }
        guard let model = DJISDKManager.product()?.model else {
            return
        }
        previewer.unSetView()
        if model == DJIAircraftModelNameA3
            || model == DJIAircraftModelNameN3
            || model == DJIAircraftModelNameMatrice600
            || model == DJIAircraftModelNameMatrice600Pro {
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.remove(self)
        } else {
            DJISDKManager.videoFeeder()?.primaryVideoFeed.remove(self)
        }
    }
}
