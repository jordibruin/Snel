//
//  SnelApp.swift
//  Snel Watch App
//
//  Created by Jordi Bruin on 21/08/2024.
//

import SwiftUI

@main
struct Snel_Watch_AppApp: App {
    @State var locationManager = LocationManager()
        
        var body: some Scene {
            WindowGroup {
                ContentView()
                    .environment(locationManager)
            }
        }

}
