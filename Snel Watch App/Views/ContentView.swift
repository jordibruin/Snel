//
//  ContentView.swift
//  Snel
//
//  Created by Jordi Bruin on 13/08/2024.
//

import SwiftUI
import MapKit
import Defaults
import StoreKit

struct ContentView: View {
    
    @Environment(LocationManager.self) var locationManager
    
    @Default(.selectedTheme) var selectedTheme
    
    @State var showSettings = false
    @State var selectedDisplayMode: DisplayMode = .speedometer
    
    @State var showPaywall = false
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedDisplayMode) {
                ForEach(DisplayMode.allCases) { mode in
                    mode.view.tag(mode)
                        .containerBackground(selectedTheme.color.gradient, for: .tabView)
                }
            }
//            .overlay(
//                Button(action: {
//                    showPaywall = true
//                }, label: {
//                    
//                    Text("Unlock")
//                        .padding()
//                        .padding(.horizontal, 12)
//                        .background(.thinMaterial)
//                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//                })
//                .buttonStyle(.plain)
//            )
            .sheet(isPresented: $showPaywall, content: {
                StoreView(ids: ["com.goodsnooze.sneller.prolifetime"])
            })
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
