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
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Max Speed")
                    Spacer()
                    
                    VStack {
                        Text(String(format:"%.\(decimalCount)f", (locationManager.correctMaxSpeed)))
                            .bold()
                        Text(selectedSpeedOption.shortName)
                    }
                    .font(.caption)
                }
                Button(action: {
                    maxSpeedInMetersPerSecond = 0.0
                }, label: {
                    Label("Reset Max Speed", systemImage: "gauge.with.dots.needle.0percent")
                })
            }
            
            Section {
                Picker(selection: $selectedSpeedOption) {
                    ForEach(SpeedOption.allCases) { option in
                        Text(option.name).tag(option)
                    }
                } label: {
                    Text("Speed Unit")
                }
            }
            
            Section {
                Picker(selection: $decimalCount) {
                    ForEach(0...3, id: \.self) { decimal in
                        Text("\(decimal)").tag(decimal)
                    }
                } label: {
                    Text("Decimals")
                }
            }
        }
    }
    
    
}


