//
//  RPCViewController.swift
//  deepstream iOS
//
//  Created by Akram Hussein on 18/02/2017.
//  Copyright © 2017 deepstreamHub GmbH. All rights reserved.
//

import UIKit

typealias RpcRequestedListenerHandler = ((String, Any, RpcResponse) -> Void)

class RPCViewController: UIViewController {
    
    @IBOutlet weak var makeMultiplyButton: UIButton! {
        didSet {
            self.makeMultiplyButton.layer.cornerRadius = 4.0
        }
    }
    
    @IBOutlet weak var requestValueTextField: UITextField!
    
    @IBOutlet weak var displayResponseTextField: UITextField!
    
    @IBOutlet weak var multiplyNumberTextField: UITextField!
    
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
    
        final class DSRpcRequestedListener : NSObject, RpcRequestedListener {
            private var handler : RpcRequestedListenerHandler!
            
            init(handler: @escaping RpcRequestedListenerHandler) {
                self.handler = handler
            }
            
            func onRPCRequested(_ rpcName: String!, data: Any!, response: RpcResponse!) {
                self.handler(rpcName, data, response)
            }
        }
        
        client.rpc.provide("multiply-number",
                           rpcRequestedListener: DSRpcRequestedListener { (rpcName, data, response) in
                            print("RPC Provider: Got an RPC request")
                            
                            guard let value = (data as? Float) else {
                                print("Error: Unable to cast data to Float")
                                return
                            }
                            
                            guard let multiplyValue = self.multiplyNumberTextField.text,
                                multiplyValue.characters.count > 0 else {
                                print("Error: No multiple number provided")
                                return
                            }
                            
                            guard let multiplyValueFloat = Float(multiplyValue) else {
                                print("Error: Unable to convert multiple value to Float")
                                return
                            }
                            
                            response.send(value * multiplyValueFloat)
        })
    }
    
    @IBAction func makeMultiplyRequestButtonPressed(_ sender: Any) {
        guard let value = self.requestValueTextField.text,
            value.characters.count > 0 else {
            print("Error: No multiply number to request")
            return
        }
        
        guard let valueFloat = Float(value) else {
            print("Error: Unable to convert multiple value to Float")
            return
        }
        
        guard let rpcResponse = self.client?.rpc.make("multiply-number", data: valueFloat) else {
            print("Error: RPC failed")
            self.displayResponseTextField.text = "Error"
            return
        }
        
        guard let data = rpcResponse.getData() else {
            print("Error: Unable to parse RPC data")
            return
        }
        
        self.displayResponseTextField.text = "\(data)"
        
        print("RPC success with data: \(rpcResponse.getData()!)")
    }
}
