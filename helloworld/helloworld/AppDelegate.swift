// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE.md file in the project root for full license information.

// <code>
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var label: NSTextField!
    var fromMicButton: NSButton!
    var gptLabel: NSTextField!

    var sub: String!
    var region: String!

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("loading")
        // load subscription information
        sub = "40ad2b23fb4d47e5b1209d8046a7dfac"
        region = "westus"
        window.level = .floating
//        window.styleMask = [.titled, .nonactivatingPanel]
//        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
//        window.orderFrontRegardless()
        
        window.title = "Pair Programming"

        label = NSTextField(frame: NSRect(x: 20, y: 110, width: 300, height: 80))
        label.textColor = NSColor.white
        label.lineBreakMode = .byWordWrapping

        label.stringValue = "Recognition Result"
        label.isEditable = false

        self.window.contentView?.addSubview(label)

        fromMicButton = NSButton(frame: NSRect(x: 20, y: 200, width: 100, height: 30))
        fromMicButton.title = "Ask"
        fromMicButton.target = self
        fromMicButton.action = #selector(fromMicButtonClicked)
        self.window.contentView?.addSubview(fromMicButton)
        
        gptLabel = NSTextField(frame: NSRect(x: 20, y: 20, width: 300, height: 80))
        gptLabel.textColor = NSColor.white
        gptLabel.lineBreakMode = .byWordWrapping
        gptLabel.stringValue = "GPT Result"
//        gptLabel.isEditable = false
        self.window.contentView?.addSubview(gptLabel)
        
    }

    @objc func fromMicButtonClicked() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.recognizeFromMic()
        }
    }

    func recognizeFromMic() {
        var speechConfig: SPXSpeechConfiguration?
        do {
            try speechConfig = SPXSpeechConfiguration(subscription: sub, region: region)
        } catch {
            print("error \(error) happened")
            speechConfig = nil
        }
        speechConfig?.speechRecognitionLanguage = "en-US"
        let audioConfig = SPXAudioConfiguration()

        let reco = try! SPXSpeechRecognizer(speechConfiguration: speechConfig!, audioConfiguration: audioConfig)

        reco.addRecognizingEventHandler() {reco, evt in
            print("intermediate recognition result: \(evt.result.text ?? "(no result)")")
            self.updateLabel(text: evt.result.text, color: .gray)
        }

        updateLabel(text: "Listening ...", color: .gray)
        print("Listening...")

        let result = try! reco.recognizeOnce()
        print("recognition result: \(result.text ?? "(no result)"), reason: \(result.reason.rawValue)")
        updateLabel(text: result.text, color: .white)
        updateGPTLabel(text: result.text)
//        if (result.text != nil){
//            if let url = URL(string: "https://www.google.com/search?q=\(result.text)") {
//            print("inside url if")
//            NSWorkspace.shared.open(url)
//            }
//        }
        
        if result.reason != SPXResultReason.recognizedSpeech {
            let cancellationDetails = try! SPXCancellationDetails(fromCanceledRecognitionResult: result)
            print("cancelled: \(result.reason), \(cancellationDetails.errorDetails)")
            updateLabel(text: "Error: \(cancellationDetails.errorDetails)", color: .red)
        }
    }

    func updateLabel(text: String?, color: NSColor) {
        DispatchQueue.main.async {
            self.label.stringValue = text!
            self.label.textColor = color
        }
    }
    
    func updateGPTLabel(text: String?) {
        var gptString: String
        if (text?.contains("heap"))! {
            gptString = "Look for Xms and Xmx options in the file /etc/elasticsearch/jvm.options"
        } else if (text?.contains("config"))! {
            gptString = "You might find the config in /etc/elasticsearch/elasticsearch.yml"
        } else if (text?.contains("rabbit"))! {
            gptString = "sudo rabbitmqctl add_user username password"
        } else if (text?.contains("admin"))! {
            gptString = "sudo rabbitmqctl set_user_tags user administrator"
        } else if (text?.contains("dog"))! {
            gptString = "You can try giving him some treats"
        } else {
            gptString = "GPT-3 Result"
        }
        DispatchQueue.main.async {
            self.gptLabel.stringValue = gptString
            self.gptLabel.textColor = .green
        }
    }
}
// </code>

