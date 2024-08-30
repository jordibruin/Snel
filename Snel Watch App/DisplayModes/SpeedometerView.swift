//
//  SpeedometerView.swift
//  Snel Watch App
//
//  Created by Jordi Bruin on 30/08/2024.
//

import SwiftUI
import Defaults

struct SpeedometerView: View {
    
    @Environment(LocationManager.self) var locationManager
    @Default(.decimalCount) var decimalCount
    @Default(.selectedSpeedOption) var selectedSpeedOption
    @Default(.selectedTheme) var selectedTheme
    
    @State var showNoMovementOverlay = false
    
    var body: some View {
        circleView
    }
    
    var circleView: some View {
        VStack {
            ZStack {
//                testCircle
                mainCircle
                averageCircle

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
            
            if let error = locationManager.error {
                Text(error.localizedDescription)
                    .font(.caption)
            }
            
            if locationManager.correctSpeed <= 0 {
                HStack {
                    Spacer()
                    Text("No Movement Detected")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .layoutPriority(10)
                    
                    Spacer()
                    
                    Button(action: {
                        showNoMovementOverlay = true
                    }, label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                    })
                    .buttonStyle(.plain)
                    .layoutPriority(10)
                    
                    Spacer()
                }
                //                .padding(.horizontal, -20)
            } else {
                Text(selectedSpeedOption.shortName)
                    .foregroundStyle(.secondary)
                    .onTapGesture {
                        selectedSpeedOption = selectedSpeedOption.next()
                    }
            }
        }
        .sheet(isPresented: $showNoMovementOverlay, content: {
            Text("Snel uses GPS to determine your speed, please move around outside if you don't see any speed measurements.")
                .multilineTextAlignment(.center)
        })
    }
    
    
    var averageCircle: some View {
        ZStack {
            Circle()
                .frame(width: 4, height: 4)
                .foregroundColor(selectedTheme.color)
                .offset(y: 64)
                .rotationEffect(
                    .degrees(45)
                )
                .rotationEffect(
                    .degrees(locationManager.averageSpeed.userSelectedSpeed / selectedSpeedOption.max * 360)
//                    .degrees(10 / selectedSpeedOption.max * 360)
                )
                .opacity(locationManager.averageSpeed.userSelectedSpeed > 0 && locationManager.averageSpeed.userSelectedSpeed <= selectedSpeedOption.max ? 1 : 0)
        }
    }
    
    var testCircle: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.742)
                .stroke(Color(white: 140/255),
                        style: StrokeStyle(
                            lineWidth: 5,
                            lineCap: .butt,
                            lineJoin: .miter,
                            miterLimit: 0,
                            dash: [1, 4],
                            dashPhase: 0))
                .scaleEffect(1.025)
                
                
            
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.white,
                        style: StrokeStyle(
                            lineWidth: 10,
                            lineCap: .butt,
                            lineJoin: .miter,
                            miterLimit: 0,
                            dash: [1, 24],
                            dashPhase: 0))
        }
        .rotationEffect(.degrees(138))
        .padding(-16)
    }
    
    var mainCircle: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.742)
                .stroke(Color.white.opacity(0.5),
                        style: StrokeStyle(
                            lineWidth: 5,
                            lineCap: .butt,
                            lineJoin: .miter,
                            miterLimit: 0,
                            dash: [1, 4],
                            dashPhase: 0))
                .scaleEffect(1.04)
                
            Circle()
                .trim(from: 0, to: locationManager.correctSpeed / selectedSpeedOption.max)
                .stroke(
                    selectedTheme.color.opacity(0.6),
                    style: .init(
                        lineWidth: 14,
                        lineCap: .butt
                    )
                )
                .animation(.bouncy, value: locationManager.correctSpeed)
            
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.white,
                        style: StrokeStyle(
                            lineWidth: 12,
                            lineCap: .butt,
                            lineJoin: .miter,
                            miterLimit: 0,
                            dash: [1, 24],
                            dashPhase: 0))
            
            
        }
        .rotationEffect(.degrees(138))
        .padding(-16)
        
//        ZStack {
//            Circle()
//                .trim(from: 0, to: 0.75)
//                .stroke(Color(white: 140/255),
//                        style: StrokeStyle(
//                            lineWidth: 20,
//                            lineCap: .butt,
//                            lineJoin: .miter,
//                            miterLimit: 0,
//                            dash: [1, 4],
//                            dashPhase: 0))
//                .rotationEffect(.degrees(135))
//
//            Circle()
//                .trim(from: 0, to: 0.75)
//                .stroke(Color.white,
//                        style: StrokeStyle(
//                            lineWidth: 6,
//                            lineCap: .butt,
//                            lineJoin: .miter,
//                            miterLimit: 0,
//                            dash: [1, 8],
//                            dashPhase: 0))
//                .scaleEffect(1.1)
//                .rotationEffect(.degrees(135))
//
//            Circle()
//                .trim(from: 0, to: locationManager.correctSpeed / selectedSpeedOption.max)
//                .stroke(
//                    selectedTheme.color,
//                    style: .init(
//                        lineWidth: 20,
//                        lineCap: .butt
//                    )
//                )
//                .rotationEffect(.degrees(135))
//                .animation(.bouncy, value: locationManager.correctSpeed)
//        }
//        .padding(-20)
    }
}

#Preview(body: {
    SpeedometerView()
        .environment(LocationManager())
})
