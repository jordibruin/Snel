//
//  SettingsView.swift
//  Snel
//
//  Created by Jordi Bruin on 21/08/2024.
//

import Foundation
import Defaults
import SwiftUI

struct SettingsView: View {
    
    @Environment(LocationManager.self) var locationManager
    
    @AppStorage("showMiles") var showMiles: Bool = false
    
    @Default(.selectedSpeedOption) var selectedSpeedOption
    @Default(.maxSpeedInMetersPerSecond) var maxSpeedInMetersPerSecond
    @Default(.decimalCount) var decimalCount
    @Default(.selectedTheme) var selectedTheme
        
    var body: some View {
        List {
            
            
            
            Section {
                HStack {
                    ForEach(Theme.allCases) { theme in
                        ZStack {
                            Circle()
                                .foregroundColor(theme.color)
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    withAnimation {
                                        selectedTheme = theme
                                    }
                                }
                            
                            if theme == selectedTheme {
                                Circle()
                                    .stroke(
                                        .black.opacity(0.3),
                                        style: .init(
                                            lineWidth: 6,
                                            lineCap: .butt
                                        )
                                    )
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                        
                }
            } header: {
                Text("Theme")
            }
            
            Section {
                Picker(selection: $selectedSpeedOption) {
                    ForEach(SpeedOption.allCases) { option in
                        Text(option.name).tag(option)
                    }
                } label: {
                    Text("Speed Unit")
                }
                
                HStack {
                    Text("Maximum")
                    Spacer()
                    
                    VStack(spacing: -2) {
                        
                        Text(String(format:"%.\(decimalCount)f", (locationManager.correctMaxSpeed)))
                            .bold()
                        Text(selectedSpeedOption.shortName)
                            .font(.system(size: 12))
                    }
                }
                Button(action: {
                    maxSpeedInMetersPerSecond = 0.0
                }, label: {
                    Label("Reset Max Speed", systemImage: "gauge.with.dots.needle.0percent")
                })
            } header: {
                Text("Speed")
            }
                  
            Section {
                HStack {
                    Text("Decimals")
                    Spacer()
                
                    Picker(selection: $decimalCount) {
                        ForEach(0...2, id: \.self) { decimal in
                            Text("\(decimal)").tag(decimal)
                                .bold()
                        }
                    } label: {
                    }
                    .frame(width: 40)
                    
                }
            } header: {
                Text("Advanced")
            }
            
        }
    }
}



#Preview {
    SettingsView()
        .environment(LocationManager())
}
