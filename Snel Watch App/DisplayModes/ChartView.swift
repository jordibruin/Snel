//
//  ChartView.swift
//  Snel Watch App
//
//  Created by Jordi Bruin on 26/08/2024.
//

import SwiftUI
import Charts
import Defaults

struct ChartView: View {
    
    @Environment(LocationManager.self) var locationManager
    @Default(.selectedSpeedOption) var selectedSpeedOption
    @Default(.selectedTheme) var selectedTheme
    @Default(.decimalCount) var decimalCount
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom) {
                Text(String(format:"%.\(decimalCount)f", (locationManager.correctSpeed)))
                    .font(.title2)
                    .bold()
                    .contentTransition(.numericText())
                    .transaction {
                        $0.animation = .default
                    }
                    .monospacedDigit()
                
                Text(selectedSpeedOption.shortName)
                    .font(.system(size: 12))
                    .opacity(0.7)
                    .padding(.bottom, 5)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, -16)
            
            Chart {
                ForEach(locationManager.recentSnelSpeeds.suffix(30)) { snelSpeed in
                    LineMark(
                        x: .value("Time", snelSpeed.date),
                        y: .value("Speed", snelSpeed.userSelectedSpeed)
                    )
                    .foregroundStyle(selectedTheme.color)
                    .lineStyle(.init(lineWidth: 2))
                    
                    AreaMark(
                        x: .value("Time", snelSpeed.date),
                        y: .value("Speed", snelSpeed.userSelectedSpeed)
                    )
                    .foregroundStyle(
                        LinearGradient(colors: [
                            selectedTheme.color.opacity(0.7),
                            selectedTheme.color.opacity(0.1)
                        ], startPoint: .top, endPoint: .bottom)
                    )
                }
            }
            .chartXAxis(.hidden)
            .chartYScale(domain: 0...averageSpeed)
            .onTapGesture {
                locationManager.recentSnelSpeeds.removeAll()
            }
        }
    }
    
    var averageSpeed: Double {
        if let max = locationManager.recentSnelSpeeds.suffix(30).max() {
            return max.userSelectedSpeed + 5
        } else {
            return locationManager.correctMaxSpeed
        }
    }
}

#Preview(body: {
    ChartView()
        .environment(LocationManager())
})
