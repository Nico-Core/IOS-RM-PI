//
//  ConnectionView.swift
//  IOS-RM-PI
//

import Foundation
import Combine
import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var client: Client
    
    @State private var ip : String = ""
    @State private var port : String = ""
    @State private var errToCon : Bool = false
    
    
    func buttonActionConnect() {
        do{
            try client.Connect(ip: self.ip, port: self.port)
            errToCon = false
            viewRouter.currentPage = "RemView"
        } catch {
            errToCon = true
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Willkommen zum PI Remote")
            
            HStack(alignment: .center) {
                Text("IP:")
                TextField("192.168.*.*", text: $ip).fixedSize().frame(width: 200, height: 20, alignment: .top)
            }
            
            HStack(alignment: .center) {
                Text("Port:")
                TextField("22", text: $port).fixedSize().frame(width: 200, height: 20, alignment: .top)
            }
            
            Spacer().frame(width: 200, height: 30, alignment: .center)
            
            Button(action: buttonActionConnect, label: {Text("Verbinden")})
            
            Spacer().frame(width: 200, height: 30, alignment: .center)
            
            if errToCon {
                Text("Verbindungsfehler").foregroundColor(.red)
            }
            
        }
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static let client = Client()
    
    static var previews: some View {
        ConnectionView().environmentObject(ViewRouter()).environmentObject(client)
    }
}
