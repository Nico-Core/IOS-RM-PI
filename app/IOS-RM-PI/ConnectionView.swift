//
//  ConnectionView.swift
//  IOS-RM-PI
//
//  Created by Nicolas Kohr on 26.05.20.
//  Copyright © 2020 Nicolas Kohr. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var ip : String = ""
    @State var port : String = ""
    @State var errToCon : Bool = false
    
    
    func buttonActionConnect() {
        do{
            try Client.shared.connect(ip: self.ip, port: self.port)
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
    static var previews: some View {
        ConnectionView().environmentObject(ViewRouter())
    }
}