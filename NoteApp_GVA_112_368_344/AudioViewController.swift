//
//  AudioViewController.swift
//  NoteApp_GVA_112_368_344
//
//  Created by Mac on 6/20/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import AVFoundation


// protocol used for sending data back
protocol DataEnteredDelegateAudio {
    func userDidEnterInformation(name:String)
}

class AudioViewController: UIViewController , AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var recordBtn: UIButton!

    var delegate: DataEnteredDelegateAudio?
    var audioTitle: String?
    var voiceRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var isPlaying = false
    var fileName = ""
   
    @IBOutlet weak var imageview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fileName = randomString(length: 10)
        
        self.delegate?.userDidEnterInformation(name: fileName)
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func setupRecorder(){
        
        let audioFilename = getCacheDirectory().appendingPathComponent(fileName)
        let recordSetting = [ AVFormatIDKey : kAudioFormatAppleLossless ,
                              AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                              AVEncoderBitRateKey : 320000,
                              AVNumberOfChannelsKey : 2,
                              AVSampleRateKey : 44100.2 ] as [String : Any]
        do {
            voiceRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSetting)
            print(audioFilename)
            
            voiceRecorder.delegate = self
            voiceRecorder.prepareToRecord()
        } catch {
            print(error)
        }
        
    }
    
    func getCacheDirectory() -> URL {
        let fm = FileManager.default
        let docsurl = fm.urls(for:.documentDirectory, in: .userDomainMask)
        
        let documentDirectory = docsurl[0]
        return documentDirectory
    }
    
    func setupPlayer() {
        let audioFilename = getCacheDirectory().appendingPathComponent(fileName)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer.delegate = self
            print(audioFilename)
            let fileName = audioFilename.absoluteString
            let documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentDirURL.appendingPathComponent(fileName)
            print("File PAth: \(fileURL)")
            print(fileName)
            self.fileName = audioFilename.absoluteString
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
        } catch {
            print(error)
        }
    }
    
    @IBAction func record(sender: UIButton) {
        if sender.titleLabel?.text == "Record"{
            
            setupRecorder()
            voiceRecorder.record()
            sender.setTitle("Stop", for: .normal)
            playBtn.isEnabled = false
           
        } else{
            voiceRecorder.stop()
      
            sender.setTitle("Record", for: .normal)
            playBtn.isEnabled = false
        }
    }
    
   
   
       
    @IBAction func recordPlayAudio(sender: UIButton) {
        if sender.titleLabel?.text == "Play" {
            recordBtn.isEnabled = false
            sender.setTitle("Stop", for: .normal)
            setupPlayer()
            audioPlayer.play()
           
            
        }
        else{
            audioPlayer.stop()
            sender.setTitle("Play", for: .normal)
            recordBtn.isEnabled = false
        }
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playBtn.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordBtn.isEnabled = true
        playBtn.setTitle("Play", for: .normal)
    }
}
