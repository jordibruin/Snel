//
//  Snel_WatchApp.swift
//  Snel Watch Watch App
//
//  Created by Jordi Bruin on 13/08/2024.
//

import SwiftUI

@main
struct Snel_Watch_Watch_AppApp: App {
    
    @State var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(locationManager)
        }
    }
}
