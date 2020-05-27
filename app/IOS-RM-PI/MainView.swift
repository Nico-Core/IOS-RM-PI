//
//  MainView.swift
//  IOS-RM-PI
//
//  Created by Nicolas Kohr on 27.05.20.
//  Copyright © 2020 Nicolas Kohr. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class ViewRouter: ObservableObject {
    let objectWillChange = PassthroughSubject<ViewRouter,Never>()
    
    var currentPage: String = "ConView"{
        didSet {
            objectWillChange.send(self)
        }
    }
}

struct MainView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        
        //No chance to implement it with switch cases >:-(
        VStack{
            if viewRouter.currentPage == "ConView" {
                ConnectionView()
            } else if viewRouter.currentPage == "RemView" {
                RemoteView()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(ViewRouter())
    }
}
