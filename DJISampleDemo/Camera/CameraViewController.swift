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
}
