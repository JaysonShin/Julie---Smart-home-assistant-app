//
//  MusicPlayerViewController.swift
//  MusicPlayerTest
//
//  Created by Edward Wei on 4/28/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

import UIKit
import AVFoundation
import Just

/*
 
 Happy
 Pharrell Williams - Happy
 Maroon 5 - Moves like Jagger
 Uncle Kracker - Smile
 
 Sad
 Adele - Someone Like You
 Sam Smith - Stay With Me
 Rihanna - Stay
 
 Angry
 Limp Bizkit - Break Stuff
 Disturbed - Down With The Sickness
 
 Fear
 Westlife - You raise me up
 Whitney Houston - When You Believe
 
 Surprise
 PSY - Gangnam Style

 
 */

var joyMap: [String:String] = [
    "joy1" : "Pharrell Williams - Happy",
    "joy2" : "Maroon 5 - Moves like Jagger"
]

var sadMap: [String:String] = [
    "sad1" : "Adele - Someone Like You",
    "sad2" : "Sam Smith - Stay With Me"
]

var angerMap: [String:String] = [
    "anger1" : "Limp Bizkit - Break Stuff",
    "anger2" : "Disturbed - Down With The Sickness"
]

var fearMap: [String:String] = [
    "fear1" : "Westlife - You raise me up",
    "fear2" : "Whitney Houston - When You Believe"
]

var surpriseMap: [String:String] = [
    "surprise1" : "PSY - Gangnam Style"
]

var emotionMap: [String:[String:String]] = [
    "joy" : joyMap,
    "anger" : angerMap,
    "sadness" : sadMap,
    "fear" : fearMap,
    "surprise" : surpriseMap
]

class MusicPlayerViewController: UIViewController, AVAudioPlayerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pausePlayBtn: UIButton!
    @IBOutlet weak var songLabel: UILabel!
    
    var musicPlayer: AVAudioPlayer  = AVAudioPlayer()
    var musicFiles = [String]()
    var currentIndex: Int = 0
    var timer: Timer?
    
    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBOutlet weak var musicSlider: UISlider!

    @IBAction func adjustVolume(_ sender: Any) {
        
        musicPlayer.volume = volumeSlider.value
    }
    
    @IBAction func nextSong(_ sender: Any) {
        currentIndex += 1
        if currentIndex == musicFiles.count {
            currentIndex = 0
        }
        
        songLabel.text = songDic[musicFiles[currentIndex]]
        playMusic(songName: musicFiles[currentIndex])
    }
    
    @IBAction func pausePlayPressed(_ sender: Any) {
        
        if musicPlayer.isPlaying {
            musicPlayer.pause()
            //update button image
            pausePlayBtn.setImage(UIImage(named: ""), for: UIControlState.normal)
            
        } else {
            musicPlayer.play()
            // update button image
            pausePlayBtn.setImage(UIImage(named: "pause (1).png"), for: UIControlState.normal)
        }
    }
    
    @IBAction func goHome(_ sender: Any) {
        performSegue(withIdentifier: "goHome", sender: self)
        //var test = hueControl("switchOff")
    }
    
    
    func hueControl(_ emotion: String) -> String {
        print(emotion)
        let URL = "http://192.168.1.7:9100/" + emotion
        Just.post(URL)
        
        return ""
    }
    
     func playMusic(songName: String){
        print(songName + " starts playing...")

        let filePath = NSString(string: Bundle.main.path(forResource: songName, ofType: "mp3")!)
        print(filePath)
        
        let fileURL = URL(fileURLWithPath: filePath as String)
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: fileURL, fileTypeHint: nil)
            musicPlayer.delegate = self
            musicPlayer.play()
        } catch {
            print(error)
        }
        
    }

    func updateTimeLabel() {
        print("Update Time Label")
        timeLabel.text = updateTime(musicPlayer.currentTime)
    }
    
    func updateTime(_ currentTime: TimeInterval) -> String {
        let current: Int = Int(currentTime)
        let minutes = current / 60
        let seconds = current % 60
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        return minutesString + ":" + secondsString
    }

    @IBOutlet weak var emotionStr: UILabel!
    var myEmotion = String()
    

    var songDic = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        musicPlayer = AVAudioPlayer()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)

        } catch {
            print(error)
        }
        
        songDic = emotionMap[myEmotion]!
        print(myEmotion + " received")

        for key in songDic.keys {
            print("====MusicFileAppend===" + key)
            musicFiles.append("\(key)")
        }
        
        currentIndex = Int(arc4random_uniform(UInt32(musicFiles.count)))
        print("===CurentIndex===" + String(currentIndex))

        let songFilename = musicFiles[currentIndex]
        let songDetail = songDic[songFilename]
    
        print("===Key====" + songFilename)
        print("===Value====" + songDetail!)
        
        songLabel.text = songDetail
        timeLabel.text = "00:00"
        
        playMusic(songName: songFilename)
        
        if timer == nil {
             timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MusicPlayerViewController.updateTimeLabel), userInfo: nil, repeats: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
           }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        musicPlayer.stop()
        songDic.removeAll()
        musicFiles.removeAll()
    }
    

    
}
