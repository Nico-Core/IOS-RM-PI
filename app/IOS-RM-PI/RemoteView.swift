//
//  RemoteView.swift
//  IOS-RM-PI
//
//  Created by Nicolas Kohr on 26.05.20.
//  Copyright © 2020 Nicolas Kohr. All rights reserved.
//

import SwiftUI

struct RemoteView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var client: Client
    
    func buttonActionDisconnect(){
        self.viewRouter.currentPage = "ConView"
        do{
            try self.client.Disconnect()
        }catch{
            //EnvironmentObject as error message
        }
    }
    
    var body: some View {
        VStack{
            Text("Liste der schaltbaren Objekte").bold().font(.headline)
            List( 0..<client.clientData.count ){ i in
                Toggle(isOn: self.$client.clientData[i].state, label: { Text(self.client.clientData[i].name) })
            }
            
            Button(action: buttonActionDisconnect, label: {Text("Trennen")
                .bold()
                .frame(width: 300, height: 50, alignment: .top)})
                .buttonStyle(PlainButtonStyle())
        }
    }
}

struct RemoteView_Previews: PreviewProvider {
    static let client = Client()
    
    static var previews: some View {
        RemoteView().environmentObject(ViewRouter()).environmentObject(client)
    }
}
