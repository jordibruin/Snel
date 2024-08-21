//
//  DisplayMode.swift
//  Snel
//
//  Created by Jordi Bruin on 21/08/2024.
//

import Foundation
import SwiftUI

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
    
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}

struct SimpleView: View {
    
    @Environment(LocationManager.self) var locationManager
    
    var body: some View {
        VStack {
            Text(String(format:"%.1f", (locationManager.correctMaxSpeed)))
                .font(.largeTitle)
            
            Text("SimpleView")
            
            Text("No speed: \(locationManager.noSpeedReceivedCount)")
                .font(.caption)
        }
    }
}

struct GraphView: View {
    
    @Environment(LocationManager.self) var locationManager
    
    var body: some View {
        circleView
    }
    
    var circleView: some View {
        VStack {
            ZStack {
                background
                foreground
                
                Text(String(format:"%.0f", (locationManager.correctMaxSpeed)))
                    .font(.system(size: 80))
                    .fontWidth(.expanded)
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
            
            if locationManager.correctMaxSpeed <= 0 {
                Text("No Movement Detected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    var background: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color(white: 140/255),
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .butt,
                        lineJoin: .miter,
                        miterLimit: 0,
                        dash: [1, 4],
                        dashPhase: 0))
            .rotationEffect(.degrees(-210))
    }
    
    var foreground: some View {
        Circle()
            .trim(from: 0, to: locationManager.speedInKilometersHour / 50)
            .stroke(
                .blue,
                style: .init(
                    lineWidth: 20,
                    lineCap: .butt
                )
            )
            .rotationEffect(.degrees(-210))
            .animation(.bouncy, value: locationManager.speedInKilometersHour)
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

