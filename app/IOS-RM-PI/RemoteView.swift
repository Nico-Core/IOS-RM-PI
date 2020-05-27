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
    
    @State var schalter : Bool = false
    
    var body: some View {
        NavigationView{
            VStack{
                Text("Liste der schaltbaren Objekte").bold().font(.headline)
                
                List{
                    Toggle(isOn: $schalter, label: {Text("Licht")})
                }
                
                Button(action: { self.viewRouter.currentPage = "ConView"}, label:
                    {Text("Trennen").bold().frame(width: 300, height: 50, alignment: .top)})
                    .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct RemoteView_Previews: PreviewProvider {
    static var previews: some View {
        RemoteView().environmentObject(ViewRouter())
    }
}
