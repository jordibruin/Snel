//
//  Analytics.swift
//  Snel Watch App
//
//  Created by Jordi Bruin on 30/08/2024.
//

import Foundation
import Foundation
import TelemetryClient

public enum AnalyticType: String, Hashable {
    case tappedSpeedSelector
    
    case selectedTheme
    case resetMax
    case selectedSpeedOption
}

public struct Analytics {

    public static func send(_ option: AnalyticType, with additionalParameters: [String: String]? = nil ) {
        if let additionalParameters {
            TelemetryDeck.signal(option.rawValue, parameters: additionalParameters)
        } else {
            TelemetryDeck.signal(option.rawValue)
        }
        
        if let additionalParameters {
            debugPrint("📊 \(option.rawValue)", additionalParameters)
        } else {
            debugPrint("📊 \(option.rawValue)")
        }
    }
}
