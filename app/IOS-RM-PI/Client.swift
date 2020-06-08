//
//  client.swift
//  IOS-RM-PI
//
//  Created by Nicolas Kohr on 27.05.20.
//  Copyright © 2020 Nicolas Kohr. All rights reserved.
//

import Foundation
import SwiftUI
import Network

enum clientErr : Error{
    case failCon
    case failRecvData
    case failChangeState
}

public class data : ObservableObject{
    @Published var name : String
    @Published var state : Bool
    
    init( _ name : String , _ state : Bool ){
        self.state = state
        self.name = name
    }
}

fileprivate enum comProtcol : String{
        case isChanged = "1"
        case ok = "2"
        case sendData = "3"
        case fail = "4"
        case changeState = "5"
        case closeCon = "6"
        case end = "7"
}

public class Client : ObservableObject{
    @Published var clientData : [data]  = []
    
    init(){}
    
    func Connect( ip : String, port : String ) throws {
        guard !ip.isEmpty && !port.isEmpty else{
            throw clientErr.failCon
        }
    }
    
    func Disconnect(){
        print("Verbindung trennen")
    }
    
    func SendPinChange( _ name : String, _ state : Bool ) throws {
        
    }
    
    func Refresh() throws {
        
    }
    
    private func SendCom( _ command : comProtcol ){
        
    }
    
}

