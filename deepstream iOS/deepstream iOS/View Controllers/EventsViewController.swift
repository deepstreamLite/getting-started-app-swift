//
//  EventsViewController.swift
//  deepstream iOS
//
//  Created by Akram Hussein on 18/02/2017.
//  Copyright © 2017 deepstreamHub GmbH. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController {

    @IBOutlet weak var publishButton: UIButton! {
        didSet {
            self.publishButton.layer.cornerRadius = 4.0
        }
    }
    
    @IBOutlet weak var publishTextField: UITextField!
    
    @IBOutlet weak var subscribeTextView: UITextView!
    
    private var client : DeepstreamClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the pre-configured client
        guard let client = DeepstreamFactory.getInstance().getClient(DeepstreamHubURL) else {
            print("Error: Unable to initialize client")
            return
        }
        
        self.client = client
        
        /////////////////////////////////////////
        
        // Subscribe to `test-event`
        
        // Create EventListener to handle changes to an event
        final class DSEventListener : NSObject, EventListener {
            private var textView : UITextView!
            
            init(textView: UITextView) {
                self.textView = textView
                super.init()
            }
            
            func onEvent(_ eventName: String!, args: Any!) {
                guard let value = args as? String else {
                    print("Error: Unable to cast args as String")
                    return
                }
                
                print("Subscriber: Event '\(eventName!)' occurred with '\(value)'")
                self.textView.text?.append("Received test-event with \(value)\n")
            }
        }
        
        // Subscribe to an event and provide an EventListener that can handle the changes
        self.client?.event.subscribe("test-event", eventListener: DSEventListener(textView: self.subscribeTextView))
    }
    
    // Whenever the user clicks the button
    // Publish an event called `test-event` and send
    @IBAction func publishButtonPressed(_ sender: Any) {
        guard let text = publishTextField.text, text.characters.count > 0 else {
            print("Error: No text to publish")
            return
        }
        print("Publisher: Emitting event \(text)")
        self.client?.event.emit("test-event", data: text)
    }
}

