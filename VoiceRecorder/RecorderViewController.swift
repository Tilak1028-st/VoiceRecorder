//
//  RecorderViewController.swift
//  VoiceRecorder
//
//  Created by PCS213 on 08/12/22.
//

import UIKit
import AVFoundation

class RecorderViewController: UIViewController {

    @IBOutlet weak var recorderView: UIView!
    @IBOutlet weak var micButton: UIButton!
    
    var captureSession: AVCaptureSession?
    var audioDevice: AVCaptureDevice?
    var audioDeviceInput: AVCaptureDeviceInput?
    var audioDeviceOutput: AVCaptureAudioDataOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleMicButton()
        prepare { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    
    func styleMicButton() {
        micButton.layer.cornerRadius = min(micButton.frame.width, micButton.frame.height) / 2
    }
    
    @IBAction func diTapOnRecordButton(_ sender: Any) {
       
    }
    
}

extension RecorderViewController {
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        
        func createCaptureSession() {
            captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevice() throws {
            guard let capturedAudioDevice = AVCaptureDevice.default(for: .audio) else {
                throw RecorderError.captureDeviceIsNotAvailable
            }
            
            self.audioDevice = capturedAudioDevice
        }
        
        func configureDeviceInput() throws {
            guard let captureSession = captureSession else {
                throw RecorderError.captureSessionIsMissing
            }
            
            if let audioDevice = self.audioDevice {
                try audioDevice.lockForConfiguration()
                self.audioDeviceInput = try AVCaptureDeviceInput.init(device: audioDevice)
                try audioDevice.unlockForConfiguration()
                
                if captureSession.canAddInput(self.audioDeviceInput!) {
                    captureSession.addInput(audioDeviceInput!)
                }
            }
        }
        
        func configureDevicOutput() throws {
            guard let captureSession = captureSession else {
                throw RecorderError.captureSessionIsMissing
            }
            
            self.audioDeviceOutput = AVCaptureAudioDataOutput()
            
            if captureSession.canAddOutput(self.audioDeviceOutput!) {
                captureSession.addOutput(self.audioDeviceOutput!)
            }
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevice()
                try configureDeviceInput()
                try configureDevicOutput()
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    
    }
    
}



enum RecorderError: Swift.Error {
    case captureDeviceIsNotAvailable
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case unknown
}
