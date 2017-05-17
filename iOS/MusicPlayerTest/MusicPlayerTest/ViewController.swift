//
//  ViewController.swift
//  MusicPlayerTest
//
//  Created by Edward Wei on 4/27/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

import UIKit
import Just
import Speech

class ViewController: UIViewController {
    
    @IBOutlet weak var fearBtnConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var fearLabelConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textField: UITextField!
    var currEmotion = "joy"
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBAction func btnClicked(_ sender: Any) {
        if textField.text != "" {
              performSegue(withIdentifier: "emotion", sender: self)
        }
    }
    
    @IBOutlet weak var cameraBtn: UIButton!
    
    var hasBeenClicked = false
    var timer = Timer()
    @IBAction func cameraBtnClicked(_ sender: Any) {
        print("taking a picture......")
        //takePicture()
        textLabel.font = textLabel.font.withSize(18)
        textLabel.text = "Photo taken. Please wait for our anlyais..."
        //wait for a while, show loading....
        print("wait for a while......")
        //timer.invalidate()
        //timer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(ViewController.updateMoodFromPicture), userInfo: nil, repeats: false)
    }
    
    //take a picture
    func takePicture() {
        let URL = "http://192.168.1.5:8484/camera"
        var r = Just.post(URL)
        if(r.ok) {
            print("Picture taken OK!!!!!!")
        } else {
            print(r.statusCode)
        }
    }
    
    //get the mood
    func updateMoodFromPicture() {
        let URL = "http://192.168.1.5:8484/camera/mood"
        let r = Just.get(URL)
        print("updateMoodFromPicture "  + r.text!)
        if (r.ok && r.text!.lowercased().range(of:"joy") != nil) {
            print(r.statusCode)
            currEmotion = "joy"
        } else {
            print(r.statusCode)
            currEmotion = "sadness"
        }
        //changeLED()
        //hueControl(currEmotion)
        performSegue(withIdentifier: "goMusicPage", sender: self)

    }
    
    //change LED based on mood
    func changeLED() {
        /*
         ("neutral", "joy", "sad", "angry", "fear", "surprise") */
        
         var emoMap: [String:String] = [
         "joy" : "joy",
         "sadness" : "sad"
         ]
 
        print("==========The current mood is " + currEmotion)
        let URL = "http://192.168.1.5:8484/led"
        Just.put(URL)
        
        if let json = Just.put(
            URL,
            json:["mood":emoMap[currEmotion]]
            ).json as? [String:AnyObject] {
            let emo:String = json["mood"] as! String
            print("\(emo)")     // joy, sadness ...
        }
    }
    
    
    @IBAction func whenMicBtnClicked(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            micBtn.setImage(UIImage(named: "microphone (3).png"), for: UIControlState.normal)
            recognitionRequest?.endAudio()
            print("============stop recording, start analysis")
            currEmotion = textToEmotion()
            print("emotion" + currEmotion)
            hueControl(currEmotion)
            performSegue(withIdentifier: "goMusicPage", sender: self)
        } else {
            print("=============start recording")
            micBtn.setImage(UIImage(named: ""), for: UIControlState.normal)
            try! startRecording()
        }
    }
    
    @IBOutlet weak var micBtn: UIButton!
    
    var hasEmojiShown = false
    @IBAction func showEmojis(_ sender: Any) {
       UIView.animate(withDuration: 0.2) {
            self.emojis.forEach {
                $0.isHidden = !$0.isHidden
            }
        }
        
        UIView.animate(withDuration: 0.2) {
            self.emojiStrCol.forEach {
                $0.isHidden = !$0.isHidden
            }
        }
        
        
    
        if hasEmojiShown {
            //hide
            //change text
            hasEmojiShown = false
            textLabel.font = textLabel.font.withSize(20)
            textLabel.numberOfLines = 3
            textLabel.text = "Hi, how is your day going?"
            /*
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.stackViewConstraint.constant -= self.view.bounds.width
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.fearLabelConstraint.constant -= self.view.bounds.width
                self.view.layoutIfNeeded()
            }, completion: nil)
                                */
        } else {
            //show emoji
            //change text
            
            hasEmojiShown = true
            textLabel.font = textLabel.font.withSize(20)
            textLabel.numberOfLines = 3
            textLabel.text = "Choose an emoji to describe your feeling now."
            
            /*
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.stackViewConstraint.constant += self.view.bounds.width
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.fearLabelConstraint.constant += self.view.bounds.width
                self.view.layoutIfNeeded()
            }, completion: nil) */
            
        }
        
            }

    @IBAction func whenAnyEmojiClicked(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        currEmotion = button.currentTitle!
        print(currEmotion + " Clicked")
        //var res = hueControl(currEmotion)
        //print("==========" + res)
        performSegue(withIdentifier: "goMusicPage", sender: self)
    }
    
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mpController = segue.destination as! MusicPlayerViewController
        mpController.myEmotion = currEmotion
        //let speechText = textLabel.text
        //myController.speechText = speechText
   }
    
    
    @IBOutlet var emojis: [UIButton]! {
        didSet {
            emojis.forEach {
                $0.isHidden = true
            }
        }
    }
    
    @IBOutlet var emojiStrCol: [UILabel]!  {
        didSet {
            emojiStrCol.forEach {
                $0.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fearBtnConstraint.constant -= view.bounds.width
        //fearLabelConstraint.constant -= view.bounds.width
        //stackViewConstraint.constant -= view.bounds.width
        
        
        textLabel.font = textLabel.font.withSize(24)
        textLabel.numberOfLines = 2
        textLabel.text = "Hi, how is your day going?"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //==============
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    //Post text to the REST API
    func hueControl(_ emotion: String) -> String {
        
        
        print(emotion)
        /*
        current IP = 192.168.1.10
        port number = 9100
        commands:
        
        1. switchOn
        2. switchOff
        3. happy
        4. sad
        5. surprise
        6. angry
        7.fear
        */
        
        let URL = "http://192.168.1.7:9100/" + emotion
        
        print("http://192.168.1.7:9100/" + emotion)
        
        //Just.post(URL)
        Just.post(URL)
        
        return ""
    }
    
    //Post text to the REST API
    func textToEmotion() -> String {
        let URL = "https://whispering-peak-14834.herokuapp.com/"
        let inputText = textLabel.text
        
        if let json = Just.post(
            URL,
            json:["text":inputText]
            ).json as? [String:AnyObject] {
            let emo:String = json["emotion"] as! String
            print("\(emo)")     // joy, sadness ...
            //emotionLabel.text = emotion;
            return emo
        }
        return "error"
    }

    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                self.textLabel.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                //self.recordButton.isEnabled = true
                //self.recordButton.setTitle("Start Recording", for: [])
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        textLabel.text = "Go ahead, I'm listening."
    }
    


}

