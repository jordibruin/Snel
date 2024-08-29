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
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State var showMiles = false
    @State var showSettings = false
    
    @Namespace private var namespace
    @State var selectedDisplayMode: DisplayMode = .graph
    @Default(.selectedTheme) var selectedTheme
    
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
                if selectedDisplayMode == .graph {
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

