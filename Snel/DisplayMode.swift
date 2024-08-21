//
//  DisplayMode.swift
//  Snel
//
//  Created by Jordi Bruin on 21/08/2024.
//

import Foundation
import SwiftUI

enum DisplayMode: String, CaseIterable, Identifiable {
    case simple
    case graph
    case fullscreen
    
    var id: String { self.rawValue }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .simple:
            SimpleView()
        case .graph:
            GraphView()
        case .fullscreen:
            FullScreenView()
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
        Text("\(locationManager.currentSpeed)")
            .font(.largeTitle)
        
        Text("SimpleView")
    }
}

struct GraphView: View {
    
    @Environment(LocationManager.self) var locationManager
    
    var body: some View {
        #if os(watchOS)
        Gauge(
            value: locationManager.currentSpeed,
            in: 0...40,
            label: {
                Text("km/h")
            },
            currentValueLabel: {
                Text(String(format:"%.2f", (locationManager.currentSpeed)))
                    .contentTransition(.numericText())
                    .transaction {
                        $0.animation = .default
                    }
            }
        )
        .gaugeStyle(.circular)
        .tint(.blue)
        .scaleEffect(3.0)
           
        #elseif os(iOS)
            Gauge(value: locationManager.currentSpeed, label: {
                Text("\(locationManager.currentSpeed)")
            })
        #endif
    }
}

struct FullScreenView: View {
    var body: some View {
        Text("FullScreenView")
    }
}
