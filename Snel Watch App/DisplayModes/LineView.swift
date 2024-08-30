//
//  LineView.swift
//  Snel Watch App
//
//  Created by Jordi Bruin on 30/08/2024.
//

import SwiftUI
import Defaults

struct LineView: View {
    
    @Environment(LocationManager.self) var locationManager
    @Default(.decimalCount) var decimalCount
    @Default(.selectedSpeedOption) var selectedSpeedOption
    @Default(.selectedTheme) var selectedTheme
    
    @State var showNoMovementOverlay = false
    
    var body: some View {
        ZStack {
            mainCircle
            speedText
        }
    }
    
    var speedText: some View {
        Text(String(format:"%.\(decimalCount)f", (locationManager.correctSpeed)))
            .font(decimalCount < 1 ? .system(size: 72) : decimalCount <= 2 ? .largeTitle : .title)
            .minimumScaleFactor(0.5)
            .bold()
            .contentTransition(.numericText())
            .transaction {
                $0.animation = .default
            }
            .monospacedDigit()
    }

    var mainCircle: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.742)
                .stroke(selectedTheme.color.opacity(0.2),
                        style: StrokeStyle(
                            lineWidth: 14,
                            lineCap: .butt,
                            lineJoin: .miter,
                            miterLimit: 0,
                            dash: [2, 4],
                            dashPhase: 0))
            
            Circle()
                .trim(from: 0, to: (locationManager.correctSpeed / selectedSpeedOption.max) * 0.742)
//                .trim(from: 0, to: 0.4)
                .stroke(selectedTheme.color,
                        style: StrokeStyle(
                            lineWidth: 14,
                            lineCap: .butt,
                            lineJoin: .miter,
                            miterLimit: 0,
                            dash: [2, 4],
                            dashPhase: 0))
        }
        .rotationEffect(.degrees(138))
    }
}

#Preview {
    LineView()
        .environment(LocationManager())
}
