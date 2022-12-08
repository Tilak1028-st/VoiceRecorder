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
    @IBOutlet weak var recordListTableView: UITableView!
    var recordingSession: AVAudioSession!
    var audioRecoder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var numberOfRecords = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingSession = AVAudioSession.sharedInstance()
        if let number:Int = UserDefaults.standard.object(forKey: "Mynumber") as? Int {
            numberOfRecords = number
        }
        checkMicPremission()
        self.styleMicButton()
    }

    
    
    @IBAction func diTapOnRecordButton(_ sender: Any) {
       
        if audioRecoder == nil {
            let fileName = getFileDirectory()?.appendingPathComponent("\(numberOfRecords).m4a")
            
            let setting = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 1200, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            do {
                audioRecoder = try AVAudioRecorder(url: fileName!, settings: setting)
                audioRecoder.delegate = self
                audioRecoder.record()
            }
            catch {
                print(error.localizedDescription)
            }
        }
        else {
            audioRecoder.stop()
            audioRecoder = nil
            
            UserDefaults.standard.set(numberOfRecords, forKey: "Mynumber")
            recordListTableView.reloadData()
        }
    }
    
}

extension RecorderViewController {

//MARK: -> Function to make mic button circle
    func styleMicButton() {
        micButton.layer.cornerRadius = min(micButton.frame.width, micButton.frame.height) / 2
    }
    
//MARK: -> Function to check Mic Premission
    func checkMicPremission() {
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("Having Record Permission")
            }
        }
    }
    
//MARK: -> Function to get file Path
    func getFileDirectory() -> URL? {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return path
    }
}

// MARK: -> Recorder Delegate method
extension RecorderViewController: AVAudioRecorderDelegate {
    
}


extension RecorderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recordListTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = getFileDirectory()?.appendingPathComponent("\(indexPath.row).m4a")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path!)
            audioPlayer.play()
        }
        catch {
            
        }
    }
}
