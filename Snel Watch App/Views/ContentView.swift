//
//  ContentView.swift
//  Snel
//
//  Created by Jordi Bruin on 13/08/2024.
//

import SwiftUI
import MapKit
import Defaults

struct ContentView: View {
    
    @Environment(LocationManager.self) var locationManager
    
    @Default(.selectedTheme) var selectedTheme
    
    @State var showSettings = false
    @State var selectedDisplayMode: DisplayMode = .speedometer
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedDisplayMode) {
                ForEach(DisplayMode.allCases) { mode in
                    mode.view.tag(mode)
                        .containerBackground(selectedTheme.color.gradient, for: .tabView)
                }
            }
            .tabViewStyle(.verticalPage)
            .toolbar {
                if selectedDisplayMode == .speedometer {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: SettingsView()) {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                    }
                }
            }
            .sheet(isPresented: $showSettings, content: {
                SettingsView()
            })
        }
    }
}

#Preview {
    ContentView()
        .environment(LocationManager())
}
