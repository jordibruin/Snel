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
//            Section {
//                NavigationLink {
//                    SpeedThresholdList()
//                } label: {
//                    Text("Speed Levels")
//                }
//            }
            
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

struct SpeedThresholdList: View {
    
    
    @State var slowThresholdDouble: Double = 2
    @State var mediumThresholdDouble: Double = 4
    @State var fastThresholdDouble: Double = 6
    
    @Default(.slowThreshold) var slowThreshold
    @Default(.mediumThreshold) var mediumThreshold
    @Default(.fastThreshold) var fastThreshold
    
    var values: [Double] {
        var values: [Double] = []
        
        for i in 1...1000 {
            values.append(Double(i) * 0.1)
        }
        return values
    }
    
    init() {
        
    }
    
    @Default(.selectedSpeedOption) var selectedSpeedOption
    
    @Environment(LocationManager.self) var locationManager
    
    var body: some View {
        List {
        
            Section {
                HStack {
                    Text("Slow")
                    Spacer()
                    Picker(selection: $slowThresholdDouble) {
                        ForEach(values, id: \.self) { value in
                            Text(String(format:"%.1f", (value)))
                        }
                    } label: {
                        Text("Slow")
                    }
                    .labelsHidden()
                    .pickerStyle(.navigationLink)
                    .onChange(of: slowThresholdDouble) { oldValue, newValue in
                        slowThreshold = SnelSpeed(meterPerSecond: newValue.convertToMeterPerSecond(speedOption: selectedSpeedOption), date: Date())
                    }
                    .frame(width: 70)
                }
                
                HStack {
                    Text("Medium")
                    Spacer()
                    Picker(selection: $mediumThresholdDouble) {
                        ForEach(values, id: \.self) { value in
                            Text(String(format:"%.1f", (value)))
                        }
                    } label: {
                        Text("Medium")
                    }
                    .labelsHidden()
                    .pickerStyle(.navigationLink)
                    .onChange(of: mediumThresholdDouble) { oldValue, newValue in
                        mediumThreshold = SnelSpeed(meterPerSecond: newValue.convertToMeterPerSecond(speedOption: selectedSpeedOption), date: Date())
                    }
                    .frame(width: 70)
                }
                
                HStack {
                    Text("Fast")
                    Spacer()
                    Picker(selection: $fastThresholdDouble) {
                        ForEach(values, id: \.self) { value in
                            Text(String(format:"%.1f", (value)))
                        }
                    } label: {
                        Text("Fast")
                    }
                    .labelsHidden()
                    .pickerStyle(.navigationLink)
                    .onChange(of: fastThresholdDouble) { oldValue, newValue in
                        fastThreshold = SnelSpeed(meterPerSecond: newValue.convertToMeterPerSecond(speedOption: selectedSpeedOption), date: Date())
                    }
                    .frame(width: 70)
                }
            } header: {
                HStack {
                    Spacer()
                    
                    Text("\(locationManager.correctSpeed)")
                    Text(selectedSpeedOption.shortName)
                        .font(.caption)
                        .padding(.trailing, 16)
                }
            } footer: {
                Text("Adjust the threshold for slow, medium and fast speeds")
            }
            
            Section {
                Button(action: {
                    slowThreshold = SnelSpeed(meterPerSecond: 2.0, date: Date())
                    mediumThreshold = SnelSpeed(meterPerSecond: 4, date: Date())
                    fastThreshold = SnelSpeed(meterPerSecond: 6, date: Date())
                }, label: {
                    Text("Reset Defaults")
                })
            }
        }
        .onAppear {
            self.slowThresholdDouble = slowThreshold.meterPerSecond
            self.mediumThresholdDouble = mediumThreshold.meterPerSecond
            self.fastThresholdDouble = fastThreshold.meterPerSecond
        }
    }
}

extension Double {
    
    func correctSpeedFor(speedOption: SpeedOption) -> Double {
        switch speedOption {
        case .metersPerSecond:
            self
        case .kilometsPerHour:
            Measurement(
                value: self,
                unit: UnitSpeed.metersPerSecond
            ).converted(to: .kilometersPerHour).value
        case .milesPerHour:
            Measurement(
                value: self,
                unit: UnitSpeed.metersPerSecond
            ).converted(to: .milesPerHour).value
        }
    }
    
    func convertToMeterPerSecond(speedOption: SpeedOption) -> Double {
        switch speedOption {
        case .metersPerSecond:
            self
        case .kilometsPerHour:
            Measurement(
                value: self,
                unit: UnitSpeed.kilometersPerHour
            ).converted(to: .metersPerSecond).value
        case .milesPerHour:
            Measurement(
                value: self,
                unit: UnitSpeed.milesPerHour
            ).converted(to: .metersPerSecond).value
        }
    }
}
