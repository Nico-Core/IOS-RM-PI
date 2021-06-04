//
//  client.swift
//  IOS-RM-PI
//

import Foundation
import SwiftUI
import Socket

enum clientErr : Error{
    case failCon
    case failRecvData
    case failChangeState
}


public class data : ObservableObject{
    var c: Client
    
    @Published var name : String
    @Published var state : Bool {
        didSet{
            do{
                try c.SendPinChange(name, state)
            }catch{
                //EnvironmentObject as error message
            }
        }
    }
    
    init( _ name : String , _ state : Bool , _ cl : Client  ){
        self.state = state
        self.name = name
        self.c = cl
    }
}


fileprivate enum comProtcol : String{
        case isChanged = "1"
        case ok = "2"
        case fail = "3"
        case changeState = "4"
        case closeCon = "5"
        case end = "6"
}


final public class Client : ObservableObject{
    @Published var clientData : [data]  = []
    var connect : Socket?
    

    init(){}
    
    func Connect( ip : String, port : String ) throws{
        guard !ip.isEmpty && !port.isEmpty else{
            throw clientErr.failCon
        }
        
        do{
            connect = try Socket.create(family: .inet, type: .stream, proto: .tcp)
            if let con = connect{
                con.readBufferSize = 11
                try con.connect(to: ip, port: Int32(port)!, timeout: 100)
                try Refresh()
            }else{
                throw clientErr.failCon
            }
        }catch(let error){
            print(error.localizedDescription)
            throw clientErr.failCon
        }
    }
    
    
    func Disconnect() throws{
        try SendCom(comProtcol.closeCon)
        if let con = self.connect{
            con.close()
        }else{
            throw clientErr.failCon
        }
        print("Verbindung trennen")
    }
    
    
    func SendPinChange( _ name : String, _ state : Bool ) throws {
        try SendCom( comProtcol.changeState )
        
        if try ReceiveCom() == comProtcol.ok{
            var buffer : Data = Data(capacity: 11)
            buffer.append(name.data(using: .utf8)!)
            buffer.append( UInt8( truncating: NSNumber(value: state) ) )
            
            try SendData(Data: buffer)
        }else{
            throw clientErr.failChangeState
        }
        
    }
    
    
    func Refresh() throws {
        var dataBuffer : [Data] = []
        
        try SendCom(comProtcol.isChanged)
        
        let com = try ReceiveCom()
        print("ReceiveCom()")
        if com == comProtcol.ok{
            print("Command: ok")
            
            let numberOfData = try ReceiveData(size: 1)
            print("Receive number of data: \(String(decoding: numberOfData, as: UTF8.self))")
            
            try SendCom(comProtcol.ok)
            print("Send command:  ok")
            
            for _ in 1...UInt8(String(decoding: numberOfData, as: UTF8.self))!{
                let rdata = try ReceiveData(size: 11)
                dataBuffer.append(rdata)
            }
            print("Data received")
            
        }else if com == comProtcol.end{
            print("no data")
            return
        }else{
            print("receive error: command fatal error")
            throw clientErr.failRecvData
        }
        
        clientData.removeAll()
        
        for rawData in dataBuffer{
            clientData.append( data( String(decoding: rawData[0...9], as: UTF8.self), Bool( truncating: rawData.last! as NSNumber ), self ) )
        }
    }
    
    
    private func ReceiveData( size s : UInt8) throws -> Data{
        let dataBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(s))
        
        if let con = connect{
            guard try con.read(into: dataBuffer, bufSize: Int(s), truncate: true) > 0 else{
                throw clientErr.failRecvData
            }
        }else{
            throw clientErr.failCon
        }
        
        return Data(bytes: dataBuffer, count: Int(s))
    }
    
    
    private func SendData( Data d : Data ) throws {
        if let con = connect{
            try con.write(from: d)
        }else{
            throw clientErr.failCon
        }
    }
    
    
    private func SendCom( _ command : comProtcol ) throws{
        if let con = connect{
            try con.write(from: command.rawValue)
        }else{
            throw clientErr.failCon
        }
    }
    
    
    private func ReceiveCom() throws -> comProtcol{
        var commandBuffer = Data()
        
        do{
            commandBuffer = try ReceiveData(size: 1)
        }catch{
            throw clientErr.failRecvData
        }
            
        return comProtcol(rawValue: String(decoding: commandBuffer, as: UTF8.self)) ?? comProtcol.fail
    }
}
