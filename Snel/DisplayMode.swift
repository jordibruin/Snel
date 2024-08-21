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
}

struct SimpleView: View {
    var body: some View {
        Text("SimpleView")
    }
}

struct GraphView: View {
    var body: some View {
        Text("GraphView")
    }
}

struct FullScreenView: View {
    var body: some View {
        Text("FullScreenView")
    }
}
