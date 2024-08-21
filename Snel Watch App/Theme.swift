//
//  Theme.swift
//  Snel
//
//  Created by Jordi Bruin on 21/08/2024.
//

import Foundation
import SwiftUI
import Defaults

enum Theme: String, Identifiable, CaseIterable, Defaults.Serializable {
    case red, blue, green, orange, purple
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .red:
            .red
        case .blue:
            .blue
        case .green:
            .green
        case .orange:
            .orange
        case .purple:
            .purple
        }
    }
}
