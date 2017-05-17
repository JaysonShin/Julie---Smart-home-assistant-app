//
//  RestViewController.swift
//  MusicPlayerTest
//
//  Created by Qian on 4/28/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

import UIKit
import Just

class RestViewController: UIViewController {
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var emotionLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitBtn(_ sender: Any) {
        let URL = "https://whispering-peak-14834.herokuapp.com/"
        let inputText = inputTextField.text
        //        let r = Just.get("https://whispering-peak-14834.herokuapp.com/")
        //        let emotion = r.text
        //        emotionLabel.text = emotion;
        
        //        Just.post(
        //            URL,
        //            json: ["text": inputText ?? ""]
        //        ) { r in
        //            if r.ok {
        //                /* success! */
        //                let response = r.json as? [String:AnyObject]
        //                let emotion = response?["emotion"]
        //                self.emotionLabel.text = emotion as! String
        //            }
        //        }
        
        if let json = Just.post(
            URL,
            json:["text":inputText]
            ).json as? [String:AnyObject] {
            let emotion:String = json["emotion"] as! String
            print("\(emotion)")     // joy, sadness ...
            emotionLabel.text = emotion;
        }
    }

    
}
