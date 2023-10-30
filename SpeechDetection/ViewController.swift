//
//  ViewController.swift
//  SpeechDetection
//
//  Created by somsak on 6/10/2566 BE.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    //MARK: - OUTLET PROPERTIES
       @IBOutlet weak var lb_speech: UILabel!
       @IBOutlet weak var view_color: UIView!
       @IBOutlet weak var btn_start: UIButton!
       
       //MARK: - Local Properties
       let audioEngine = AVAudioEngine()
       let speechReconizer : SFSpeechRecognizer? = SFSpeechRecognizer()
       let request = SFSpeechAudioBufferRecognitionRequest()
       var task : SFSpeechRecognitionTask!
       var isStart : Bool = false
    
    @IBAction func btn_start_stop(_ sender: Any) {
        //MARK:- Coding for start and stop sppech recognization...!
        isStart = !isStart
        if isStart {
            startSpeechRecognization()
            btn_start.setTitle("STOP", for: .normal)
            btn_start.backgroundColor = .systemGreen
        }else {
            cancelSpeechRecognization()
            btn_start.setTitle("START", for: .normal)
            btn_start.backgroundColor = .systemOrange
        }
    }
    
    func startSpeechRecognization(){
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch let error {
            print("Error comes here for starting the audio listner =\(error.localizedDescription)")
        }
        
        guard let myRecognization = SFSpeechRecognizer() else {
            print("Recognization is not allow on your local")
            return
        }
        
        if !myRecognization.isAvailable {
            print("Recognization is free right now, Please try again after some time.")
        }
        
        task = speechReconizer?.recognitionTask(with: request, resultHandler: { (response, error) in
            guard let response = response else {
                if error != nil {
                    print(error.debugDescription)
                }else {
                    print("Problem in giving the response")
                }
                return
            }
            
            let message = response.bestTranscription.formattedString
            print("Message : \(message)")
            self.lb_speech.text = message
            
            
            var lastString: String = ""
            for segment in response.bestTranscription.segments {
                let indexTo = message.index(message.startIndex, offsetBy: segment.substringRange.location)
                lastString = String(message[indexTo...])
            }
            
            if lastString == "red" {
                self.view_color.backgroundColor = .systemRed
            } else if lastString.elementsEqual("green") {
                self.view_color.backgroundColor = .systemGreen
            } else if lastString.elementsEqual("pink") {
                self.view_color.backgroundColor = .systemPink
            } else if lastString.elementsEqual("blue") {
                self.view_color.backgroundColor = .systemBlue
            } else if lastString.elementsEqual("black") {
                self.view_color.backgroundColor = .black
            }
            
            
        })
    }
    
    //MARK: UPDATED FUNCTION

        func cancelSpeechRecognization() {
            task.finish()
            task.cancel()
            task = nil
            
            request.endAudio()
            audioEngine.stop()
            //audioEngine.inputNode.removeTap(onBus: 0)
            
            //MARK: UPDATED
            if audioEngine.inputNode.numberOfInputs > 0 {
                audioEngine.inputNode.removeTap(onBus: 0)
            }
        }
}

