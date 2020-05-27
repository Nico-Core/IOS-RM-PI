//
//  client.swift
//  IOS-RM-PI
//
//  Created by Nicolas Kohr on 27.05.20.
//  Copyright © 2020 Nicolas Kohr. All rights reserved.
//

import Foundation
import Network

enum clientErr : Error{
    case failCon
}

public struct data{
    var name : String
    var state : Bool
}

public class Client{
    static let shared = Client()
    
    private init(){}
    
    func connect( ip : String, port : String ) throws {
        guard !ip.isEmpty && !port.isEmpty else{
            throw clientErr.failCon
        }
    }
    
    func disconnect(){
        print("Verbindung trennen")
    }
    
    func refresh( ){
        
    }
    
    func recvCom( ){
        
    }
    
    func sendCom( ){
        
    }
    
}

