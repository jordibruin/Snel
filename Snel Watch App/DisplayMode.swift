//
//  DisplayMode.swift
//  Snel
//
//  Created by Jordi Bruin on 21/08/2024.
//

import Foundation
import SwiftUI
import Defaults

enum DisplayMode: String, CaseIterable, Identifiable {
//    case simple
    case graph
    case map
    
    var id: String { self.rawValue }
    
    @ViewBuilder
    var view: some View {
        switch self {
//        case .simple:
//            SimpleView()
        case .graph:
            GraphView()
        case .map:
            MapView()
        }
    }
}

extension CaseIterable where Self: Equatable {
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}

struct SimpleView: View {
    
    @Environment(LocationManager.self) var locationManager
    
    @Default(.decimalCount) var decimalCount
    
    var body: some View {
        VStack {
            Text(String(format:"%.\(decimalCount)f", (locationManager.correctMaxSpeed)))
                .font(.largeTitle)
            
            Text("SimpleView")
            Text("No speed: \(locationManager.noSpeedReceivedCount)")
                .font(.caption)
        }
    }
}

struct GraphView: View {
    
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
                ZStack {
                    background
                    foreground
                }
                
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
    

    var background: some View {
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(Color(white: 140/255),
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .butt,
                        lineJoin: .miter,
                        miterLimit: 0,
                        dash: [1, 4],
                        dashPhase: 0))
            .rotationEffect(.degrees(135))
    }
    
    var foreground: some View {
        Circle()
            .trim(from: 0, to: locationManager.correctSpeed / selectedSpeedOption.max)
            .stroke(
                selectedTheme.color,
                style: .init(
                    lineWidth: 20,
                    lineCap: .butt
                )
            )
            .rotationEffect(.degrees(135))
            .animation(.bouncy, value: locationManager.correctSpeed)
    }
}

#Preview(body: {
    GraphView()
        .environment(LocationManager())
})

import MapKit

struct MapView: View {
    
    @Environment(LocationManager.self) var locationManager
    @State var mapCameraPosition = MapCameraPosition.userLocation(fallback: .automatic)
    
    var body: some View {
        Map(position: $mapCameraPosition, content: {
            UserAnnotation()
        })
        .animation(.easeInOut, value: locationManager.lastLocation)
        .disabled(true)
    }
}

