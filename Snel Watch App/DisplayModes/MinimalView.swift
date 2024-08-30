//
//  MinimalView.swift
//  Snel Watch App
//
//  Created by Jordi Bruin on 30/08/2024.
//

import SwiftUI
import Defaults

struct MinimalView: View {
    
    @Environment(LocationManager.self) var locationManager
    @Default(.decimalCount) var decimalCount
    @Default(.selectedSpeedOption) var selectedSpeedOption
    @Default(.selectedTheme) var selectedTheme
    
    @State var showNoMovementOverlay = false
    
    var body: some View {
        ZStack {
            mainCircle
//            speedText
            
            arrow
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
    
    var arrow: some View {
        Rectangle()
            .rotationEffect(.degrees((trimTo * 360) - 3), anchor: .bottom)
            .frame(width: 2, height: 88)
            .offset(y: -40)
            .foregroundColor(selectedTheme.color)
            .rotationEffect(.degrees(-131))
            .animation(.easeInOut(duration: 1), value: trimTo)
    }
    
    var trimTo: Double {
        return locationManager.correctSpeed / selectedSpeedOption.max * 0.742
    }
    
    var mainCircle: some View {
        ZStack {
            Circle()
                .trim(from: trimTo + 0.0025, to: 0.742)
                .stroke(Color.white.opacity(0.2),
                        style: StrokeStyle(
                            lineWidth: 3))
                .scaleEffect(1.015)
            
            // white bar
            Circle()
                .trim(from: 0, to: trimTo - 0.0025)
                .stroke(Color.white,
                        style: StrokeStyle(
                            lineWidth: 5))
        }
        .rotationEffect(.degrees(138))
        .animation(.easeInOut(duration: 1), value: trimTo)
    }
}

#Preview {
    MinimalView()
        .environment(LocationManager())
}
