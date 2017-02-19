//
//  RecordsViewController.swift
//  deepstream iOS
//
//  Created by Akram Hussein on 18/02/2017.
//  Copyright © 2017 deepstreamHub GmbH. All rights reserved.
//

import UIKit

class RecordsViewController: UIViewController {

    @IBOutlet weak var firstnameTextField: UITextField!
    
    @IBOutlet weak var lastnameTextField: UITextField!
    
    private var client : DeepstreamClient?
    private var record : Record?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the pre-configured client
        guard let client = DeepstreamFactory.getInstance().getClient(DeepstreamHubURL) else {
            print("Error: Unable to initialize client")
            return
        }
        
        self.client = client
        
        /////////////////////////////////////////
        
        // Create or retrieve a record with the name test/johndoe
        
        // Get record handler
        guard let record = self.client?.record.getRecord("test/johndoe") else {
            return
        }
        
        self.record = record
        
        // Create a RecordPathChangedCallback that will handle changes to a record path
        final class NameRecordPathChangedCallback : NSObject, RecordPathChangedCallback {
            
            var textField : UITextField!
            
            init(textField: UITextField) {
                self.textField = textField
                super.init()
            }
            
            func onRecordPathChanged(_ recordName: String!, path: String!, data: JsonElement!) {
                print("Record '\(recordName!)' changed, data is now: \(data)")

                // Update text field in main thread
                DispatchQueue.main.async {
                    self.textField.text = "\(data.getAsString()!)"
                }
            }
        }
        
        // Subscribe to changes for path 'firstname' and provide a callback to handle changes
        record.subscribe("firstname", recordPathChangedCallback: NameRecordPathChangedCallback(textField: self.firstnameTextField))

        // Subscribe to changes for path 'firstname' and provide a callback to handle changes
        record.subscribe("lastname", recordPathChangedCallback: NameRecordPathChangedCallback(textField: self.lastnameTextField))
    }
    
    // We want to synchronize a path within the record, e.g. `firstname`
    // with an input so that every change to the input will be saved to the
    // record and every change from the record will be written to the input
    
    @IBAction func editingChanged(_ sender: UITextField) {
        
        // Identify which text field changed and set the relevant path
        let path = (sender == self.firstnameTextField) ? "firstname" : "lastname"
        
        // Set the record for the path
        if let record = self.record {
            record.set(path, value: sender.text)
        }
    }
}

