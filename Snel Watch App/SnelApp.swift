//
//  SnelApp.swift
//  Snel Watch App
//
//  Created by Jordi Bruin on 21/08/2024.
//

import SwiftUI
import TelemetryClient

@main
struct Snel_Watch_AppApp: App {
    @State var locationManager = LocationManager()
    
    init() {
        TelemetryDeck.initialize(config: .init(appID: "25D36DE5-FF0E-4456-9BA9-47B66BBB6BD6"))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(locationManager)
        }
    }
    
}

