//
//  SpeedOption.swift
//  Snel
//
//  Created by Jordi Bruin on 21/08/2024.
//

import Foundation
import Defaults

enum SpeedOption: String, CaseIterable, Identifiable, Defaults.Serializable {
    case metersPerSecond
    case kilometsPerHour
    case milesPerHour
    
    var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .metersPerSecond:
            "Meters / Second"
        case .kilometsPerHour:
            "Km / Hour"
        case .milesPerHour:
            "Mile / Hour"
        }
    }
    
    var shortName: String {
        switch self {
        case .metersPerSecond:
            "m/s"
        case .kilometsPerHour:
            "km/h"
        case .milesPerHour:
            "m/h"
        }
    }
}
